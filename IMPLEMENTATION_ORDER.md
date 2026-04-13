# GitMissions — Implementation Order for AI

Follow this exact order to implement GitMissions from scratch.

---

## Phase 1: Project Skeleton

Create these files in order:

1. `requirements.txt` — `rich>=13.0.0` and `pyyaml>=6.0`
2. `play.sh` — launcher script (see ARCHITECTURE.md)
3. `install.sh` — setup script (see ARCHITECTURE.md)
4. `engine/__init__.py` — empty
5. `engine/ui.py` — all UI functions (see ENGINE_SPEC.md)
6. `engine/player.py` — player name prompt
7. `engine/validator.py` — all 25+ validators
8. `engine/reset.py` — sandbox setup
9. `engine/certificate.py` — module certificates
10. `engine/engine.py` — main game loop + REPL

## Phase 2: Scripts

11. `scripts/generate_registry.py`
12. `scripts/build_levels.py`

## Phase 3: Shell Completion

13. `completion/_gitmissions` (zsh)
14. `completion/gitmissions.bash`

## Phase 4: GIT_GUIDE.md

15. Write the full beginner Git handbook

## Phase 5: All 225 Levels

Generate all levels in module order. For each level create:
- `modules/module-NN-<slug>/level-NNN-<slug>/mission.yaml`
- `modules/module-NN-<slug>/level-NNN-<slug>/setup.sh`
- `modules/module-NN-<slug>/level-NNN-<slug>/solution.sh`

Use CURRICULUM.md for the full level list.
Use SAMPLE_LEVELS.md for format reference.
Use LEVEL_FORMAT.md for the mission.yaml schema and all validator types.

## Phase 6: Registry

16. Run `python3 scripts/generate_registry.py` to produce `levels.json`

## Phase 7: Validation

17. Run `python3 scripts/build_levels.py` — must report all levels valid

---

## Critical Rules for the AI Implementing This

### Sandbox paths
- Always: `/tmp/gitmissions/<module-slug>/<level-slug>/`
- Print this path prominently after setup. Player MUST cd here.
- Use `git -C <sandbox>` for all git commands in validators.

### setup.sh rules
- First line: `#!/usr/bin/env bash`
- Second line: `set -e`
- Third line: `SANDBOX="$1"` then `cd "$SANDBOX"`
- Always set `git config user.email` and `git config user.name` inside the repo
- For levels that need remote operations: use `git clone --local` or create a bare repo in the same sandbox dir
- Never rely on the player's global git config

### Remote operation levels (Module 4)
Since there's no real remote server, simulate remotes using local paths:
```bash
# Create a "remote" bare repo in the sandbox
mkdir -p "$SANDBOX/remote.git"
git init --bare "$SANDBOX/remote.git"

# Create the local "clone"
git clone "$SANDBOX/remote.git" "$SANDBOX/local"
cd "$SANDBOX/local"
git config user.email "player@gitmissions.local"
git config user.name "Player"
```
Tell the player in the mission briefing to work in `<sandbox>/local/`.

### Conflict setups
To leave a repo in mid-merge conflict state:
```bash
git merge some-branch --no-edit || true
```
The `|| true` prevents set -e from killing the script when merge fails.

### Hook levels
For server-side hook levels (pre-receive, update): simulate with a local bare repo
that has hooks installed. The player pushes to it and the hook fires.

### XP values
Use the ranges from CURRICULUM.md. Beginner: 100-150. Intermediate: 200-280.
Advanced: 300-400. Expert: 500-800.

### Difficulty badges in UI
- beginner: bold green `[BEGINNER]`
- intermediate: bold yellow `[INTERMEDIATE]`
- advanced: bold red `[ADVANCED]`
- expert: bold magenta `[EXPERT]`

### Missing features vs k8smissions
GitMissions does NOT need:
- `check-dry` (no cluster to dry-run against)
- RBAC safety guards (no cluster)
- kind cluster setup

GitMissions DOES add:
- Watch mode checking git repo state (not cluster state)
- Sandbox path display after every reset
- `git -C <path>` pattern in all validators

### The watch mode display line
```
● GitMissions  [auto] last check: ✓ PASS  14:23:05
```
vs
```
● GitMissions  [auto] last check: ✗ FAIL  14:23:05
```
Green for pass, red for fail. Overwrite the same line each tick using `\r`.

### Error messages
When a validator fails, show the validator's `description` field as the failure reason.
Example:
```
  ✗  Working tree is not clean — there are staged or unstaged changes
     → Hint: run 'git status' to see what's uncommitted
```

---

## Testing Each Level After Creation

After creating each level, mentally verify:
1. Does `setup.sh` create a reproducible state?
2. Does `solution.sh` actually pass all validators?
3. Are validators specific enough to reject wrong solutions?
4. Are hints in increasing specificity order?
5. Is the debrief educational (not just repeating the guide)?
6. Is the XP appropriate for the difficulty?

---

## Module Directory Names (exact)

```
module-01-foundations
module-02-branching-basics
module-03-merge-conflicts
module-04-remote-operations
module-05-detached-head
module-06-rebase
module-07-stash
module-08-history-reflog
module-09-reset-revert
module-10-tags-releases
module-11-git-hooks
module-12-advanced-git
module-13-git-internals
module-14-war-games
```
