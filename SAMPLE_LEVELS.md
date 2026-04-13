# GitMissions — Sample Levels (Reference for AI Implementation)

These are 10 fully specified levels across different modules.
Use these as the template when generating all 225 levels.

---

## Level 001 — Init Your First Repo

**File**: `modules/module-01-foundations/level-001-init-your-first-repo/`

### mission.yaml
```yaml
name: "Init Your First Repo"
module: "module-01-foundations"
level: "level-001-init-your-first-repo"
order: 1
difficulty: "beginner"
xp: 100
expected_time: "3m"
concepts:
  - "git init"
  - ".git directory"
  - "repository"

description: |
  There's a folder called `project/` in your sandbox.
  It contains some files, but it's not a Git repository yet.
  No commits have been made. The team is waiting.

objective: |
  Initialize a Git repository in the `project/` directory,
  stage all files, and make an initial commit with the message "Initial commit".

hints:
  - "Navigate into the `project/` directory first."
  - "Use `git init` to create a new repository."
  - "Use `git add .` to stage all files."
  - "Use `git commit -m \"Initial commit\"` to make your first commit."

guide: |
  ## Step-by-step Guide

  1. Change into the project directory:
     ```bash
     cd project/
     ```

  2. Initialize the repository:
     ```bash
     git init
     ```
     This creates a `.git/` folder — the entire history lives here.

  3. Stage all files:
     ```bash
     git add .
     ```

  4. Make the first commit:
     ```bash
     git commit -m "Initial commit"
     ```

  5. Verify:
     ```bash
     git log --oneline
     ```

debrief: |
  ## What Just Happened

  `git init` created a hidden `.git/` directory in your project.
  This is where Git stores the entire history of your project —
  every commit, branch, tag, and configuration.

  **The staging area (index):** Before committing, Git requires
  you to explicitly stage changes with `git add`. This gives you
  precise control over what goes into each commit.

  **Interview question you can now answer:**
  "What does `git init` do?"

validators:
  - type: is_on_branch
    branch: "master"
    description: "Repository is on master/main branch"
    # Note: accept either 'master' or 'main' — check both

  - type: commit_count_gte
    branch: "HEAD"
    count: 1
    description: "At least one commit exists"

  - type: commit_message_contains
    text: "Initial commit"
    description: "Commit message is 'Initial commit'"

  - type: is_clean
    description: "Working tree is clean"
```

### setup.sh
```bash
#!/usr/bin/env bash
set -e
SANDBOX="$1"
mkdir -p "$SANDBOX/project"
cd "$SANDBOX/project"

# Create some files but NO git init
cat > README.md << 'EOF'
# My Project
A simple project.
EOF

cat > main.py << 'EOF'
def main():
    print("Hello, world!")

if __name__ == "__main__":
    main()
EOF

cat > .gitignore << 'EOF'
__pycache__/
*.pyc
EOF

# Intentionally do NOT run git init — that's the player's job
```

### solution.sh
```bash
#!/usr/bin/env bash
# Run these in /tmp/gitmissions/.../level-001-init-your-first-repo/project/

git init
git add .
git commit -m "Initial commit"
```

---

## Level 036 — Your First Conflict

**File**: `modules/module-03-merge-conflicts/level-036-first-conflict/`

### mission.yaml
```yaml
name: "Your First Conflict"
module: "module-03-merge-conflicts"
level: "level-036-first-conflict"
order: 36
difficulty: "intermediate"
xp: 200
expected_time: "8m"
concepts:
  - "merge conflict"
  - "conflict markers"
  - "<<<<<<< HEAD"
  - "git add"
  - "git commit"

description: |
  You have two branches: `main` and `feature/greeting`.
  Both branches modified the same line in `hello.py`.
  When you try to merge, Git stops and says there's a conflict.

objective: |
  The repository is already in a mid-merge conflicted state.
  Resolve the conflict in `hello.py` by keeping the `feature/greeting`
  version of the message, then complete the merge.

hints:
  - "Run `git status` — you'll see `both modified: hello.py`."
  - "Open `hello.py` and find the `<<<<<<<`, `=======`, `>>>>>>>` markers."
  - "The `<<<<<<< HEAD` section is main's version. The `>>>>>>> feature/greeting` section is the incoming version. Keep the feature version."
  - "Delete the three marker lines and keep only the feature/greeting code."
  - "Run `git add hello.py` then `git commit` to finish the merge."

guide: |
  ## Step-by-step Guide

  1. Check what's in conflict:
     ```bash
     git status
     ```

  2. Open `hello.py`. It looks like this:
     ```python
     <<<<<<< HEAD
     message = "Hello, World!"
     =======
     message = "Hello, GitMissions!"
     >>>>>>> feature/greeting
     ```

  3. Keep the feature/greeting version. Edit the file to:
     ```python
     message = "Hello, GitMissions!"
     ```
     (Delete the three marker lines.)

  4. Mark resolved and commit:
     ```bash
     git add hello.py
     git commit
     ```
     (Accept the default merge commit message.)

debrief: |
  ## What Just Happened

  A merge conflict occurs when two branches modify the **same lines**
  of the same file. Git marks the conflict in the file and pauses,
  waiting for you to decide which version to keep.

  **Reading the markers:**
  - `<<<<<<< HEAD` — start of your current branch's version
  - `=======` — divider
  - `>>>>>>> branch-name` — end of the incoming branch's version

  Everything between `<<<<<<<` and `=======` is YOUR version.
  Everything between `=======` and `>>>>>>>` is THEIRS.

  You can keep one side, the other, or manually combine both.
  After editing, you MUST `git add` the file to mark it as resolved.

  **Real-world tip:** Most teams use VS Code or IntelliJ for visual
  merge resolution. The underlying principle is identical.

validators:
  - type: no_conflict_markers
    description: "No conflict markers remain in hello.py"

  - type: is_clean
    description: "Working tree is clean (merge committed)"

  - type: is_on_branch
    branch: "main"
    description: "HEAD is on main branch"

  - type: file_content_contains
    path: "hello.py"
    text: "Hello, GitMissions!"
    description: "hello.py contains the feature/greeting version"
```

### setup.sh
```bash
#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"

git init
git config user.email "player@gitmissions.local"
git config user.name "Player"

# Initial commit on main
cat > hello.py << 'EOF'
message = "Hello, World!"
print(message)
EOF
git add hello.py
git commit -m "Initial greeting"

# Feature branch changes the message
git checkout -b feature/greeting
cat > hello.py << 'EOF'
message = "Hello, GitMissions!"
print(message)
EOF
git add hello.py
git commit -m "feat: update greeting for GitMissions"

# Back to main, make a conflicting change to the same line
git checkout main
cat > hello.py << 'EOF'
message = "Hello, World! (updated)"
print(message)
EOF
git add hello.py
git commit -m "Update greeting on main"

# Start the merge — it will conflict and stop
git merge feature/greeting --no-edit || true
# Repo is now in conflicted state
```

### solution.sh
```bash
#!/usr/bin/env bash
# Reference solution

cat > hello.py << 'EOF'
message = "Hello, GitMissions!"
print(message)
EOF

git add hello.py
git commit --no-edit
```

---

## Level 071 — What Is Detached HEAD?

**File**: `modules/module-05-detached-head/level-071-what-is-detached-head/`

### mission.yaml
```yaml
name: "What Is Detached HEAD?"
module: "module-05-detached-head"
level: "level-071-what-is-detached-head"
order: 71
difficulty: "intermediate"
xp: 220
expected_time: "5m"
concepts:
  - "detached HEAD"
  - "git checkout <hash>"
  - "HEAD points to commit"

description: |
  The repository has 3 commits on main. Someone ran
  `git checkout <old-hash>` and then left. Now HEAD is detached
  and pointing to the first commit, not to any branch.

objective: |
  You are currently in detached HEAD state.
  Return to the `main` branch without losing any commits.

hints:
  - "Run `git status` — you'll see 'HEAD detached at <hash>'."
  - "Run `git branch` to see that main still exists."
  - "Use `git switch main` or `git checkout main` to reattach HEAD."

guide: |
  ## Step-by-step Guide

  1. Verify the detached state:
     ```bash
     git status
     ```
     Output: `HEAD detached at a1b2c3`

  2. See available branches:
     ```bash
     git branch
     ```

  3. Return to main:
     ```bash
     git switch main
     ```

  4. Verify:
     ```bash
     git status
     ```
     Output: `On branch main`

debrief: |
  ## What Is Detached HEAD?

  Normally HEAD points to a branch name (like `main`), and that branch
  points to a commit. When you `git checkout <commit-hash>` directly,
  HEAD points to the commit itself instead of a branch. This is "detached HEAD."

  **Why it's dangerous:** Any commits you make in detached HEAD state are
  NOT attached to any branch. If you switch away without saving them to a
  branch, Git will eventually garbage-collect them and they'll be gone.

  **How to escape:** `git switch <branch-name>` or `git checkout <branch-name>`.

  **How to save detached work:** `git switch -c new-branch-name` creates a
  branch at the current detached HEAD position.

validators:
  - type: is_on_branch
    branch: "main"
    description: "HEAD is attached to main branch"

  - type: is_clean
    description: "Working tree is clean"
```

### setup.sh
```bash
#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"

git init
git config user.email "player@gitmissions.local"
git config user.name "Player"

echo "version 1" > app.py
git add app.py
git commit -m "Initial commit"

FIRST_HASH=$(git rev-parse HEAD)

echo "version 2" > app.py
git add app.py
git commit -m "Second commit"

echo "version 3" > app.py
git add app.py
git commit -m "Third commit"

# Detach HEAD at the first commit
git checkout "$FIRST_HASH" --quiet
```

### solution.sh
```bash
#!/usr/bin/env bash
git switch main
```

---

## Level 086 — What Is Rebase?

**File**: `modules/module-06-rebase/level-086-what-is-rebase/`

### mission.yaml
```yaml
name: "What Is Rebase?"
module: "module-06-rebase"
level: "level-086-what-is-rebase"
order: 86
difficulty: "intermediate"
xp: 250
expected_time: "8m"
concepts:
  - "git rebase"
  - "linear history"
  - "rebase vs merge"

description: |
  You have a `feature/add-logging` branch that forked off `main`
  3 commits ago. Since then, `main` has received 2 new commits.
  Your feature branch is now out of date.

  Your team prefers a **linear history** — no merge commits.

objective: |
  Rebase `feature/add-logging` onto the current tip of `main`,
  then verify the history is linear.

hints:
  - "Make sure you are on the feature branch first: `git switch feature/add-logging`."
  - "Run `git rebase main` to replay your commits on top of main's tip."
  - "Check the result with `git log --oneline --graph`."

guide: |
  ## Step-by-step Guide

  1. Switch to the feature branch:
     ```bash
     git switch feature/add-logging
     ```

  2. Rebase onto main:
     ```bash
     git rebase main
     ```
     Git replays your commits on top of main's latest commit.

  3. Verify the linear history:
     ```bash
     git log --oneline --graph
     ```
     You should see a straight line — no merge commit.

debrief: |
  ## What Is Rebase?

  `git rebase` takes the commits from your branch and **replays** them
  on top of a different base commit. The result is a linear history —
  as if your branch was created from the latest main, not the old one.

  **Rebase vs Merge:**
  - `git merge` creates a new "merge commit" that joins two histories
  - `git rebase` rewrites history to appear linear

  **When to use rebase:**
  - Before merging a feature branch (to apply on latest main)
  - Cleaning up local commits before sharing
  - When your team enforces a linear history policy

  **Golden Rule:** Never rebase commits that have already been pushed
  to a shared branch. Rewriting shared history causes problems for
  everyone who has pulled those commits.

validators:
  - type: is_on_branch
    branch: "feature/add-logging"
    description: "Still on feature/add-logging branch"

  - type: no_merge_commit
    branch: "feature/add-logging"
    description: "History is linear (no merge commits)"

  - type: commit_count_gte
    branch: "feature/add-logging"
    count: 4
    description: "Feature branch has at least 4 commits total"
```

### setup.sh
```bash
#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"

git init
git config user.email "player@gitmissions.local"
git config user.name "Player"

# Initial commit
echo "app v1" > app.py
git add app.py
git commit -m "Initial commit"

# Create feature branch
git checkout -b feature/add-logging
echo "import logging" >> app.py
git add app.py
git commit -m "feat: add logging import"

echo "logging.basicConfig(level=logging.INFO)" >> app.py
git add app.py
git commit -m "feat: configure logging"

# Back to main — add 2 commits that the feature doesn't have
git checkout main
echo "# version 2" >> app.py
git add app.py
git commit -m "chore: bump version"

echo "# stable release" >> app.py
git add app.py
git commit -m "chore: mark stable"

# Leave player on the feature branch
git checkout feature/add-logging
```

### solution.sh
```bash
#!/usr/bin/env bash
git rebase main
```

---

## Level 122 — Recover After Hard Reset

**File**: `modules/module-08-history-reflog/level-122-reflog-after-reset/`

### mission.yaml
```yaml
name: "Recover After Hard Reset"
module: "module-08-history-reflog"
level: "level-122-reflog-after-reset"
order: 122
difficulty: "advanced"
xp: 350
expected_time: "12m"
concepts:
  - "git reflog"
  - "git reset --hard"
  - "recovering lost commits"
  - "ORIG_HEAD"

description: |
  A panicked developer ran `git reset --hard HEAD~3` on main.
  Three commits are now unreachable from any branch.
  The commits contained critical work that must be recovered.

objective: |
  Use `git reflog` to find the lost commits and restore `main`
  to the state it was in before the accidental reset.

hints:
  - "Run `git reflog` to see all recent HEAD movements."
  - "Look for the entry just before the reset — it shows the hash of the old HEAD."
  - "Use `git reset --hard <hash>` with the old HEAD hash to restore."
  - "Alternatively, check `ORIG_HEAD` — Git saves the pre-reset position there."

guide: |
  ## Step-by-step Guide

  1. View the reflog:
     ```bash
     git reflog
     ```
     You'll see entries like:
     ```
     a1b2c3 HEAD@{0}: reset: moving to HEAD~3
     d4e5f6 HEAD@{1}: commit: feat: add payment module
     ...
     ```

  2. Find the hash before the reset (HEAD@{1} or further back).

  3. Reset to that hash:
     ```bash
     git reset --hard HEAD@{1}
     ```
     Or:
     ```bash
     git reset --hard d4e5f6
     ```

  4. Verify:
     ```bash
     git log --oneline
     ```
     The three commits should be back.

debrief: |
  ## Git Reflog: The Real Safety Net

  `git reflog` records every time HEAD moves — commits, resets, checkouts,
  rebases, merges. It's local-only (not pushed) and expires after 90 days
  by default.

  **When `git reset --hard` destroys commits:**
  The commits aren't immediately deleted — they become "unreachable" (no branch
  points to them). Reflog still references them. You have a window to recover.

  **ORIG_HEAD:** Git also saves the pre-reset position to `.git/ORIG_HEAD`.
  `git reset --hard ORIG_HEAD` is a one-liner recovery for the most recent
  destructive operation.

  **Interview question you can now answer:**
  "How would you recover commits after an accidental `git reset --hard`?"

validators:
  - type: commit_count_gte
    branch: "main"
    count: 6
    description: "main has at least 6 commits (3 restored)"

  - type: is_on_branch
    branch: "main"
    description: "HEAD is on main"

  - type: commit_message_contains
    text: "feat: add payment module"
    description: "The lost commit 'feat: add payment module' is restored"
```

### setup.sh
```bash
#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"

git init
git config user.email "player@gitmissions.local"
git config user.name "Player"

# Build a history
echo "v1" > app.py; git add app.py; git commit -m "Initial commit"
echo "v2" > app.py; git add app.py; git commit -m "feat: user authentication"
echo "v3" > app.py; git add app.py; git commit -m "feat: dashboard"
echo "v4" > app.py; git add app.py; git commit -m "feat: add payment module"
echo "v5" > app.py; git add app.py; git commit -m "feat: email notifications"
echo "v6" > app.py; git add app.py; git commit -m "feat: export to CSV"

# Simulate accidental reset
git reset --hard HEAD~3

# Now HEAD points to "feat: dashboard" and 3 commits are unreachable
```

### solution.sh
```bash
#!/usr/bin/env bash
# Find the lost hash and reset to it
git reset --hard ORIG_HEAD
# Or equivalently:
# git reset --hard HEAD@{1}
```

---

## Level 156 — What Are Git Hooks?

**File**: `modules/module-11-git-hooks/level-156-hooks-intro/`

### mission.yaml
```yaml
name: "What Are Git Hooks?"
module: "module-11-git-hooks"
level: "level-156-hooks-intro"
order: 156
difficulty: "advanced"
xp: 300
expected_time: "8m"
concepts:
  - "git hooks"
  - ".git/hooks/"
  - "pre-commit"
  - "executable scripts"

description: |
  The repo has a `.git/hooks/pre-commit.sample` file.
  Your task is to activate a pre-commit hook that prints
  "Running pre-commit checks..." before every commit.

objective: |
  Create an executable `pre-commit` hook in `.git/hooks/`
  that prints "Running pre-commit checks..." when invoked,
  then make a commit to verify it runs.

hints:
  - "Hook files live in `.git/hooks/` and must be executable."
  - "Copy or create `.git/hooks/pre-commit` (no .sample extension)."
  - "The file must start with `#!/usr/bin/env bash` and be executable (`chmod +x`)."
  - "After creating the hook, make a commit — you'll see the hook output."

guide: |
  ## Step-by-step Guide

  1. Create the hook file:
     ```bash
     cat > .git/hooks/pre-commit << 'EOF'
     #!/usr/bin/env bash
     echo "Running pre-commit checks..."
     exit 0
     EOF
     ```

  2. Make it executable:
     ```bash
     chmod +x .git/hooks/pre-commit
     ```

  3. Test it by making a commit:
     ```bash
     echo "test" >> README.md
     git add README.md
     git commit -m "test: verify hook runs"
     ```
     You should see "Running pre-commit checks..." in the output.

debrief: |
  ## Git Hooks

  Git hooks are scripts that Git executes at specific points in the
  workflow. They live in `.git/hooks/` and must be executable.

  **Common hooks:**
  - `pre-commit` — runs before a commit is created (linting, tests)
  - `commit-msg` — validates the commit message format
  - `pre-push` — runs before a push (integration tests)
  - `post-commit` — runs after a commit (notifications)

  **Important:** Hooks in `.git/hooks/` are NOT committed to the repo.
  To share hooks with your team, use `git config core.hooksPath hooks/`
  pointing to a committed directory.

  **Exit codes matter:** If a hook exits with non-zero, the operation
  is aborted. Exit 0 to allow it to proceed.

validators:
  - type: hook_exists
    hook: "pre-commit"
    description: ".git/hooks/pre-commit exists and is executable"
```

### setup.sh
```bash
#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"

git init
git config user.email "player@gitmissions.local"
git config user.name "Player"

echo "# My Project" > README.md
git add README.md
git commit -m "Initial commit"

# The pre-commit.sample already exists (git init creates it)
# Player needs to create pre-commit (without .sample)
```

### solution.sh
```bash
#!/usr/bin/env bash
cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
echo "Running pre-commit checks..."
exit 0
EOF
chmod +x .git/hooks/pre-commit
```

---

## Level 225 — The Final Incident

**File**: `modules/module-14-war-games/level-225-wargame-final-incident/`

### mission.yaml
```yaml
name: "The Final Incident"
module: "module-14-war-games"
level: "level-225-wargame-final-incident"
order: 225
difficulty: "expert"
xp: 800
expected_time: "45m"
concepts:
  - "force push recovery"
  - "lost branch recovery"
  - "hook debugging"
  - "merge conflict resolution"
  - "reflog"

description: |
  Production is down. Four things went wrong simultaneously:

  1. A teammate force-pushed `main`, overwriting your last 2 commits.
  2. The `feature/payments` branch was accidentally deleted.
  3. The `pre-commit` hook has a bug — it's rejecting all commits with exit code 1.
  4. There's a live merge conflict in `api.py` that was committed with conflict markers still in it.

  This is your final exam.

objective: |
  Fix all four problems:
  1. Restore the 2 lost commits to `main` using reflog.
  2. Restore the `feature/payments` branch using reflog.
  3. Fix the `pre-commit` hook so it no longer blocks commits.
  4. Remove the conflict markers from `api.py` and amend the commit.

hints:
  - "Start with `git reflog` to understand the full history of HEAD movements."
  - "Use `git reset --hard <hash>` to restore main's lost commits."
  - "For the deleted branch, `git reflog` will show when it was last at its tip — use `git checkout -b feature/payments <hash>`."
  - "Inspect `.git/hooks/pre-commit` — find and fix the exit code bug."
  - "For the conflict markers in api.py, edit the file, then `git add api.py` and `git commit --amend`."

guide: |
  ## Step-by-step Guide

  ### 1. Restore lost commits on main
  ```bash
  git reflog
  # Find the hash before the force push
  git reset --hard <pre-force-push-hash>
  ```

  ### 2. Restore the deleted feature/payments branch
  ```bash
  git reflog | grep "payments"
  # Find the last commit hash on that branch
  git checkout -b feature/payments <hash>
  git checkout main
  ```

  ### 3. Fix the broken pre-commit hook
  ```bash
  cat .git/hooks/pre-commit
  # Look for the bug (probably `exit 1` unconditionally)
  # Fix the exit code:
  sed -i 's/^exit 1$/exit 0/' .git/hooks/pre-commit
  ```

  ### 4. Fix conflict markers in api.py
  ```bash
  # Edit api.py — remove all <<<<<<< ======= >>>>>>> lines
  # Keep the correct version of each conflicted section
  git add api.py
  git commit --amend --no-edit
  ```

debrief: |
  ## The Final Incident: What You Just Survived

  Real production incidents rarely come one at a time.
  You've now demonstrated mastery of Git's recovery mechanisms:

  **Reflog** is your black box recorder — it captures every HEAD movement,
  even operations that "destroy" history.

  **Force push** rewrites remote history — always use `--force-with-lease`
  in real projects to avoid overwriting others' work.

  **Hook bugs** silently block your team's workflow until diagnosed.
  Always test hooks with `bash -x .git/hooks/pre-commit` to debug.

  **Conflict markers in commits** are embarrassing production bugs.
  Git doesn't prevent you from committing them — you need a pre-commit hook
  that checks for `<<<<<<<` in tracked files.

  You have completed GitMissions. You are ready for real-world Git.

validators:
  - type: commit_count_gte
    branch: "main"
    count: 7
    description: "main has all original commits restored (at least 7)"

  - type: branch_exists
    branch: "feature/payments"
    description: "feature/payments branch restored"

  - type: hook_exists
    hook: "pre-commit"
    description: "pre-commit hook exists and is executable"

  - type: no_conflict_markers
    description: "No conflict markers in any tracked file"

  - type: is_clean
    description: "Working tree is clean"

  - type: is_on_branch
    branch: "main"
    description: "HEAD is on main"
```

### setup.sh
```bash
#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"

git init
git config user.email "player@gitmissions.local"
git config user.name "Player"

# Build main history
echo "v1" > api.py; git add api.py; git commit -m "Initial commit"
echo "v2" > api.py; git add api.py; git commit -m "feat: user auth"
echo "v3" > api.py; git add api.py; git commit -m "feat: dashboard"
echo "v4" > api.py; git add api.py; git commit -m "feat: reporting"

# Create feature/payments branch
git checkout -b feature/payments
echo "payments_v1" > payments.py; git add payments.py; git commit -m "feat: payment init"
echo "payments_v2" > payments.py; git add payments.py; git commit -m "feat: payment processing"

# Back to main — add 2 more commits
git checkout main
echo "v5" > api.py; git add api.py; git commit -m "feat: notifications"
echo "v6" > api.py; git add api.py; git commit -m "feat: exports"

# PROBLEM 1: Simulate force push by resetting main 2 back
git reset --hard HEAD~2

# PROBLEM 2: Delete the feature/payments branch
git branch -D feature/payments

# PROBLEM 3: Install a broken pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash
echo "Running checks..."
exit 1
EOF
chmod +x .git/hooks/pre-commit

# PROBLEM 4: Commit a file with conflict markers in it
cat > api.py << 'EOF'
<<<<<<< HEAD
def get_users():
    return []
=======
def get_users():
    return db.query("SELECT * FROM users")
>>>>>>> feature/db
EOF
git add api.py
git commit --no-verify -m "feat: add get_users endpoint"
```

### solution.sh
```bash
#!/usr/bin/env bash
# 1. Restore main's lost 2 commits
git reset --hard HEAD@{4}  # hash will vary — use reflog to find

# 2. Restore feature/payments branch
# git checkout -b feature/payments <hash-from-reflog>

# 3. Fix the broken hook
sed -i 's/^exit 1$/exit 0/' .git/hooks/pre-commit

# 4. Fix conflict markers in api.py
cat > api.py << 'EOF'
def get_users():
    return db.query("SELECT * FROM users")
EOF
git add api.py
git commit --amend --no-edit
```
