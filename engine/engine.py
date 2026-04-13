from __future__ import annotations

import json
import readline  # noqa: F401
import re
import subprocess
import threading
import time
from pathlib import Path

import yaml
from rich.prompt import Prompt

from engine.certificate import generate_certificate, render_certificate, save_certificate
from engine.player import prompt_player_name
from engine.reset import prepare_level
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
    "guide git": "handbook",
    "handbook": "handbook",
    "q": "quit",
}

GITMISSIONS_COMMANDS = frozenset({
    "check", "watch", "hint", "solution", "guide", "debrief", "handbook",
    "reset", "skip", "status", "help", "quit",
})


def default_progress() -> dict:
    return {
        "player_name": None,
        "total_xp": 0,
        "completed_levels": [],
        "current_module": "module-01-foundations",
        "current_level": "level-001-init-your-first-repo",
        "module_certificates": [],
        "time_per_level": {},
        "level_start_time": None,
        "hint_state": {},
    }


def load_progress() -> dict:
    if not PROGRESS_FILE.exists():
        return default_progress()
    return json.loads(PROGRESS_FILE.read_text(encoding="utf-8"))


def save_progress(progress: dict) -> None:
    PROGRESS_FILE.write_text(json.dumps(progress, indent=2), encoding="utf-8")


def setup_history() -> None:
    try:
        readline.read_history_file(str(HISTORY_FILE))
    except FileNotFoundError:
        HISTORY_FILE.touch()
    except OSError:
        return

    readline.set_history_length(500)
    try:
        readline.parse_and_bind("set editing-mode emacs")
        readline.parse_and_bind('"\\e[A": previous-history')
        readline.parse_and_bind('"\\e[B": next-history')
    except OSError:
        pass


def append_history(command: str) -> None:
    if not command.strip():
        return
    try:
        if readline.get_current_history_length() == 0 or readline.get_history_item(readline.get_current_history_length()) != command:
            readline.add_history(command)
        readline.write_history_file(str(HISTORY_FILE))
    except OSError:
        pass


def load_registry() -> list[dict]:
    if not LEVELS_REGISTRY.exists():
        return []
    return json.loads(LEVELS_REGISTRY.read_text(encoding="utf-8"))


def load_mission(module: str, level: str) -> dict:
    mission_path = MODULES_DIR / module / level / "mission.yaml"
    return yaml.safe_load(mission_path.read_text(encoding="utf-8"))


def resolve_current_level(progress: dict, registry: list[dict]) -> dict | None:
    completed = set(progress.get("completed_levels", []))
    for item in registry:
        if item["level"] not in completed:
            progress["current_module"] = item["module"]
            progress["current_level"] = item["level"]
            return item
    return None


def format_duration(seconds: float) -> str:
    total = max(int(seconds), 0)
    minutes, secs = divmod(total, 60)
    return f"{minutes}m {secs}s"


def run_watch_mode(sandbox: Path, validators: list[dict], stop_event: threading.Event) -> None:
    while not stop_event.is_set():
        results = validate_all(sandbox, validators)
        show_watch_tick(all(item["passed"] for item in results))
        if stop_event.wait(3):
            break


def _module_completed(module_name: str, completed_levels: set[str], registry: list[dict]) -> bool:
    module_levels = [item["level"] for item in registry if item["module"] == module_name]
    return bool(module_levels) and all(level in completed_levels for level in module_levels)


def _module_xp(module_name: str, registry: list[dict]) -> int:
    return sum(item["xp"] for item in registry if item["module"] == module_name)


def _effective_repo_path(sandbox: Path, mission: dict) -> Path:
    repo_path = mission.get("repo_path", ".")
    return (sandbox / repo_path).resolve()


def _advance_after_success(progress: dict, registry: list[dict], current_entry: dict) -> dict | None:
    completed = set(progress.get("completed_levels", []))
    if current_entry["level"] not in completed:
        completed.add(current_entry["level"])
        progress["completed_levels"] = sorted(completed)
        progress["total_xp"] = progress.get("total_xp", 0) + current_entry["xp"]

    module = current_entry["module"]
    if _module_completed(module, completed, registry) and module not in progress.get("module_certificates", []):
        progress.setdefault("module_certificates", []).append(module)
        xp = _module_xp(module, registry)
        render_certificate(module, progress.get("player_name") or "Player", xp)
        save_certificate(REPO_ROOT, module, generate_certificate(module, progress.get("player_name") or "Player", xp))
        show_module_completion(module, xp, progress.get("player_name") or "Player")

    return resolve_current_level(progress, registry)


def _handle_cd(raw: str, state: dict) -> None:
    """Handle `cd` as a virtual directory change within the sandbox."""
    parts = raw.split(None, 1)
    if len(parts) == 1 or parts[1] in ("~", ""):
        state["cwd"] = state["sandbox"]
        return
    target = parts[1]
    new_path = (state["cwd"] / target).resolve()
    if new_path.is_dir():
        state["cwd"] = new_path
    else:
        console.print(f"[red]cd: {target}: No such file or directory[/red]")


def _run_shell(raw: str, cwd: Path) -> None:
    """Run an arbitrary shell command in the sandbox directory."""
    subprocess.run(raw, shell=True, cwd=str(cwd), check=False)


def _cwd_display(state: dict) -> str:
    """Return a short cwd label relative to the sandbox root."""
    try:
        rel = state["cwd"].relative_to(state["sandbox"])
        return f"~/{rel}" if str(rel) != "." else "~"
    except ValueError:
        return str(state["cwd"])


def _clear_screen() -> None:
    console.clear()


def _show_handbook() -> None:
    handbook_path = REPO_ROOT / "GIT_GUIDE.md"
    show_guide(handbook_path.read_text(encoding="utf-8"))


def _maybe_collect_heredoc(raw: str) -> str:
    match = re.search(r"<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1\s*$", raw)
    if not match:
        return raw

    terminator = match.group(2)
    lines = [raw]
    while True:
        next_line = Prompt.ask("[dim]...[/dim]", default="")
        lines.append(next_line)
        if next_line == terminator:
            break
    return "\n".join(lines)


def dispatch(cmd: str, state: dict) -> bool:
    """Handle a resolved gitmissions command. Returns False to quit."""
    if cmd == "check":
        results = validate_all(state["repo_path"], state["mission"]["validators"])
        show_check_results(results)
        if all(item["passed"] for item in results):
            elapsed = time.time() - state["level_started_at"]
            next_entry = _advance_after_success(state["progress"], state["registry"], state["entry"])
            next_name = next_entry["name"] if next_entry else None
            _clear_screen()
            show_victory(state["mission"]["name"], state["entry"]["xp"], format_duration(elapsed), next_name)
            show_debrief(
                state["mission"].get("debrief", "No debrief available yet."),
                state["mission"].get("common_mistakes", []),
            )
            Prompt.ask("\n[dim]Press Enter to continue to the next level[/dim]", default="")
            save_progress(state["progress"])
            state["level_completed"] = True
            state["advance"] = True
        return True
    if cmd == "watch":
        stop_event = threading.Event()
        worker = threading.Thread(
            target=run_watch_mode,
            args=(state["repo_path"], state["mission"]["validators"], stop_event),
            daemon=True,
        )
        worker.start()
        Prompt.ask("\n[dim]Press Enter to stop watch mode[/dim]", default="")
        stop_event.set()
        worker.join(timeout=1)
        print()
        return True
    if cmd == "hint":
        hints = state["mission"].get("hints", [])
        index = state["progress"].setdefault("hint_state", {}).get(state["entry"]["level"], 0)
        if index >= len(hints):
            show_all_hints_used(len(hints))
            show_solution((state["level_dir"] / "solution.sh").read_text(encoding="utf-8"))
        else:
            show_hint(hints[index], index + 1, len(hints))
            state["progress"]["hint_state"][state["entry"]["level"]] = index + 1
            save_progress(state["progress"])
        return True
    if cmd == "solution":
        show_solution((state["level_dir"] / "solution.sh").read_text(encoding="utf-8"))
        return True
    if cmd == "guide":
        show_guide(state["mission"].get("guide", "No guide available."))
        return True
    if cmd == "handbook":
        _show_handbook()
        return True
    if cmd == "debrief":
        if not state.get("level_completed"):
            show_info("The debrief unlocks after you complete the level.")
        else:
            show_debrief(
                state["mission"].get("debrief", "No debrief available yet."),
                state["mission"].get("common_mistakes", []),
            )
        return True
    if cmd == "reset":
        _clear_screen()
        show_info("Resetting level sandbox…")
        sandbox = prepare_level(state["entry"]["module"], state["entry"]["level"], state["level_dir"])
        state["sandbox"] = sandbox
        state["cwd"] = _effective_repo_path(sandbox, state["mission"])
        state["repo_path"] = state["cwd"]
        state["level_started_at"] = time.time()
        state["level_completed"] = False
        render_sandbox_path(str(state["repo_path"]))
        show_progress_summary(state["progress"], state["registry"], state["mission"]["name"])
        show_mission_briefing(state["mission"], state["entry"]["order"], len(state["registry"]), str(state["repo_path"]))
        return True
    if cmd == "skip":
        next_entry = resolve_current_level(state["progress"], state["registry"])
        if next_entry and next_entry["level"] == state["entry"]["level"]:
            state["progress"].setdefault("completed_levels", [])
            state["progress"]["completed_levels"].append(state["entry"]["level"])
        save_progress(state["progress"])
        state["advance"] = True
        return True
    if cmd == "status":
        show_status(state["progress"], state["registry"])
        return True
    if cmd == "help":
        show_help()
        return True
    if cmd == "quit":
        save_progress(state["progress"])
        return False
    show_error(f"Unknown command '{cmd}'. Type 'help' or press 9.")
    return True


def main() -> None:
    setup_history()
    registry = load_registry()
    progress = load_progress()
    prompt_player_name(progress)
    save_progress(progress)

    _clear_screen()
    show_welcome(
        progress.get("player_name") or "Player",
        progress.get("total_xp", 0),
        progress.get("current_module", ""),
    )

    while True:
        entry = resolve_current_level(progress, registry)
        if entry is None:
            show_info("All missions are complete. Excellent work.")
            break

        level_dir = MODULES_DIR / entry["module"] / entry["level"]
        mission = load_mission(entry["module"], entry["level"])
        sandbox = prepare_level(entry["module"], entry["level"], level_dir)
        repo_path = _effective_repo_path(sandbox, mission)

        _clear_screen()
        show_welcome(
            progress.get("player_name") or "Player",
            progress.get("total_xp", 0),
            progress.get("current_module", ""),
        )
        show_progress_summary(progress, registry, mission["name"])
        render_sandbox_path(str(repo_path))
        show_mission_briefing(mission, entry["order"], len(registry), str(repo_path))

        state = {
            "advance": False,
            "entry": entry,
            "level_dir": level_dir,
            "mission": mission,
            "progress": progress,
            "registry": registry,
            "sandbox": sandbox,
            "repo_path": repo_path,
            "cwd": repo_path,
            "level_started_at": time.time(),
            "level_completed": False,
        }

        while True:
            show_menu_bar()
            cwd_label = _cwd_display(state)
            raw = Prompt.ask(
                f"[cyan]gitmissions[/cyan] [dim]{cwd_label}[/dim] [yellow]❯[/yellow]"
            ).strip()
            if not raw:
                continue
            raw = _maybe_collect_heredoc(raw)
            append_history(raw)

            # cd is a shell builtin — handle it virtually
            cmd_lower = raw.lower()
            if cmd_lower == "cd" or cmd_lower.startswith("cd ") or cmd_lower.startswith("cd\t"):
                _handle_cd(raw, state)
                continue

            # Resolve gitmissions aliases
            resolved = COMMAND_ALIASES.get(cmd_lower, cmd_lower)

            if resolved in GITMISSIONS_COMMANDS:
                if not dispatch(resolved, state):
                    return
            else:
                # Run as a shell command in the current sandbox directory
                _run_shell(raw, state["cwd"])

            if state["advance"]:
                break


if __name__ == "__main__":
    main()
