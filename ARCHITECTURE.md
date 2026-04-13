# GitMissions — Architecture & Implementation Plan

This document describes the full technical architecture for the AI implementing GitMissions.
Follow this exactly. The UI/UX must match k8smissions closely.

---

## Stack

- **Language**: Python 3.9+
- **UI Library**: `rich` (panels, tables, progress bars, markdown, syntax highlighting)
- **Shell scripts**: bash (play.sh, install.sh, setup.sh, solution.sh per level)
- **Level data**: YAML (mission.yaml per level)
- **Progress storage**: JSON (progress.json in repo root)
- **Sandbox**: `/tmp/gitmissions/<level-slug>/` — fresh git repo per level

---

## Key Design Decisions

### 1. Sandbox Model
Every level gets a sandboxed git repository created by `setup.sh`.
- Path: `/tmp/gitmissions/<module-slug>/<level-slug>/`
- The engine calls `setup.sh <sandbox_path>` which runs `git init`, makes commits,
  creates branches, introduces the broken/challenge state, etc.
- Player opens a second terminal, `cd`s to that path, and uses git to fix things.
- On `reset`, the engine deletes the sandbox and reruns `setup.sh`.

### 2. Validation Model
Validation is done by Python in `mission.yaml` under a `validators` list.
Each validator is a named check type + parameters. The engine runs all validators
and reports pass/fail per check. All must pass to complete the level.

Validator types (implemented in `engine/validator.py`):
- `branch_exists` — checks a branch name exists in the repo
- `branch_not_exists` — checks a branch was deleted
- `commit_message_contains` — HEAD commit message contains a string
- `file_exists` — a file exists in the working tree or index
- `file_not_exists` — a file does not exist
- `file_content_contains` — file content contains a string
- `file_content_equals` — file content equals exact string
- `no_conflict_markers` — no `<<<<<<<` in any tracked file
- `is_clean` — working tree is clean (no staged/unstaged changes)
- `is_on_branch` — HEAD is on a specific branch (not detached)
- `is_detached` — HEAD is detached
- `tag_exists` — a tag exists
- `tag_not_exists` — a tag was deleted
- `commit_count_gte` — number of commits on branch >= N
- `commit_count_eq` — number of commits on branch == N
- `merge_commit_exists` — there is a merge commit on the branch
- `no_merge_commit` — no merge commits (linear history)
- `hook_exists` — .git/hooks/<name> file exists and is executable
- `hook_output_contains` — running the hook produces output containing string
- `remote_exists` — remote name exists in config
- `ahead_of` — current branch is N commits ahead of another
- `stash_empty` — stash list is empty
- `stash_not_empty` — stash has at least one entry
- `reflog_contains` — reflog mentions a specific hash or message
- `submodule_exists` — a submodule path is registered
- `worktree_count` — number of worktrees matches N
- `script_passes` — run a custom inline shell script; exit 0 = pass

### 3. Engine Flow

```
play.sh
  └─► engine/engine.py
        1. load_progress()
        2. show_welcome() banner
        3. prompt_player_name() if first run
        4. resolve current level from progress
        5. prepare_level():
              a. mkdir -p sandbox_path
              b. run setup.sh sandbox_path
              c. print sandbox path to player
        6. show_mission_briefing(mission_data)
        7. REPL loop:
              check / watch / hint / solution / guide / debrief /
              reset / skip / status / help / quit
        8. On "check":
              run_validators(sandbox_path, validators)
              if all pass → show_victory() → award XP → next level
              else → show failures with diff hints
        9. On module completion → generate_certificate()
```

### 4. UI Style (must match k8smissions exactly)

Implemented in `engine/ui.py` using `rich`:

- **Welcome screen**: large ASCII art "GITMISSIONS" banner in green/yellow gradient,
  tagline, player name, total XP, current module badge
- **Mission briefing panel**: `rich.Panel` with bold title, description, objective in
  yellow, `[concepts]` tags in cyan, difficulty badge, expected time, XP reward
- **Hint system**: hints numbered, shown one at a time with `[Hint N/M]` header in yellow
- **Victory panel**: green panel with "MISSION COMPLETE", XP earned, time taken,
  next mission preview
- **Status view**: table of modules with level count, XP earned/total, completion %
- **Module certificate**: big box-art certificate with module name, completion date,
  player name, XP earned — rendered fully in terminal
- **Failure output**: red panel showing which validators failed and why
- **Prompt**: `[cyan]GitMissions[/] [yellow]>[/]` — identical style to k8smissions

### 5. Progress File Schema

```json
{
  "player_name": "Alice",
  "total_xp": 0,
  "completed_levels": [],
  "current_module": "module-01-foundations",
  "current_level": "level-001-init-your-first-repo",
  "module_certificates": [],
  "time_per_level": {},
  "level_start_time": null
}
```

### 6. levels.json Registry

Generated by `scripts/generate_registry.py`. Scans all `mission.yaml` files and builds:

```json
[
  {
    "module": "module-01-foundations",
    "level": "level-001-init-your-first-repo",
    "name": "Init Your First Repo",
    "xp": 100,
    "difficulty": "beginner",
    "order": 1
  },
  ...
]
```

---

## File Layout (complete)

```
gitmissions/
├── play.sh
├── install.sh
├── requirements.txt          (rich, pyyaml)
├── progress.json             (auto-created)
├── levels.json               (generated)
├── GIT_GUIDE.md
├── engine/
│   ├── __init__.py
│   ├── engine.py
│   ├── ui.py
│   ├── certificate.py
│   ├── player.py
│   ├── reset.py
│   └── validator.py
├── scripts/
│   ├── build_levels.py
│   └── generate_registry.py
├── completion/
│   ├── _gitmissions
│   └── gitmissions.bash
└── modules/
    ├── module-01-foundations/
    ├── module-02-branching-basics/
    ├── module-03-merge-conflicts/
    ├── module-04-remote-operations/
    ├── module-05-detached-head/
    ├── module-06-rebase/
    ├── module-07-stash/
    ├── module-08-history-reflog/
    ├── module-09-reset-revert/
    ├── module-10-tags-releases/
    ├── module-11-git-hooks/
    ├── module-12-advanced-git/
    ├── module-13-git-internals/
    └── module-14-war-games/
```

---

## install.sh

```bash
#!/usr/bin/env bash
set -e

echo "Setting up GitMissions..."

# Check git
if ! command -v git &>/dev/null; then
  echo "ERROR: git is not installed"; exit 1
fi

# Check python
if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 is not installed"; exit 1
fi

# Install Python deps
python3 -m pip install --quiet -r requirements.txt

# Generate registry if missing
if [ ! -f levels.json ]; then
  python3 scripts/generate_registry.py
fi

echo "GitMissions is ready. Run: ./play.sh"
```

## play.sh

```bash
#!/usr/bin/env bash
REPO="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO"
PYTHONPATH="$REPO" python3 -m engine.engine "$@"
```

## requirements.txt

```
rich>=13.0.0
pyyaml>=6.0
```

---

## engine/validator.py — Key Implementation Notes

```python
import subprocess, os
from pathlib import Path

def run_git(sandbox: Path, *args) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", "-C", str(sandbox)] + list(args),
        capture_output=True, text=True
    )

def validate(sandbox: Path, validators: list[dict]) -> list[dict]:
    """Run all validators. Returns list of {name, passed, message}."""
    results = []
    for v in validators:
        vtype = v["type"]
        result = _dispatch(sandbox, vtype, v)
        results.append(result)
    return results

def _dispatch(sandbox, vtype, v):
    handlers = {
        "branch_exists": _branch_exists,
        "branch_not_exists": _branch_not_exists,
        "is_clean": _is_clean,
        "is_on_branch": _is_on_branch,
        "is_detached": _is_detached,
        "no_conflict_markers": _no_conflict_markers,
        "commit_message_contains": _commit_message_contains,
        "file_exists": _file_exists,
        "file_not_exists": _file_not_exists,
        "file_content_contains": _file_content_contains,
        "tag_exists": _tag_exists,
        "commit_count_gte": _commit_count_gte,
        "merge_commit_exists": _merge_commit_exists,
        "no_merge_commit": _no_merge_commit,
        "hook_exists": _hook_exists,
        "stash_empty": _stash_empty,
        "script_passes": _script_passes,
        # ... all others
    }
    fn = handlers.get(vtype)
    if fn is None:
        return {"name": vtype, "passed": False, "message": f"Unknown validator: {vtype}"}
    return fn(sandbox, v)
```

---

## engine/reset.py — Key Implementation Notes

```python
import shutil, subprocess
from pathlib import Path

SANDBOX_BASE = Path("/tmp/gitmissions")

def get_sandbox_path(module: str, level: str) -> Path:
    return SANDBOX_BASE / module / level

def prepare_level(module: str, level: str, level_dir: Path) -> Path:
    sandbox = get_sandbox_path(module, level)
    # Clean previous run
    if sandbox.exists():
        shutil.rmtree(sandbox)
    sandbox.mkdir(parents=True)

    setup_script = level_dir / "setup.sh"
    result = subprocess.run(
        ["bash", str(setup_script), str(sandbox)],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        raise RuntimeError(f"setup.sh failed:\n{result.stderr}")
    return sandbox
```

---

## engine/engine.py — REPL Loop Sketch

The main loop should:
1. Load mission.yaml for current level
2. Call `prepare_level()` to create sandbox
3. Print sandbox path prominently: `cd /tmp/gitmissions/module-01.../level-001.../`
4. Show mission briefing panel
5. Enter REPL:
   - `check` / `1`: run validators, show pass/fail, if all pass → victory → advance
   - `watch` / `w`: launch background thread calling check every 3s
   - `hint` / `2`: show next hint (up to max hints, tracks which was last shown)
   - `solution` / `3`: print solution.sh content with syntax highlighting
   - `guide` / `4`: print step-by-step guide from mission.yaml
   - `debrief` / `5`: print post-mission debrief (only after completion or skip)
   - `reset` / `6`: delete sandbox, re-run setup.sh, re-print sandbox path
   - `skip` / `7`: confirm skip (no XP), advance to next level
   - `status` / `8`: show progress table
   - `help` / `9`: show command reference
   - `quit` / `q`: save and exit
