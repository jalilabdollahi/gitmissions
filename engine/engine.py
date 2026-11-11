from __future__ import annotations

import json
import os
import re
import shlex
import subprocess
import time
from pathlib import Path

import yaml
from rich.prompt import Prompt

try:
    import readline
except ImportError:  # pragma: no cover - readline is missing on some platforms
    readline = None

from engine.certificate import generate_certificate, render_certificate, save_certificate
from engine.player import prompt_player_name
from engine.reset import LevelSetupError, prepare_level
from engine.ui import (
    console,
    render_sandbox_path,
    show_all_hints_used,
    show_check_results,
    show_debrief,
    show_error,
    show_guide,
    show_help,
    show_hint,
    show_info,
    show_menu_bar,
    show_mission_briefing,
    show_progress_summary,
    show_module_completion,
    show_solution,
    show_status,
    show_victory,
    show_watch_tick,
    show_welcome,
)
from engine.validator import validate_all

REPO_ROOT = Path(__file__).resolve().parent.parent
PROGRESS_FILE = REPO_ROOT / "progress.json"
LEVELS_REGISTRY = REPO_ROOT / "levels.json"
MODULES_DIR = REPO_ROOT / "modules"
HISTORY_FILE = REPO_ROOT / ".gitmissions_history"
WATCH_INTERVAL = 3

COMMAND_ALIASES = {
    "1": "check",
    "w": "watch",
    "2": "hint",
    "3": "solution",
    "4": "guide",
    "5": "debrief",
    "6": "reset",
    "7": "skip",
    "8": "status",
    "9": "help",
    "g": "handbook",
    "gitguide": "handbook",
    "q": "quit",
    "exit": "quit",
}

GITMISSIONS_COMMANDS = frozenset({
    "check", "watch", "hint", "solution", "guide", "debrief", "handbook",
    "reset", "skip", "status", "help", "quit",
})

# Characters that make a line a compound shell command rather than a plain `cd`.
_SHELL_OPERATORS = re.compile(r"&&|\|\||[;|&<>`$(]")


# --------------------------------------------------------------------------- progress


def default_progress() -> dict:
    return {
        "player_name": None,
        "total_xp": 0,
        "completed_levels": [],
        "skipped_levels": [],
        "current_module": "module-01-foundations",
        "current_level": "level-001-init-your-first-repo",
        "module_certificates": [],
        "time_per_level": {},
        "hint_state": {},
    }


def load_progress() -> dict:
    progress = default_progress()
    if not PROGRESS_FILE.exists():
        return progress
    try:
        saved = json.loads(PROGRESS_FILE.read_text(encoding="utf-8"))
        if not isinstance(saved, dict):
            raise ValueError("progress.json is not an object")
    except (OSError, ValueError) as exc:
        backup = PROGRESS_FILE.with_name("progress.json.corrupt")
        PROGRESS_FILE.replace(backup)
        show_error(f"progress.json could not be read ({exc}); it was moved to {backup.name}. Starting fresh.")
        return progress
    saved.pop("level_start_time", None)
    progress.update(saved)
    return progress


def save_progress(progress: dict) -> None:
    """Write progress atomically so an interrupted save never corrupts it."""
    tmp = PROGRESS_FILE.with_name(PROGRESS_FILE.name + ".tmp")
    tmp.write_text(json.dumps(progress, indent=2), encoding="utf-8")
    os.replace(tmp, PROGRESS_FILE)


def load_registry() -> list[dict]:
    if not LEVELS_REGISTRY.exists():
        return []
    registry = json.loads(LEVELS_REGISTRY.read_text(encoding="utf-8"))
    return sorted(registry, key=lambda item: item["order"])


def load_mission(module: str, level: str) -> dict:
    mission_path = MODULES_DIR / module / level / "mission.yaml"
    return yaml.safe_load(mission_path.read_text(encoding="utf-8"))


def resolve_current_level(progress: dict, registry: list[dict]) -> dict | None:
    """First level neither completed nor skipped; once those run out, revisit skipped levels."""
    completed = set(progress.get("completed_levels", []))
    skipped = set(progress.get("skipped_levels", []))
    candidates = [item for item in registry if item["level"] not in completed]
    entry = next((item for item in candidates if item["level"] not in skipped), None)
    if entry is None and candidates:
        entry = candidates[0]
    if entry is not None:
        progress["current_module"] = entry["module"]
        progress["current_level"] = entry["level"]
    return entry


def format_duration(seconds: float) -> str:
    total = max(int(seconds), 0)
    minutes, secs = divmod(total, 60)
    return f"{minutes}m {secs}s"


def _module_levels(module_name: str, registry: list[dict]) -> list[dict]:
    return [item for item in registry if item["module"] == module_name]


def _complete_level(progress: dict, registry: list[dict], entry: dict, elapsed: float) -> None:
    completed = set(progress.get("completed_levels", []))
    if entry["level"] not in completed:
        completed.add(entry["level"])
        progress["total_xp"] = progress.get("total_xp", 0) + entry["xp"]
    progress["completed_levels"] = sorted(completed)
    progress["skipped_levels"] = [lvl for lvl in progress.get("skipped_levels", []) if lvl != entry["level"]]
    progress.setdefault("time_per_level", {})[entry["level"]] = int(elapsed)

    module = entry["module"]
    levels = _module_levels(module, registry)
    if levels and all(item["level"] in completed for item in levels) and module not in progress.get("module_certificates", []):
        progress.setdefault("module_certificates", []).append(module)
        player = progress.get("player_name") or "Player"
        xp = sum(item["xp"] for item in levels)
        render_certificate(module, player, xp)
        save_certificate(REPO_ROOT, module, generate_certificate(module, player, xp))
        show_module_completion(module, xp, player)


def _skip_level(progress: dict, entry: dict) -> None:
    skipped = progress.setdefault("skipped_levels", [])
    if entry["level"] in skipped:
        skipped.remove(entry["level"])  # move to the back of the revisit queue
    skipped.append(entry["level"])


# --------------------------------------------------------------------------- shell helpers


def setup_history() -> None:
    if readline is None:
        return
    try:
        readline.read_history_file(str(HISTORY_FILE))
    except FileNotFoundError:
        pass
    except OSError:
        return
    readline.set_history_length(500)


def append_history() -> None:
    """Persist the history readline already recorded for the last prompt."""
    if readline is None:
        return
    try:
        readline.write_history_file(str(HISTORY_FILE))
    except OSError:
        pass


def _effective_repo_path(sandbox: Path, mission: dict) -> Path:
    return (sandbox / mission.get("repo_path", ".")).resolve()


def _is_plain_cd(raw: str) -> bool:
    return (raw == "cd" or raw.startswith(("cd ", "cd\t"))) and not _SHELL_OPERATORS.search(raw)


def _handle_cd(raw: str, state: dict) -> None:
    """Handle `cd` virtually, since each shell command runs in its own process."""
    try:
        parts = shlex.split(raw)
    except ValueError as exc:
        show_error(f"cd: {exc}")
        return
    target = parts[1] if len(parts) > 1 else "~"
    if target == "-":
        state["cwd"], state["prev_cwd"] = state.get("prev_cwd", state["cwd"]), state["cwd"]
        return
    if target == "~" or target.startswith("~/"):
        new_path = (state["repo_path"] / target[2:]).resolve()
    else:
        new_path = (state["cwd"] / os.path.expanduser(target)).resolve()
    if new_path.is_dir():
        state["prev_cwd"] = state["cwd"]
        state["cwd"] = new_path
    else:
        show_error(f"cd: {target}: No such file or directory")


def _run_shell(raw: str, cwd: Path) -> None:
    """Run a player command with bash in the sandbox directory, using the player's own git config."""
    if not cwd.is_dir():
        show_error(f"Current directory {cwd} no longer exists; use `cd ~` or `reset`.")
        return
    try:
        subprocess.run(["bash", "-c", raw], cwd=str(cwd), check=False)
    except KeyboardInterrupt:
        console.print()


def _cwd_display(state: dict) -> str:
    try:
        rel = state["cwd"].relative_to(state["repo_path"])
        return f"~/{rel}" if str(rel) != "." else "~"
    except ValueError:
        return str(state["cwd"])


def _maybe_collect_heredoc(raw: str) -> str:
    match = re.search(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1\s*$", raw)
    if not match:
        return raw
    terminator = match.group(2)
    strip_tabs = "<<-" in raw[match.start():match.start() + 3]
    lines = [raw]
    while True:
        next_line = input("... ")
        lines.append(next_line)
        if (next_line.lstrip("\t") if strip_tabs else next_line) == terminator:
            break
    return "\n".join(lines)


# --------------------------------------------------------------------------- level lifecycle


def _start_level(state: dict) -> None:
    """(Re)build the sandbox for the current entry and print the briefing."""
    entry = state["entry"]
    state["level_ready"] = False
    try:
        sandbox = prepare_level(entry["module"], entry["level"], state["level_dir"])
    except LevelSetupError as exc:
        show_error(f"Could not set up this level: {exc}")
        show_info("Try `reset`, or `skip` to move on. Please report this level as a bug.")
        return
    state["sandbox"] = sandbox
    state["repo_path"] = _effective_repo_path(sandbox, state["mission"])
    state["cwd"] = state["repo_path"]
    state["prev_cwd"] = state["repo_path"]
    state["level_started_at"] = time.time()
    state["level_completed"] = False
    state["level_ready"] = True

    show_progress_summary(state["progress"], state["registry"], state["mission"]["name"])
    render_sandbox_path(str(state["repo_path"]))
    show_mission_briefing(state["mission"], entry["order"], len(state["registry"]), str(state["repo_path"]))


def _run_check(state: dict, results: list[dict] | None = None) -> None:
    if not state.get("level_ready"):
        show_error("This level's sandbox is not ready. Use `reset` or `skip`.")
        return
    if results is None:
        results = validate_all(state["repo_path"], state["mission"]["validators"])
    show_check_results(results)
    if not all(item["passed"] for item in results):
        return

    elapsed = time.time() - state["level_started_at"]
    progress, registry, entry = state["progress"], state["registry"], state["entry"]
    console.clear()
    _complete_level(progress, registry, entry, elapsed)
    next_entry = resolve_current_level(progress, registry)
    save_progress(progress)
    show_victory(state["mission"]["name"], entry["xp"], format_duration(elapsed), next_entry["name"] if next_entry else None)
    show_debrief(state["mission"].get("debrief", "No debrief available yet."), state["mission"].get("common_mistakes", []))
    state["level_completed"] = True
    try:
        Prompt.ask("\n[dim]Press Enter to continue to the next level[/dim]", default="")
    except (KeyboardInterrupt, EOFError):
        console.print()
    state["advance"] = True


def _run_watch(state: dict) -> None:
    if not state.get("level_ready"):
        show_error("This level's sandbox is not ready. Use `reset` or `skip`.")
        return
    show_info(f"Watching the repo every {WATCH_INTERVAL}s. Work in another terminal; press Ctrl+C to stop.")
    try:
        while True:
            results = validate_all(state["repo_path"], state["mission"]["validators"])
            passed = all(item["passed"] for item in results)
            show_watch_tick(passed, sum(item["passed"] for item in results), len(results))
            if passed:
                console.print()
                _run_check(state, results)
                return
            time.sleep(WATCH_INTERVAL)
    except KeyboardInterrupt:
        console.print()
        show_info("Watch mode stopped.")


def dispatch(cmd: str, state: dict) -> bool:
    """Handle a resolved gitmissions command. Returns False to quit."""
    mission, progress, entry = state["mission"], state["progress"], state["entry"]
    if cmd == "check":
        _run_check(state)
    elif cmd == "watch":
        _run_watch(state)
    elif cmd == "hint":
        hints = mission.get("hints", [])
        index = progress.setdefault("hint_state", {}).get(entry["level"], 0)
        if index >= len(hints):
            show_all_hints_used(len(hints))
        else:
            show_hint(hints[index], index + 1, len(hints))
            progress["hint_state"][entry["level"]] = index + 1
            save_progress(progress)
    elif cmd == "solution":
        show_solution((state["level_dir"] / "solution.sh").read_text(encoding="utf-8"))
    elif cmd == "guide":
        show_guide(mission.get("guide", "No guide available."))
    elif cmd == "handbook":
        show_guide((REPO_ROOT / "GIT_GUIDE.md").read_text(encoding="utf-8"))
    elif cmd == "debrief":
        if state.get("level_completed") or entry["level"] in progress.get("completed_levels", []):
            show_debrief(mission.get("debrief", "No debrief available yet."), mission.get("common_mistakes", []))
        else:
            show_info("The debrief unlocks after you complete the level.")
    elif cmd == "reset":
        console.clear()
        show_info("Resetting level sandbox…")
        _start_level(state)
    elif cmd == "skip":
        _skip_level(progress, entry)
        save_progress(progress)
        show_info("Level skipped (no XP). Skipped levels come back after you finish the rest.")
        state["advance"] = True
    elif cmd == "status":
        show_status(progress, state["registry"])
    elif cmd == "help":
        show_help()
    elif cmd == "quit":
        save_progress(progress)
        return False
    return True


# --------------------------------------------------------------------------- main loop


def _read_command(state: dict) -> str | None:
    """Prompt for one command. Returns None when the player wants to quit (Ctrl+D)."""
    show_menu_bar()
    try:
        raw = console.input(f"[cyan]gitmissions[/cyan] [dim]{_cwd_display(state)}[/dim] [yellow]❯[/yellow] ").strip()
        if raw:
            raw = _maybe_collect_heredoc(raw)
    except KeyboardInterrupt:
        console.print()
        show_info("Type `q` to save and quit.")
        return ""
    except EOFError:
        console.print()
        return None
    if raw:
        append_history()
    return raw


def main() -> None:
    setup_history()
    registry = load_registry()
    if not registry:
        show_error("levels.json is missing or empty. Run ./install.sh first.")
        return
    progress = load_progress()
    try:
        prompt_player_name(progress)
    except (KeyboardInterrupt, EOFError):
        console.print()
        return
    save_progress(progress)

    while True:
        entry = resolve_current_level(progress, registry)
        if entry is None:
            show_info("All missions are complete. Excellent work.")
            break

        console.clear()
        show_welcome(progress.get("player_name") or "Player", progress.get("total_xp", 0), entry["module"])
        level_dir = MODULES_DIR / entry["module"] / entry["level"]
        state = {
            "advance": False,
            "entry": entry,
            "level_dir": level_dir,
            "mission": load_mission(entry["module"], entry["level"]),
            "progress": progress,
            "registry": registry,
            "sandbox": None,
            "repo_path": level_dir,
            "cwd": level_dir,
            "level_started_at": time.time(),
            "level_completed": False,
            "level_ready": False,
        }
        _start_level(state)

        while not state["advance"]:
            raw = _read_command(state)
            if raw is None:
                save_progress(progress)
                return
            if not raw:
                continue
            if _is_plain_cd(raw):
                _handle_cd(raw, state)
                continue
            resolved = COMMAND_ALIASES.get(raw.lower(), raw.lower())
            if resolved in GITMISSIONS_COMMANDS:
                if not dispatch(resolved, state):
                    return
            else:
                _run_shell(raw, state["cwd"])


if __name__ == "__main__":
    main()
