# Writing GitMissions Levels

Every level lives in `modules/<module>/<level>/` and is made of three hand-written files.
There is no generator: these files are the source of truth. After changing levels, run:

```bash
.venv/bin/python scripts/build_levels.py --module module-03   # or --level level-042, or no filter
.venv/bin/python scripts/generate_registry.py                 # refresh levels.json
```

`build_levels.py` checks, for each level:

1. `mission.yaml` has every required key, and its `module`/`level` match the folder names.
2. `setup.sh` runs.
3. The validators **fail** right after setup. A level must not be solved before the player starts.
4. `solution.sh` runs without needing input, and afterwards **every validator passes**.
5. No two levels anywhere are near-duplicates. Their setup, solution and validators are compared, and a pair that is 85% or more similar fails the build.

## The golden rule: every level is its own mission

No two levels may share a scenario. Each level gets:

- **Its own small, realistic project**, for example a bakery's order API, a Kubernetes manifest repo, a
  thesis written in LaTeX, a game's level config, a payroll script, or a static blog. Use different file names
  and contents each time. Don't reuse `app.txt` or `README.md` with "base" in them.
- **Its own story.** Describe who you are, what went wrong, and why it matters. Example: "The release
  manager tagged the wrong commit as v2.3.0 and CI already published it…"
- **Its own end state and its own check.** Two levels about the same command must still
  differ in situation, starting state and what the validators check.

Within a module, levels must get harder as the module goes on. Late levels in a module combine the
module's concepts with earlier modules.

## mission.yaml

Keep `name`, `module`, `level`, `order`, `xp` and `difficulty` as they are, since `levels.json` and players'
progress depend on them. Rewrite everything else.

```yaml
name: Stage Specific Files            # unchanged
module: module-01-foundations         # unchanged
level: level-004-stage-specific-files # unchanged
order: 4                              # unchanged
difficulty: beginner                  # unchanged: beginner | intermediate | advanced | expert
xp: 100                               # unchanged
expected_time: 6m                     # realistic estimate
concepts:                             # 1-4 short items shown in the briefing
  - git add <path>
  - partial staging
repo_path: shop                       # optional: subfolder of the sandbox where the player works
description: |                        # SITUATION: the story, 2-5 concrete sentences
  ...
objective: |                          # OBJECTIVE: the exact required end state.
  ...                                 # Name every branch, file, tag and commit message that is checked.
hints:                                # 3 progressive hints: what to look at, then which command family, then nearly the exact command
  - ...
guide: |                              # Markdown walkthrough: each step's command AND why. About 15-40 lines.
  ...
debrief: |                            # Markdown: what happened, why it works, real-world use,
  ...                                 # related commands/flags, pitfalls. About 15-40 lines.
common_mistakes:                      # 2-4 mistakes specific to THIS level (no boilerplate)
  - ...
validators:
  - type: is_on_branch
    branch: main
    description: HEAD is on main      # shown to the player as a ✓/✗ line
```

Guide and debrief are shown as Markdown, 22 lines per page. Use headings, short paragraphs and
fenced `bash` blocks.

## setup.sh

`setup.sh` receives the sandbox directory as `$1` and runs inside it. Start every setup with:

```bash
#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
```

- Setup runs with the player's global git config **disabled**. Set any config the level relies on
  locally in the repo.
- The **player** runs commands with their own global config. So do not rely on global defaults.
  Set `pull.rebase`, `core.hooksPath .git/hooks` (hook levels), `merge.conflictStyle`, etc. locally when the
  level depends on them, or have the objective say which flag to use.
- Use other authors and dates to make history realistic:
  `GIT_AUTHOR_NAME=Dana GIT_AUTHOR_EMAIL=dana@shop.dev GIT_AUTHOR_DATE="2025-03-04T10:15:00" GIT_COMMITTER_DATE="2025-03-04T10:15:00" git commit -q -m "..."`.
- Remotes are local bare repos. If the player's repo is not the sandbox root, put them **outside** the
  player's working tree, e.g. `sandbox/origin.git` + `sandbox/shop` with `repo_path: shop`.
  Otherwise they show up as untracked files.
- Do not use the network, `date`, `$RANDOM` or anything else that changes between runs. The script must work on both macOS (BSD) and
  Linux (GNU): use `printf`, not `echo -e`, and `sed -i.bak` (then delete the .bak), not bare `sed -i`.
- Use `-q` on noisy git commands. Setup must finish in a few seconds.
- A setup may leave the repo mid-operation, for example in a merge conflict, a stopped rebase or a detached HEAD.
  Use `|| true` where a command is expected to fail.

## solution.sh

`solution.sh` runs in `repo_path` with `set -e`, and players see it as the reference solution. Write what
an experienced engineer would type. Short comments are welcome.

- It must never open an editor or wait for input. Use `-m`, `--no-edit`, `GIT_EDITOR=true`, and for
  interactive rebase `GIT_SEQUENCE_EDITOR="sed -i.bak -e '2s/^pick/fixup/'" git rebase -i HEAD~3`.
- When the answer depends on the repo (a SHA, an author, a count), compute it with git in the
  solution, e.g. `git log --format=%an -1 -- prices.csv > answer.txt`. This also teaches the command.

## Validators

The validators run in `repo_path`. Use the most specific built-in type, and `script_passes` for anything else.

| type | keys | passes when |
|---|---|---|
| `branch_exists` / `branch_not_exists` | `branch` | local branch exists / does not exist |
| `is_on_branch` | `branch`, opt `alt_branches` | HEAD is attached to that branch |
| `is_detached` | | HEAD is detached |
| `commit_message_contains` / `commit_message_equals` | `text`, opt `ref` (default HEAD) | message of that commit |
| `commit_count_eq` / `commit_count_gte` | `count`, opt `branch` | `git rev-list --count <branch>` |
| `merge_commit_exists` / `no_merge_commit` | opt `branch` | merges reachable from branch |
| `file_exists` / `file_not_exists` | `path` | in the working tree |
| `file_content_equals` / `file_content_contains` | `path`, `text` | working-tree content (equals ignores surrounding whitespace) |
| `file_tracked` / `file_not_tracked` | `path` | in the index |
| `file_ignored` | `path` | matched by ignore rules |
| `is_clean` | opt `ignore_untracked: true` | `git status --porcelain` is empty |
| `no_conflict_markers` | | no tracked file has a line that is a conflict marker |
| `no_unmerged_files` | | `git ls-files --unmerged` is empty |
| `tag_exists` / `tag_not_exists` / `tag_is_annotated` | `tag` | |
| `remote_exists` | `name` | |
| `ahead_of` | `other`, `count`, opt `branch`, opt `behind` | branch is ≥count ahead of other (and exactly `behind` behind) |
| `is_ancestor` | `ancestor`, opt `descendant` | `git merge-base --is-ancestor` |
| `refs_equal` | `left`, `right` | both resolve to the same commit |
| `config_equals` | `key`, `value` | local repo config |
| `stash_empty` / `stash_not_empty` / `stash_count_eq` | `count` | |
| `reflog_contains` | `text` | `git reflog --all` |
| `hook_exists` | `name` | executable hook in the repo's hooks dir |
| `hook_output_contains` | `name`, `text`, opt `args`, `stdin`, `expect_exit` | runs the hook directly |
| `submodule_exists` | `path` | listed in `.gitmodules` |
| `worktree_count` | `count` | `git worktree list` |
| `script_passes` | `script` | bash snippet (with `set -e`) exits 0 |

Rules for good validators:

- **Check the real outcome, not a token.** Don't hand the player a string in the mission
  text and then only check that the string was written somewhere. For investigation levels (log, blame,
  bisect, cat-file, reflog…) the setup hides the answer in history, and the validator computes the expected
  answer itself with git inside `script_passes`, e.g.
  `test "$(cat culprit.txt)" = "$(git log --format=%h -1 --grep='rounding')"`.
- Make answers impossible to guess. Use real SHAs, author names among several authors, or counts that
  are not obvious.
- Guard against shortcuts. If the lesson is "revert, don't reset", check that the original commit is
  still an ancestor *and* that a revert commit exists. If the lesson is "keep both changes", check both.
- Give every validator a clear `description`; it is the player's checklist.
- Each validator command has a 30s timeout.

## How the player plays

The game prompt runs each command with `bash -c` in the current directory. `cd` is handled by the game.
Heredocs work. `export` and aliases do **not** carry over to the next command. Editors such as vim or nano work,
so interactive rebase and plain `git commit` are fine for players, but `solution.sh` must stay non-interactive.
