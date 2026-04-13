# GitMissions ⚔️🌿

![platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-blue)
![shell](https://img.shields.io/badge/shell-bash-brightgreen)
![focus](https://img.shields.io/badge/learning-git-orange)

> **Learn Git by breaking it — then fixing it.**

GitMissions is a fully local, game-based Git training platform with a rich terminal interface.
Each mission drops you into a deliberately broken or challenging Git repository.
Your job: diagnose and fix it using real `git` commands.

**225 progressive challenges across 14 modules — beginner to expert.**
No cloud. No accounts. No external services required.

**Design by: Jalil Abdollahi**
Email: `jalil.abdollahi@gmail.com`

---

## Features

- **225 missions** across 14 modules — from first commits to production incident war games
- **Rich terminal UI** matching k8smissions (colors, panels, banners, XP bars)
- **XP & progression system** — earn points, unlock modules, track your journey
- **Progressive hints** — unlock gradually, only when you need them
- **Post-mission debriefs** — learn *why* your fix worked with real-world examples
- **Time tracking** — see how long each mission takes vs estimated time
- **Watch mode** — auto-validates your repo every 3 seconds
- **Module certificates** — earn a rich terminal certificate for each module
- **Sandboxed repos** — every level gets a clean `/tmp/gitmissions/<level>/` repo
- **Auto-save** — progress saved after every completed mission
- **Shell completion** — tab-complete all commands in bash and zsh

---

## Quick Start

```bash
cd /path/to/gitmissions
./install.sh
./play.sh
```

`./install.sh` creates a local `.venv` and installs dependencies there, so it works on systems that block global `pip` installs.

---

## Prerequisites

| Tool | Notes |
|------|-------|
| git 2.23+ | Required |
| Python 3.9+ | For the engine |
| pip | For dependencies |

---

## How to Play

1. Run `./play.sh` — the game loop runs here
2. The engine sets up a sandboxed git repo in `/tmp/gitmissions/<level>/`
3. **Open a second terminal** — navigate to that repo and use `git` to fix it
4. Run `check` (or press `1`) in the game to validate
5. Earn XP and move on

Important: the `GitMissions >` prompt is not a shell. Commands like `ls`, `cd`, `pwd`, and `git status` should be run in the second terminal after you `cd` into the sandbox path shown by the game.

---

## Commands

| Command | Shortcut | Description |
|---------|----------|-------------|
| `check` | `1` | Validate your solution |
| `watch` | `w` | Auto-validate every 3 seconds |
| `hint` | `2` | Reveal the next progressive hint |
| `solution` | `3` | Show the reference solution |
| `guide` | `4` | Step-by-step walkthrough for the current level |
| `debrief` | `5` | Post-mission learning debrief |
| `reset` | `6` | Reset this level to broken state |
| `skip` | `7` | Skip level (no XP awarded) |
| `status` | `8` | Show current progress and XP |
| `help` | `9` | Show all commands |
| `handbook` | `g` | Open the full `GIT_GUIDE.md` handbook |
| `quit` | `q` | Save and exit |

---

## Learning Path — 14 Modules · 225 Levels

| # | Module | Levels | Difficulty | Key Topics |
|---|--------|--------|------------|------------|
| 1 | Git Foundations | 20 | Beginner | init, add, commit, log, diff, .gitignore |
| 2 | Branching Basics | 15 | Beginner | branch, switch, fast-forward merge |
| 3 | Merge Conflicts | 20 | Intermediate | conflict markers, strategies, resolution |
| 4 | Remote Operations | 15 | Intermediate | clone, fetch, pull, push, diverged history |
| 5 | Detached HEAD | 15 | Intermediate | detached state, recovery, branch from commit |
| 6 | Rebase | 20 | Int/Advanced | rebase, interactive rebase, rebase conflicts |
| 7 | Stash | 10 | Intermediate | stash, pop, apply, stash branch |
| 8 | History & Reflog | 15 | Advanced | log, reflog, recovering lost commits |
| 9 | Reset & Revert | 15 | Advanced | soft/mixed/hard reset, revert, cherry-pick |
| 10 | Tags & Releases | 10 | Intermediate | lightweight/annotated tags, push, delete |
| 11 | Git Hooks | 20 | Advanced | pre-commit, commit-msg, pre-push, debugging |
| 12 | Advanced Git | 15 | Expert | bisect, worktree, submodules, cherry-pick |
| 13 | Git Internals | 15 | Expert | objects, cat-file, refs, pack files |
| 14 | War Games | 20 | Expert | multi-failure incidents, disaster recovery |

---

## Project Structure

```
gitmissions/
├── play.sh                     ← Launch the game
├── install.sh                  ← One-time setup
├── requirements.txt            ← Python dependencies
├── progress.json               ← Auto-saved player progress
├── levels.json                 ← Built level registry
├── GIT_GUIDE.md                ← General Git handbook for beginners
├── engine/
│   ├── engine.py               ← Core game loop
│   ├── ui.py                   ← Rich terminal UI (matches k8smissions style)
│   ├── certificate.py          ← Module completion certificates
│   ├── player.py               ← Player state helpers
│   ├── reset.py                ← Level reset + sandbox setup
│   └── validator.py            ← Git repo validation helpers
├── scripts/
│   ├── build_levels.py         ← Build/verify all level files
│   └── generate_registry.py   ← Regenerate levels.json
├── completion/
│   ├── _gitmissions            ← zsh completion
│   └── gitmissions.bash        ← bash completion
└── modules/
    ├── module-01-foundations/
    │   └── level-001-*/
    │       ├── mission.yaml    ← Briefing, hints, debrief, validator config
    │       ├── setup.sh        ← Creates the broken/challenge repo state
    │       └── solution.sh     ← Reference solution commands
    └── ... (modules 02–14)
```

---

## License

MIT License.
