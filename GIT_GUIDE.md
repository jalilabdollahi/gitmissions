# Git Guide

This guide is the beginner-friendly handbook for GitMissions.

It is here to answer the questions that early Git levels naturally raise:

- What is Git actually tracking?
- What is the difference between untracked, unstaged, and staged?
- What happens when I commit?
- When should I branch, merge, rebase, stash, reset, or revert?
- How do I recover when something seems lost?

You do not need to memorize everything at once. Come back to this guide whenever a mission teaches a new Git idea.

## What Git Is

Git is a version control system.

At a high level, Git lets you:

- track changes to files over time
- save snapshots called commits
- create branches for different lines of work
- combine work from different branches
- inspect old states
- recover from many mistakes

Git does not just "save files". It records a history of snapshots and the relationships between those snapshots.

## The 3 Main Areas in Git

Many beginner Git problems make more sense once you know Git has three important places:

1. Working tree
   This is what you see in your folder right now.

2. Staging area
   This is the "next commit draft". Files added here will go into the next commit.

3. Repository history
   This is the saved commit history inside `.git/`.

This is why `git status` is such an important command. It tells you what is in each state.

## The Core Everyday Workflow

The most common Git loop is:

```bash
git status
git add <files>
git commit -m "meaningful message"
```

What each step does:

- `git status`
  Shows what changed and what state those changes are in.

- `git add <files>`
  Moves selected changes into the staging area.

- `git commit -m "..."`
  Saves the staged snapshot into history.

If you remember only one Git rhythm at first, remember that one.

## `git status`: The Most Important Beginner Command

`git status` tells you:

- which files are untracked
- which tracked files changed but are not staged
- which changes are already staged
- which branch you are on
- whether a merge, rebase, or cherry-pick is in progress

Typical states:

- `untracked`
  Git sees a new file, but it is not being tracked yet.

- `modified`
  A tracked file changed in the working tree.

- `changes to be committed`
  The file is staged.

If a level feels confusing, `git status` is almost always the first place to look.

## Untracked vs Unstaged vs Staged

These three states are easy to confuse at first.

### Untracked

A brand-new file exists, but Git is not tracking it yet.

Example:

```bash
echo "hello" > notes.txt
git status
```

Git will show `notes.txt` as untracked.

To include it in the next commit:

```bash
git add notes.txt
```

### Unstaged

A tracked file was edited, but the updated version is not staged yet.

Example:

```bash
echo "more text" >> README.md
git status
```

To stage it:

```bash
git add README.md
```

### Staged

The change is ready to be included in the next commit.

Then commit it:

```bash
git commit -m "Update README"
```

## Creating a Repository

To start Git in a folder:

```bash
git init
```

This creates a hidden `.git/` directory that stores the repository metadata and history.

After that, the directory becomes a Git repository.

## Making Your First Commit

Example:

```bash
git init
git add .
git commit -m "Initial commit"
```

This does three things:

- starts the repo
- stages the current files
- saves the first snapshot

## Looking at History

Useful commands:

```bash
git log
git log --oneline
git show <commit>
git diff
git diff --staged
```

What they do:

- `git log`
  Shows commit history.

- `git log --oneline`
  Shows a shorter, easier-to-read history.

- `git show <commit>`
  Shows one commit and its changes.

- `git diff`
  Shows unstaged changes.

- `git diff --staged`
  Shows staged changes.

## Commit Messages

A good commit message explains what changed and why.

Simple example:

```bash
git commit -m "Add login validation"
```

When needed, use a subject and body:

```bash
git commit -m "Fix config loading" -m "Use the environment variable before falling back to the default file."
```

Good commit messages help future-you and teammates understand history quickly.

## Ignoring Files

Git should not track everything.

Typical things to ignore:

- build output
- logs
- temporary files
- secrets
- editor files

Use `.gitignore`:

```gitignore
*.log
build/
.env
__pycache__/
```

If a file is already tracked, adding it to `.gitignore` is not enough by itself. You usually also need:

```bash
git rm --cached <file>
```

That removes it from Git tracking while keeping the local file.

## Branches

Branches let you work on different ideas without disturbing `main`.

Useful commands:

```bash
git branch
git switch -c feature/login
git switch main
git branch -d feature/login
```

What they mean:

- `git branch`
  List local branches.

- `git switch -c feature/login`
  Create and switch to a new branch.

- `git switch main`
  Move back to `main`.

- `git branch -d feature/login`
  Delete a merged branch.

Think of a branch as a movable label pointing at a commit.

## Merging

When work on a branch is ready, you can merge it back:

```bash
git switch main
git merge feature/login
```

Possible outcomes:

- fast-forward merge
  `main` simply moves forward because nothing diverged.

- merge commit
  Git creates a new merge commit that joins two histories.

- merge conflict
  Git cannot decide how to combine changes automatically.

## Merge Conflicts

A merge conflict usually happens when two branches changed the same lines of the same file.

You may see markers like:

```text
<<<<<<< HEAD
current branch version
=======
incoming branch version
>>>>>>> feature/login
```

To resolve:

1. Open the file.
2. Decide the correct final content.
3. Remove the conflict markers.
4. Stage the file.
5. Complete the operation.

Example:

```bash
git add app.py
git commit
```

Or if you want to back out:

```bash
git merge --abort
```

## Remotes

Git can connect your local repo to another repo, often called a remote.

Common commands:

```bash
git remote -v
git fetch origin
git pull origin main
git push origin main
```

What they do:

- `git fetch`
  Downloads remote history but does not merge it into your current branch.

- `git pull`
  Usually means fetch plus merge or fetch plus rebase.

- `git push`
  Sends your local commits to the remote.

In GitMissions, remotes are often simulated with local bare repositories.

## Detached HEAD

HEAD usually points to your current branch.

If you checkout a specific commit or tag, HEAD can become detached:

```bash
git checkout <commit>
```

This is okay for exploration, but if you commit in detached HEAD and then switch away, that commit can become hard to find unless you save it.

To keep detached work:

```bash
git branch rescue-work
```

or

```bash
git switch -c rescue-work
```

## Rebase

Rebase rewrites commits so they appear on top of a different base commit.

Example:

```bash
git switch feature/login
git rebase main
```

Why people use it:

- to keep history linear
- to replay feature work on top of the latest `main`
- to clean up commit order before merging

Important caution:

- avoid rebasing commits that other people already depend on unless you understand the consequences

If rebase conflicts:

```bash
git status
git add <resolved-files>
git rebase --continue
```

Or cancel:

```bash
git rebase --abort
```

## Stash

Stash temporarily shelves work-in-progress changes.

Useful commands:

```bash
git stash
git stash push -m "WIP login"
git stash list
git stash pop
git stash apply
```

Use stash when:

- you need to switch tasks quickly
- your changes are not ready to commit
- you need a clean working tree for another operation

## Reflog: Git's Safety Net

If something seems lost, `git reflog` is one of the best commands to try.

```bash
git reflog
```

Reflog records where HEAD and branch refs recently pointed, even after resets, rebases, and accidental moves.

That means you can often recover "lost" commits if you can still find their hashes in the reflog.

## Reset vs Revert

These are easy to mix up.

### `git reset`

Moves the current branch pointer backward.

Examples:

```bash
git reset --soft HEAD~1
git reset HEAD~1
git reset --hard HEAD~1
```

- `--soft`
  Uncommit, but keep changes staged.

- default / mixed
  Uncommit and unstage changes, but keep the file edits.

- `--hard`
  Uncommit and discard the changes from the working tree too.

### `git revert`

Creates a new commit that undoes an older commit.

```bash
git revert <commit>
```

Use `revert` when history may already be shared. It is safer because it does not rewrite existing public history.

## Cherry-Pick

Cherry-pick copies a specific commit onto your current branch.

```bash
git cherry-pick <commit>
```

This is useful when:

- one fix from another branch should be applied here too
- you do not want to merge the whole branch

## Tags

Tags mark important points in history, often releases.

Examples:

```bash
git tag v1.0
git tag -a v1.1 -m "Release v1.1"
git show v1.0
```

Annotated tags store extra metadata. Lightweight tags are simpler references.

## Hooks

Git hooks are scripts Git can run automatically at certain moments.

Examples:

- `pre-commit`
- `commit-msg`
- `pre-push`

They live in:

```text
.git/hooks/
```

Hooks are often used to:

- run tests
- check formatting
- block bad commit messages
- enforce team workflow rules

## Recovery Checklist

If Git feels broken, try this sequence:

```bash
git status
git log --oneline --graph --all
git branch -a
git reflog
git stash list
```

Those commands answer most recovery questions:

- what state am I in?
- what branch am I on?
- is an operation in progress?
- where did HEAD used to be?
- did I stash something?

## Good Habits

- Run `git status` often.
- Make small, meaningful commits.
- Use branches for focused work.
- Read error messages carefully. Git often tells you the next command.
- Prefer safe undo commands first.
- Keep `main` stable.
- Learn what state the repo is in before trying random fixes.

## Common Beginner Mistakes

- Committing without checking what is staged
- Forgetting `git add` after editing files
- Using `git reset --hard` too quickly
- Rebasing when you really meant to merge
- Force pushing without understanding the consequences
- Ignoring `git status` output
- Panicking when a commit seems lost instead of checking `git reflog`

## A Simple Mental Model

If Git ever feels confusing, return to this model:

- files changed in your folder
- some changes may be staged
- a commit saves the staged snapshot
- branches point at commits
- most Git commands are really about moving between those states safely

That mental model is enough to understand a large part of Git.
