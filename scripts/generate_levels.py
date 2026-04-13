#!/usr/bin/env python3
from __future__ import annotations

import re
import shutil
import sys
import textwrap
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

MODULES_DIR = REPO_ROOT / "modules"
CURRICULUM = REPO_ROOT / "CURRICULUM.md"

MODULE_DIRS = {
    1: "module-01-foundations",
    2: "module-02-branching-basics",
    3: "module-03-merge-conflicts",
    4: "module-04-remote-operations",
    5: "module-05-detached-head",
    6: "module-06-rebase",
    7: "module-07-stash",
    8: "module-08-history-reflog",
    9: "module-09-reset-revert",
    10: "module-10-tags-releases",
    11: "module-11-git-hooks",
    12: "module-12-advanced-git",
    13: "module-13-git-internals",
    14: "module-14-war-games",
}


def parse_curriculum() -> list[dict]:
    text = CURRICULUM.read_text(encoding="utf-8")
    lines = text.splitlines()
    levels: list[dict] = []
    module_num = None
    for line in lines:
        header = re.match(r"## Module (\d+) ", line)
        if header:
            module_num = int(header.group(1))
            continue
        row = re.match(r"\| (\d+) \| ([^|]+) \| ([^|]+) \| ([^|]+) \| (\d+) \|", line)
        if row and module_num is not None:
            order = int(row.group(1))
            levels.append(
                {
                    "order": order,
                    "slug": row.group(2).strip(),
                    "title": row.group(3).strip(),
                    "concept": row.group(4).strip(),
                    "xp": int(row.group(5)),
                    "module_num": module_num,
                    "module_dir": MODULE_DIRS[module_num],
                    "level_dir": f"level-{order:03d}-{row.group(2).strip()}",
                    "difficulty": difficulty_for_module(module_num, order),
                }
            )
    return levels


def difficulty_for_module(module_num: int, order: int) -> str:
    if module_num == 1:
        return "beginner"
    if module_num in {2, 10}:
        return "beginner" if module_num == 2 else "intermediate"
    if module_num in {3, 4, 5, 6, 7}:
        return "intermediate"
    if module_num in {8, 9, 11}:
        return "advanced"
    return "expert" if module_num in {12, 13, 14} else "advanced"


def estimated_time(module_num: int) -> str:
    return {
        1: "5m",
        2: "6m",
        3: "10m",
        4: "9m",
        5: "8m",
        6: "12m",
        7: "7m",
        8: "10m",
        9: "10m",
        10: "7m",
        11: "12m",
        12: "14m",
        13: "12m",
        14: "18m",
    }[module_num]


def shell_header() -> str:
    return "#!/usr/bin/env bash\nset -e\nSANDBOX=\"$1\"\ncd \"$SANDBOX\"\n"


def repo_init() -> str:
    return textwrap.dedent(
        """
        git init -b main
        git config user.email "player@gitmissions.local"
        git config user.name "Player"
        """
    ).strip()


def write_text(path: Path, content: str, executable: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")
    if executable:
        path.chmod(0o755)


def dump_yaml(path: Path, data: dict) -> None:
    path.write_text(yaml.safe_dump(data, sort_keys=False, allow_unicode=False), encoding="utf-8")


def file_block(path: str, content: str) -> str:
    return f"cat > {path} <<'EOF'\n{content.rstrip()}\nEOF"


def write_exact_cmd(path: str, content: str) -> str:
    return file_block(path, content)


def foundation_level(level: dict) -> dict:
    slug = level["slug"]
    if slug == "init-your-first-repo":
        mission = mission_base(level)
        mission["repo_path"] = "project"
        mission["description"] = "A small project folder exists, but it is not a Git repository yet."
        mission["objective"] = "Initialize Git in `project/`, stage every file, and create a commit with the message `Initial commit`."
        mission["hints"] = [
            "Change into `project/` first.",
            "Use `git init` to create the repository.",
            "Stage everything with `git add .`.",
            "Commit with `git commit -m \"Initial commit\"`.",
        ]
        mission["guide"] = guide_steps(
            "cd project",
            "git init",
            "git add .",
            "git commit -m \"Initial commit\"",
        )
        mission["debrief"] = debrief_text(level["title"], "Git repositories start when `.git/` is created with `git init`.")
        mission["validators"] = [
            {"type": "is_on_branch", "branch": "main", "alt_branches": ["master"], "description": "Repository is on main or master"},
            {"type": "commit_count_gte", "branch": "HEAD", "count": 1, "description": "At least one commit exists"},
            {"type": "commit_message_contains", "text": "Initial commit", "description": "Latest commit message contains 'Initial commit'"},
            {"type": "is_clean", "description": "Working tree is clean"},
        ]
        setup = shell_header() + "\nmkdir -p project\ncd project\n" + "\n\n".join(
            [
                file_block("README.md", "# My Project\n"),
                file_block("main.py", "print('hello')\n"),
                file_block(".gitignore", "__pycache__/\n*.pyc\n"),
            ]
        )
        solution = solution_script(["git init", "git add .", "git commit -m \"Initial commit\""], comment="Run in project/")
        return {"mission": mission, "setup": setup, "solution": solution}

    if slug == "your-first-commit":
        return repo_commit_level(
            level,
            description="The repository exists, but the first file has not been committed yet.",
            objective="Stage `hello.txt` and create the first commit with the message `Initial commit`.",
            setup_extra=file_block("hello.txt", "hello gitmissions\n"),
            solution_cmds=["git add hello.txt", "git commit -m \"Initial commit\""],
            validators=[
                {"type": "commit_message_contains", "text": "Initial commit", "description": "Latest commit message contains 'Initial commit'"},
                {"type": "commit_count_eq", "branch": "HEAD", "count": 2, "description": "The first user commit was created"},
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    reports = {
        "check-status": ("status-report.txt", "staged=1\nunstaged=1\nuntracked=1"),
        "read-the-log": ("log-report.txt", "latest=Add release notes"),
        "see-the-diff": ("diff-report.txt", "changed_line=version=2"),
        "view-a-past-commit": ("past-commit.txt", "subject=Initial scaffold"),
        "compare-two-commits": ("compare-report.txt", "difference=version line changed"),
        "log-pretty-formats": ("pretty-log.txt", "Alice: Add release notes"),
        "log-filter-by-author": ("author-report.txt", "matches=2"),
        "log-filter-by-date": ("date-report.txt", "matches=2"),
        "log-search-by-message": ("grep-report.txt", "matches=1"),
    }
    if slug in reports:
        filename, expected = reports[slug]
        return history_report_level(level, filename, expected)

    if slug == "stage-specific-files":
        return repo_commit_level(
            level,
            description="Three files changed, but only one belongs in the next commit.",
            objective="Commit only `app.txt` with the message `feat: update app file`.",
            setup_extra="\n\n".join(
                [
                    "git add . >/dev/null 2>&1 || true",
                    file_block("app.txt", "app=v2\n"),
                    file_block("notes.txt", "leave me alone\n"),
                    file_block("draft.txt", "also leave me alone\n"),
                ]
            ),
            solution_cmds=[
                "git add app.txt",
                "git commit -m \"feat: update app file\"",
                "rm -f notes.txt draft.txt",
            ],
            validators=[
                {"type": "commit_message_contains", "text": "feat: update app file", "description": "Latest commit message is correct"},
                {
                    "type": "script_passes",
                    "description": "Only app.txt changed in the latest commit",
                    "script": "test \"$(git diff --name-only HEAD~1 HEAD)\" = \"app.txt\"",
                },
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    if slug == "unstage-a-file":
        return repo_commit_level(
            level,
            description="Two files are staged, but only one should be committed.",
            objective="Unstage `debug.log`, then commit only `app.txt` with the message `fix: commit app only`.",
            setup_extra="\n\n".join(
                [
                    file_block("app.txt", "version=2\n"),
                    file_block("debug.log", "verbose output\n"),
                    "git add app.txt debug.log",
                ]
            ),
            solution_cmds=[
                "git restore --staged debug.log",
                "git commit -m \"fix: commit app only\"",
                "rm -f debug.log",
                "git restore --staged debug.log >/dev/null 2>&1 || true",
            ],
            validators=[
                {"type": "commit_message_contains", "text": "fix: commit app only", "description": "Latest commit message is correct"},
                {
                    "type": "script_passes",
                    "description": "Only app.txt changed in the latest commit",
                    "script": "test \"$(git diff --name-only HEAD~1 HEAD)\" = \"app.txt\"",
                },
                {"type": "file_not_exists", "path": "debug.log", "description": "debug.log is gone from the working tree"},
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    if slug == "amend-last-commit":
        return repo_commit_level(
            level,
            description="The most recent commit has the wrong message and is missing a release note.",
            objective="Amend the latest commit so the message contains `docs: release notes` and `notes.md` contains `v1.0 ready`.",
            setup_extra="\n\n".join(
                [
                    file_block("notes.md", "draft notes\n"),
                    "git add notes.md",
                    "git commit -m \"bad message\"",
                ]
            ),
            solution_cmds=[
                "printf 'v1.0 ready\n' > notes.md",
                "git add notes.md",
                "git commit --amend -m \"docs: release notes\"",
            ],
            validators=[
                {"type": "commit_message_contains", "text": "docs: release notes", "description": "Latest commit message was amended"},
                {"type": "file_content_contains", "path": "notes.md", "text": "v1.0 ready", "description": "notes.md contains the release note"},
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    if slug == "discard-unstaged":
        return repo_commit_level(
            level,
            description="`config.ini` was edited locally, but the change should be discarded.",
            objective="Throw away the unstaged change in `config.ini` and leave the repo clean.",
            setup_extra="\n\n".join(
                [
                    file_block("config.ini", "mode=stable\n"),
                    "git add config.ini",
                    "git commit -m \"Add config\"",
                    "printf 'mode=broken\n' > config.ini",
                ]
            ),
            solution_cmds=["git restore config.ini"],
            validators=[
                {"type": "file_content_equals", "path": "config.ini", "text": "mode=stable", "description": "config.ini matches the committed version"},
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    if slug == "create-gitignore":
        return repo_commit_level(
            level,
            description="Build artifacts are cluttering the repo and should be ignored going forward.",
            objective="Create a `.gitignore` that ignores `*.log` and `build/`, then commit it with the message `chore: add gitignore`.",
            setup_extra="\n\n".join(
                [
                    "mkdir -p build",
                    file_block("server.log", "noise\n"),
                    file_block("build/output.txt", "artifact\n"),
                ]
            ),
            solution_cmds=[
                "printf '*.log\nbuild/\n' > .gitignore",
                "git add .gitignore",
                "git commit -m \"chore: add gitignore\"",
            ],
            validators=[
                {"type": "file_content_contains", "path": ".gitignore", "text": "*.log", "description": ".gitignore ignores log files"},
                {"type": "file_content_contains", "path": ".gitignore", "text": "build/", "description": ".gitignore ignores build/"},
                {"type": "commit_message_contains", "text": "chore: add gitignore", "description": "Latest commit message is correct"},
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    if slug == "ignore-already-tracked":
        return repo_commit_level(
            level,
            description="A secrets file is already tracked, but it should now be ignored without deleting it locally.",
            objective="Stop tracking `secrets.env`, add it to `.gitignore`, and commit with the message `chore: ignore secrets`.",
            setup_extra="\n\n".join(
                [
                    file_block("secrets.env", "TOKEN=12345\n"),
                    "git add secrets.env",
                    "git commit -m \"Add secrets file\"",
                ]
            ),
            solution_cmds=[
                "printf 'secrets.env\n' > .gitignore",
                "git rm --cached secrets.env",
                "git add .gitignore",
                "git commit -m \"chore: ignore secrets\"",
            ],
            validators=[
                {"type": "file_exists", "path": "secrets.env", "description": "secrets.env still exists locally"},
                {"type": "file_content_contains", "path": ".gitignore", "text": "secrets.env", "description": ".gitignore ignores secrets.env"},
                {
                    "type": "script_passes",
                    "description": "secrets.env is no longer tracked",
                    "script": "! git ls-files --error-unmatch secrets.env >/dev/null 2>&1",
                },
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    if slug == "global-git-config":
        return repo_commit_level(
            level,
            description="This sandbox repo has no identity configured yet.",
            objective="Configure `user.name` as `Git Missions` and `user.email` as `missions@example.com` for this repository.",
            setup_extra="git config --unset-all user.name >/dev/null 2>&1 || true\ngit config --unset-all user.email >/dev/null 2>&1 || true",
            solution_cmds=[
                "git config user.name \"Git Missions\"",
                "git config user.email \"missions@example.com\"",
            ],
            validators=[
                {
                    "type": "script_passes",
                    "description": "Repository user.name is configured",
                    "script": "test \"$(git config user.name)\" = \"Git Missions\"",
                },
                {
                    "type": "script_passes",
                    "description": "Repository user.email is configured",
                    "script": "test \"$(git config user.email)\" = \"missions@example.com\"",
                },
            ],
        )

    if slug == "commit-with-body":
        return repo_commit_level(
            level,
            description="A documentation update is ready, but the commit needs both a subject and a body.",
            objective="Commit `CHANGELOG.md` with the subject `docs: add changelog` and a body line containing `Explains the first release`.",
            setup_extra=file_block("CHANGELOG.md", "## v1.0\n- first release\n"),
            solution_cmds=[
                "git add CHANGELOG.md",
                "git commit -m \"docs: add changelog\" -m \"Explains the first release\"",
            ],
            validators=[
                {"type": "commit_message_contains", "text": "docs: add changelog", "description": "Commit subject is correct"},
                {"type": "commit_message_contains", "text": "Explains the first release", "description": "Commit body contains the explanation"},
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    if slug == "empty-commit":
        return repo_commit_level(
            level,
            description="Operations wants a marker commit even though no files changed.",
            objective="Create an empty commit with the message `chore: mark release checkpoint`.",
            setup_extra="",
            solution_cmds=["git commit --allow-empty -m \"chore: mark release checkpoint\""],
            validators=[
                {"type": "commit_message_contains", "text": "chore: mark release checkpoint", "description": "Empty commit message is correct"},
                {"type": "commit_count_eq", "branch": "HEAD", "count": 2, "description": "A new commit was created"},
                {"type": "is_clean", "description": "Working tree is clean"},
            ],
        )

    return history_report_level(level, "report.txt", "done=1")


def repo_commit_level(level: dict, description: str, objective: str, setup_extra: str, solution_cmds: list[str], validators: list[dict]) -> dict:
    mission = mission_base(level)
    mission["description"] = description
    mission["objective"] = objective
    mission["hints"] = generic_hints(level["concept"])
    mission["guide"] = guide_steps(*solution_cmds)
    mission["debrief"] = debrief_text(level["title"], f"This level focused on {level['concept']}.")
    mission["validators"] = validators
    setup_parts = [
        shell_header(),
        repo_init(),
        file_block("README.md", "# Sandbox\n"),
        "git add README.md",
        "git commit -m \"Initial scaffold\"",
    ]
    if setup_extra.strip():
        setup_parts.append(setup_extra.strip())
    setup = "\n\n".join(setup_parts)
    solution = solution_script(solution_cmds)
    return {"mission": mission, "setup": setup, "solution": solution}


def history_report_level(level: dict, filename: str, expected: str) -> dict:
    mission = mission_base(level)
    mission["description"] = f"This repository contains a small history designed to practice `{level['concept']}`."
    mission["objective"] = f"Inspect the repository history and create `{filename}` containing exactly:\n\n`{expected}`\n\nThen commit the report with the message `docs: add report`."
    mission["hints"] = [
        f"Start with the Git command related to `{level['concept']}`.",
        f"Write the exact expected answer into `{filename}`.",
        "Commit the report so the working tree ends clean.",
    ]
    mission["guide"] = guide_steps(
        write_exact_cmd(filename, expected),
        f"git add {filename}",
        "git commit -m \"docs: add report\"",
    )
    mission["debrief"] = debrief_text(level["title"], "Inspection commands become much easier to remember when you tie them to concrete answers.")
    mission["validators"] = [
        {"type": "file_content_equals", "path": filename, "text": expected, "description": f"{filename} contains the expected answer"},
        {"type": "commit_message_contains", "text": "docs: add report", "description": "Latest commit message contains 'docs: add report'"},
        {"type": "is_clean", "description": "Working tree is clean"},
    ]
    setup = "\n\n".join(
        [
            shell_header(),
            repo_init(),
            file_block("app.txt", "version=1\n"),
            "git add app.txt",
            "GIT_AUTHOR_NAME='Alice' GIT_AUTHOR_EMAIL='alice@example.com' GIT_AUTHOR_DATE='2024-01-10T10:00:00' GIT_COMMITTER_DATE='2024-01-10T10:00:00' git commit -m \"Initial scaffold\"",
            "printf 'version=2\n' > app.txt",
            "git add app.txt",
            "GIT_AUTHOR_NAME='Bob' GIT_AUTHOR_EMAIL='bob@example.com' GIT_AUTHOR_DATE='2024-02-10T10:00:00' GIT_COMMITTER_DATE='2024-02-10T10:00:00' git commit -m \"Bump version\"",
            file_block("RELEASE.md", "ready\n"),
            "git add RELEASE.md",
            "GIT_AUTHOR_NAME='Alice' GIT_AUTHOR_EMAIL='alice@example.com' GIT_AUTHOR_DATE='2024-03-10T10:00:00' GIT_COMMITTER_DATE='2024-03-10T10:00:00' git commit -m \"Add release notes\"",
        ]
    )
    solution = solution_script(
        [
            write_exact_cmd(filename, expected),
            f"git add {filename}",
            "git commit -m \"docs: add report\"",
        ]
    )
    return {"mission": mission, "setup": setup, "solution": solution}


def branching_level(level: dict) -> dict:
    slug = level["slug"]
    if slug == "list-branches":
        return branches_report(level, "branches.txt", "main\nfeature/ui\nbugfix/login")
    if slug == "view-merged-branches":
        return branches_report(level, "merged.txt", "feature/merged")
    if slug == "create-a-branch":
        return branch_action_level(level, "Create a branch named `feature/login`.", ["git branch feature/login"], [{"type": "branch_exists", "branch": "feature/login", "description": "feature/login exists"}])
    if slug == "switch-to-branch":
        return branch_action_level(level, "Switch from `main` to `feature/ui`.", ["git switch feature/ui"], [{"type": "is_on_branch", "branch": "feature/ui", "description": "HEAD is on feature/ui"}], setup_extra="git branch feature/ui")
    if slug == "create-and-switch":
        return branch_action_level(level, "Create and switch to `feature/docs`.", ["git switch -c feature/docs"], [{"type": "branch_exists", "branch": "feature/docs", "description": "feature/docs exists"}, {"type": "is_on_branch", "branch": "feature/docs", "description": "HEAD is on feature/docs"}])
    if slug == "rename-a-branch":
        return branch_action_level(level, "Rename `old-name` to `feature/docs`.", ["git branch -m old-name feature/docs"], [{"type": "branch_not_exists", "branch": "old-name", "description": "old-name no longer exists"}, {"type": "branch_exists", "branch": "feature/docs", "description": "feature/docs exists"}], setup_extra="git branch old-name")
    if slug == "delete-merged-branch":
        return merged_branch_cleanup(level, force=False)
    if slug == "delete-unmerged-branch":
        return merged_branch_cleanup(level, force=True)
    if slug == "fast-forward-merge":
        return merge_level(level, no_ff=False)
    if slug == "no-fast-forward-merge":
        return merge_level(level, no_ff=True)
    if slug == "merge-two-branches":
        return merge_diverged_level(level)
    if slug == "branch-from-commit":
        return branch_from_ref(level, "HEAD~1", "rescue")
    if slug == "branch-from-tag":
        return branch_from_tag(level)
    if slug == "copy-file-from-branch":
        return copy_file_from_branch(level)
    if slug == "upstream-tracking":
        return upstream_tracking_level(level)
    return branch_action_level(level, f"Create a branch related to `{level['title']}`.", ["git branch practice"], [{"type": "branch_exists", "branch": "practice", "description": "practice branch exists"}])


def branch_action_level(level: dict, objective: str, solution_cmds: list[str], validators: list[dict], setup_extra: str = "") -> dict:
    mission = mission_base(level)
    mission["description"] = "This sandbox starts from a simple `main` branch with one commit."
    mission["objective"] = objective
    mission["hints"] = generic_hints(level["concept"])
    mission["guide"] = guide_steps(*solution_cmds)
    mission["debrief"] = debrief_text(level["title"], "Branches are lightweight references to commits, which makes them cheap to create and remove.")
    mission["validators"] = validators
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "main\n"), "git add app.txt", "git commit -m \"Initial scaffold\"", setup_extra.strip()]).strip() + "\n"
    return {"mission": mission, "setup": setup, "solution": solution_script(solution_cmds)}


def branches_report(level: dict, filename: str, expected: str) -> dict:
    mission = mission_base(level)
    mission["description"] = "This repo has a few local branches to inspect."
    mission["objective"] = f"Inspect the branch list and create `{filename}` containing exactly:\n\n`{expected}`\n\nThen commit it with `docs: record branches`."
    mission["hints"] = ["Use `git branch` or `git branch --merged` depending on the mission.", f"Write the exact answer into `{filename}`.", "Commit the report."]
    mission["guide"] = guide_steps(
        write_exact_cmd(filename, expected),
        f"git add {filename}",
        "git commit -m \"docs: record branches\"",
    )
    mission["debrief"] = debrief_text(level["title"], "Branch inspection commands help you clean up stale work safely.")
    mission["validators"] = [
        {"type": "file_content_equals", "path": filename, "text": expected, "description": f"{filename} contains the expected answer"},
        {"type": "commit_message_contains", "text": "docs: record branches", "description": "Latest commit message contains 'docs: record branches'"},
        {"type": "is_clean", "description": "Working tree is clean"},
    ]
    setup = "\n\n".join(
        [
            shell_header(),
            repo_init(),
            file_block("app.txt", "base\n"),
            "git add app.txt",
            "git commit -m \"Initial scaffold\"",
            "git branch feature/ui",
            "git branch bugfix/login",
            "git checkout -b feature/merged",
            "printf 'merged branch\n' > merged.txt",
            "git add merged.txt",
            "git commit -m \"Work on merged branch\"",
            "git checkout main",
            "git merge feature/merged --no-edit",
        ]
    )
    return {"mission": mission, "setup": setup, "solution": solution_script([write_exact_cmd(filename, expected), f"git add {filename}", "git commit -m \"docs: record branches\""])}


def merged_branch_cleanup(level: dict, force: bool) -> dict:
    branch = "feature/old" if not force else "feature/wip"
    mission = mission_base(level)
    mission["description"] = "A temporary branch should be removed from the repository."
    mission["objective"] = f"Delete `{branch}`{' with force' if force else ''} and leave the repo on `main`."
    mission["hints"] = ["List branches first.", f"Use `git branch {'-D' if force else '-d'} {branch}`.", "Stay on `main`."]
    mission["guide"] = guide_steps(f"git branch {'-D' if force else '-d'} {branch}")
    mission["debrief"] = debrief_text(level["title"], "Deleting merged branches is cleanup; force deletion is a deliberate safety override.")
    mission["validators"] = [
        {"type": "branch_not_exists", "branch": branch, "description": f"{branch} no longer exists"},
        {"type": "is_on_branch", "branch": "main", "description": "HEAD is on main"},
    ]
    setup_parts = [shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Initial scaffold\""]
    if force:
        setup_parts += ["git checkout -b feature/wip", "printf 'wip\n' > wip.txt", "git add wip.txt", "git commit -m \"WIP\"", "git checkout main"]
    else:
        setup_parts += ["git checkout -b feature/old", "printf 'done\n' > done.txt", "git add done.txt", "git commit -m \"Complete work\"", "git checkout main", "git merge feature/old --no-edit"]
    return {"mission": mission, "setup": "\n\n".join(setup_parts), "solution": solution_script([f"git branch {'-D' if force else '-d'} {branch}"])}


def merge_level(level: dict, no_ff: bool) -> dict:
    mission = mission_base(level)
    mission["description"] = "A feature branch is ready to be integrated into `main`."
    mission["objective"] = f"Merge `feature/login` into `main` using {'`--no-ff`' if no_ff else 'a fast-forward merge'}."
    mission["hints"] = ["Make sure you are on `main`.", f"Merge with `git merge {'--no-ff ' if no_ff else ''}feature/login`.", "Keep the working tree clean after the merge."]
    mission["guide"] = guide_steps("git switch main", f"git merge {'--no-ff ' if no_ff else ''}feature/login")
    mission["debrief"] = debrief_text(level["title"], "Fast-forward merges keep history linear; `--no-ff` preserves an explicit integration point.")
    mission["validators"] = [
        {"type": "is_on_branch", "branch": "main", "description": "HEAD is on main"},
        {"type": "file_content_contains", "path": "feature.txt", "text": "login ready", "description": "Feature change reached main"},
        {"type": "merge_commit_exists" if no_ff else "no_merge_commit", "branch": "HEAD", "description": "History shape matches the mission"},
        {"type": "is_clean", "description": "Working tree is clean"},
    ]
    setup_parts = [shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Initial scaffold\"", "git checkout -b feature/login", file_block("feature.txt", "login ready\n"), "git add feature.txt", "git commit -m \"Add login feature\"", "git checkout main"]
    return {"mission": mission, "setup": "\n\n".join(setup_parts), "solution": solution_script(["git switch main", f"git merge {'--no-ff ' if no_ff else ''}feature/login"])}


def merge_diverged_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "Two branches diverged on separate files, so the merge should complete cleanly."
    mission["objective"] = "Merge `feature/api` into `main` and keep both files."
    mission["hints"] = ["Check out `main` first.", "Run `git merge feature/api`.", "There should be no conflicts because the branches touched different files."]
    mission["guide"] = guide_steps("git switch main", "git merge feature/api")
    mission["debrief"] = debrief_text(level["title"], "Diverged branches can merge automatically when they touch different parts of the tree.")
    mission["validators"] = [
        {"type": "merge_commit_exists", "branch": "HEAD", "description": "A merge commit exists"},
        {"type": "file_exists", "path": "main.txt", "description": "main.txt exists"},
        {"type": "file_exists", "path": "api.txt", "description": "api.txt exists"},
        {"type": "is_clean", "description": "Working tree is clean"},
    ]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Initial scaffold\"", "git checkout -b feature/api", file_block("api.txt", "api work\n"), "git add api.txt", "git commit -m \"Add API work\"", "git checkout main", file_block("main.txt", "main work\n"), "git add main.txt", "git commit -m \"Add main work\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch main", "git merge feature/api"])}


def branch_from_ref(level: dict, ref: str, name: str) -> dict:
    mission = mission_base(level)
    mission["description"] = "You need to preserve work by creating a branch from an older point in history."
    mission["objective"] = f"Create a branch named `{name}` from `{ref}`."
    mission["hints"] = ["Inspect the log if you want to confirm the target commit.", f"Use `git switch -c {name} {ref}` or `git branch {name} {ref}`."]
    mission["guide"] = guide_steps(f"git switch -c {name} {ref}")
    mission["debrief"] = debrief_text(level["title"], "Branches can point at any reachable commit, not just the current HEAD.")
    mission["validators"] = [{"type": "branch_exists", "branch": name, "description": f"{name} exists"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Initial scaffold\"", "printf 'v2\n' > app.txt", "git add app.txt", "git commit -m \"Second commit\""])
    return {"mission": mission, "setup": setup, "solution": solution_script([f"git switch -c {name} {ref}"])}


def branch_from_tag(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A release tag marks the point where the new branch should begin."
    mission["objective"] = "Create a branch named `hotfix` from tag `v1.0`."
    mission["hints"] = ["List tags if needed.", "Use `git switch -c hotfix v1.0`."]
    mission["guide"] = guide_steps("git switch -c hotfix v1.0")
    mission["debrief"] = debrief_text(level["title"], "Tags are fixed pointers, but you can branch from them whenever work needs to resume.")
    mission["validators"] = [{"type": "branch_exists", "branch": "hotfix", "description": "hotfix exists"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Initial release\"", "git tag v1.0", "printf 'v2\n' > app.txt", "git add app.txt", "git commit -m \"Next release\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch -c hotfix v1.0"])}


def copy_file_from_branch(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A file exists only on a feature branch, and you need it on `main` without merging the whole branch."
    mission["objective"] = "Copy `release.md` from `feature/docs` into `main` and commit it with `docs: copy release notes`."
    mission["hints"] = ["Stay on `main`.", "Use `git checkout feature/docs -- release.md`.", "Commit the copied file."]
    mission["guide"] = guide_steps("git switch main", "git checkout feature/docs -- release.md", "git commit -m \"docs: copy release notes\"")
    mission["debrief"] = debrief_text(level["title"], "Checking out a file from another branch is a precise alternative to a full merge.")
    mission["validators"] = [
        {"type": "file_content_contains", "path": "release.md", "text": "Release notes", "description": "release.md was copied"},
        {"type": "commit_message_contains", "text": "docs: copy release notes", "description": "Commit message is correct"},
        {"type": "is_clean", "description": "Working tree is clean"},
    ]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Initial scaffold\"", "git checkout -b feature/docs", file_block("release.md", "Release notes\n"), "git add release.md", "git commit -m \"Add release notes\"", "git checkout main"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch main", "git checkout feature/docs -- release.md", "git add release.md", "git commit -m \"docs: copy release notes\""])}


def upstream_tracking_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["repo_path"] = "local"
    mission["description"] = "A local clone has a branch that should track the remote branch of the same name."
    mission["objective"] = "Set `feature/ui` to track `origin/feature/ui`."
    mission["hints"] = ["Work inside `local/`.", "Inspect remote branches with `git branch -a`.", "Use `git branch --set-upstream-to=origin/feature/ui feature/ui`."]
    mission["guide"] = guide_steps("cd local", "git branch --set-upstream-to=origin/feature/ui feature/ui")
    mission["debrief"] = debrief_text(level["title"], "Tracking branches connect local work to a remote reference so pull and push defaults behave well.")
    mission["validators"] = [
        {
            "type": "script_passes",
            "description": "feature/ui tracks origin/feature/ui",
            "script": "test \"$(git for-each-ref --format='%(upstream:short)' refs/heads/feature/ui)\" = \"origin/feature/ui\"",
        }
    ]
    setup = "\n\n".join(
        [
            shell_header(),
            "git init --bare remote.git",
            "git clone remote.git seed",
            "cd seed",
            "git config user.email \"player@gitmissions.local\"",
            "git config user.name \"Player\"",
            file_block("README.md", "seed\n"),
            "git add README.md",
            "git commit -m \"Initial scaffold\"",
            "git branch -M main",
            "git push origin main",
            "git -C ../remote.git symbolic-ref HEAD refs/heads/main",
            "git checkout -b feature/ui",
            file_block("ui.txt", "remote ui\n"),
            "git add ui.txt",
            "git commit -m \"Add remote branch\"",
            "git push -u origin feature/ui",
            "cd ..",
            "git clone remote.git local",
            "cd local",
            "git config user.email \"player@gitmissions.local\"",
            "git config user.name \"Player\"",
            "git branch feature/ui origin/feature/ui",
        ]
    )
    return {"mission": mission, "setup": setup, "solution": solution_script(["git branch --set-upstream-to=origin/feature/ui feature/ui"])}


def conflict_level(level: dict) -> dict:
    slug = level["slug"]
    strategy = "feature" if "theirs" in slug or slug == "first-conflict" else "main" if "ours" in slug else "both"
    if slug == "abort-a-merge":
        return abort_merge_level(level)
    if slug == "merge-strategy-ours":
        return strategy_merge_level(level, ours=True)
    if slug == "merge-strategy-recursive":
        return strategy_merge_level(level, ours=False)
    if slug == "octopus-merge":
        return octopus_level(level)
    if slug == "rerere":
        return rerere_level(level)
    if slug == "prevent-conflicts":
        return prevent_conflicts_level(level)
    return standard_conflict_level(level, strategy)


def standard_conflict_level(level: dict, strategy: str) -> dict:
    final_line = {
        "main": "value=main\n",
        "feature": "value=feature\n",
        "both": "value=main+feature\n",
    }[strategy]
    mission = mission_base(level)
    mission["description"] = "The repository is already stopped in the middle of a merge conflict."
    mission["objective"] = f"Resolve the conflict in `app.txt`, keep {'the current branch version' if strategy == 'main' else 'the incoming version' if strategy == 'feature' else 'both changes combined'}, and complete the merge."
    mission["hints"] = ["Run `git status` to confirm the conflicted file.", "Open `app.txt` and remove the conflict markers.", "Stage the file and commit the merge."]
    mission["guide"] = guide_steps(write_exact_cmd("app.txt", final_line), "git add app.txt", "git commit -m \"Resolve merge conflict\"")
    mission["debrief"] = debrief_text(level["title"], "Conflict resolution is just editing the working tree to the final content you want, then telling Git the file is resolved.")
    mission["validators"] = [
        {"type": "no_conflict_markers", "description": "No conflict markers remain"},
        {"type": "file_content_equals", "path": "app.txt", "text": final_line.strip(), "description": "app.txt has the expected content"},
        {"type": "is_clean", "description": "Working tree is clean"},
        {"type": "is_on_branch", "branch": "main", "description": "HEAD is on main"},
    ]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "value=base\n"), "git add app.txt", "git commit -m \"Base commit\"", "git checkout -b feature/merge", "printf 'value=feature\n' > app.txt", "git add app.txt", "git commit -m \"Feature change\"", "git checkout main", "printf 'value=main\n' > app.txt", "git add app.txt", "git commit -m \"Main change\"", "git merge feature/merge --no-edit || true"])
    return {"mission": mission, "setup": setup, "solution": solution_script([write_exact_cmd("app.txt", final_line), "git add app.txt", "git commit -m \"Resolve merge conflict\""])}


def abort_merge_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A merge conflict started, but this mission asks you to back out safely."
    mission["objective"] = "Abort the merge so the repository returns to a clean `main` branch."
    mission["hints"] = ["The repo is mid-merge right now.", "Use `git merge --abort`."]
    mission["guide"] = guide_steps("git merge --abort")
    mission["debrief"] = debrief_text(level["title"], "Aborting a merge restores the pre-merge state when you decide the attempt should not continue.")
    mission["validators"] = [
        {"type": "is_clean", "description": "Working tree is clean"},
        {"type": "is_on_branch", "branch": "main", "description": "HEAD is on main"},
        {"type": "file_content_equals", "path": "app.txt", "text": "value=main", "description": "The main branch version is restored"},
    ]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "value=base\n"), "git add app.txt", "git commit -m \"Base commit\"", "git checkout -b feature/conflict", "printf 'value=feature\n' > app.txt", "git add app.txt", "git commit -m \"Feature change\"", "git checkout main", "printf 'value=main\n' > app.txt", "git add app.txt", "git commit -m \"Main change\"", "git merge feature/conflict --no-edit || true"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git merge --abort"])}


def strategy_merge_level(level: dict, ours: bool) -> dict:
    mission = mission_base(level)
    mission["description"] = "Two branches disagree completely, and you want Git to prefer one side during the merge."
    mission["objective"] = f"Merge `feature/merge` into `main` using {'the `ours` strategy' if ours else 'a recursive strategy option that prefers our side'}."
    mission["hints"] = ["Start from `main`.", f"Use `git merge {'-s ours' if ours else '-Xours'} feature/merge`.", "Finish with a clean working tree."]
    mission["guide"] = guide_steps("git switch main", f"git merge {'-s ours' if ours else '-Xours'} feature/merge")
    mission["debrief"] = debrief_text(level["title"], "Merge strategies and strategy options let you encode a high-level preference instead of hand-editing every conflict.")
    mission["validators"] = [
        {"type": "file_content_equals", "path": "app.txt", "text": "main-side", "description": "main's version won"},
        {"type": "merge_commit_exists", "branch": "HEAD", "description": "A merge commit exists"},
        {"type": "is_clean", "description": "Working tree is clean"},
    ]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "git checkout -b feature/merge", "printf 'feature-side\n' > app.txt", "git add app.txt", "git commit -m \"Feature side\"", "git checkout main", "printf 'main-side\n' > app.txt", "git add app.txt", "git commit -m \"Main side\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch main", f"git merge {'-s ours' if ours else '-Xours'} feature/merge"])}


def octopus_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "Three short-lived branches each add a different file."
    mission["objective"] = "Merge `feature/a`, `feature/b`, and `feature/c` into `main` with one octopus merge."
    mission["hints"] = ["Check out `main` first.", "Use one `git merge` command with all three branches."]
    mission["guide"] = guide_steps("git switch main", "git merge feature/a feature/b feature/c")
    mission["debrief"] = debrief_text(level["title"], "Octopus merges are useful when several independent branches can be integrated together without conflicts.")
    mission["validators"] = [{"type": "merge_commit_exists", "branch": "HEAD", "description": "A merge commit exists"}, {"type": "file_exists", "path": "a.txt", "description": "a.txt exists"}, {"type": "file_exists", "path": "b.txt", "description": "b.txt exists"}, {"type": "file_exists", "path": "c.txt", "description": "c.txt exists"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "git checkout -b feature/a", file_block("a.txt", "a\n"), "git add a.txt", "git commit -m \"Add a\"", "git checkout main", "git checkout -b feature/b", file_block("b.txt", "b\n"), "git add b.txt", "git commit -m \"Add b\"", "git checkout main", "git checkout -b feature/c", file_block("c.txt", "c\n"), "git add c.txt", "git commit -m \"Add c\"", "git checkout main"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch main", "git merge feature/a feature/b feature/c"])}


def rerere_level(level: dict) -> dict:
    return standard_conflict_level(level, "both") | {"mission": {**standard_conflict_level(level, "both")["mission"], "objective": "Enable `rerere`, resolve the conflict in `app.txt` by keeping both sides as `value=main+feature`, and complete the merge.", "validators": [{"type": "script_passes", "description": "rerere is enabled", "script": "test \"$(git config rerere.enabled)\" = \"true\""}, {"type": "file_content_equals", "path": "app.txt", "text": "value=main+feature", "description": "Conflict was resolved as expected"}, {"type": "is_clean", "description": "Working tree is clean"}]}, "solution": solution_script(["git config rerere.enabled true", "printf 'value=main+feature\n' > app.txt", "git add app.txt", "git commit -m \"Resolve merge conflict\""])}


def prevent_conflicts_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A feature branch is behind `main`, and the safe next step is to bring it up to date before integration."
    mission["objective"] = "Rebase `feature/prevent` onto `main`, then merge it back cleanly."
    mission["hints"] = ["Update the feature branch first.", "Rebase it onto `main`.", "Then merge from `main`."]
    mission["guide"] = guide_steps("git switch feature/prevent", "git rebase main", "git switch main", "git merge feature/prevent")
    mission["debrief"] = debrief_text(level["title"], "Keeping branches short-lived and up to date reduces the chance of painful conflicts later.")
    mission["validators"] = [{"type": "file_exists", "path": "feature.txt", "description": "Feature work reached main"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "git checkout -b feature/prevent", file_block("feature.txt", "feature\n"), "git add feature.txt", "git commit -m \"Feature work\"", "git checkout main", file_block("main.txt", "main\n"), "git add main.txt", "git commit -m \"Main work\"", "git checkout feature/prevent"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch feature/prevent", "git rebase main", "git switch main", "git merge feature/prevent"])}


def remote_level(level: dict) -> dict:
    slug = level["slug"]
    if slug == "clone-a-repo":
        return clone_level(level)
    if slug == "fetch-vs-pull":
        return fetch_level(level)
    if slug == "multiple-remotes":
        return multiple_remotes_level(level)
    if slug == "shallow-clone":
        return shallow_clone_level(level)
    if slug == "push-all-tags":
        return push_all_tags_level(level)
    return generic_remote_level(level)


def generic_remote_level(level: dict) -> dict:
    slug = level["slug"]
    mission = mission_base(level)
    mission["repo_path"] = "local"
    setup = remote_base_setup()
    validators = [{"type": "is_clean", "description": "Working tree is clean"}]
    solution_cmds = []
    objective = ""
    if slug == "add-a-remote":
        objective = "Add a remote named `origin` that points to `../remote.git`."
        solution_cmds = ["git remote add origin ../remote.git"]
        validators = [{"type": "remote_exists", "name": "origin", "description": "origin remote exists"}]
        setup = "\n\n".join([shell_header(), "git init --bare remote.git", "mkdir local", "cd local", "git init -b main", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("README.md", "local repo\n"), "git add README.md", "git commit -m \"Initial scaffold\""])
    elif slug == "push-to-remote":
        objective = "Push `main` to `origin`."
        solution_cmds = ["git push origin main"]
        validators = [{"type": "script_passes", "description": "origin/main exists in the remote", "script": "git -C ../remote.git rev-parse --verify refs/heads/main >/dev/null"}]
    elif slug == "push-rejected-diverged":
        objective = "Resolve the diverged history by integrating `origin/main`, then push successfully."
        solution_cmds = ["git pull --no-rebase origin main", "git push origin main"]
        validators = [{"type": "ahead_of", "other": "origin/main", "count": 0, "description": "Local branch is synchronized with origin/main"}, {"type": "script_passes", "description": "Remote contains the local change", "script": "git show origin/main:local.txt >/dev/null 2>&1"}]
        setup += "\n\nprintf 'local work\n' > local.txt\ngit add local.txt\ngit commit -m \"Local work\"\ncd ..\ngit clone remote.git peer\ncd peer\ngit config user.email \"peer@example.com\"\ngit config user.name \"Peer\"\nprintf 'peer work\n' > peer.txt\ngit add peer.txt\ngit commit -m \"Peer work\"\ngit push origin main\ncd ../local"
    elif slug == "remote-tracking-branches":
        objective = "Fetch from `origin` so `origin/main` appears locally."
        solution_cmds = ["git fetch origin"]
        validators = [{"type": "script_passes", "description": "origin/main exists locally", "script": "git rev-parse --verify refs/remotes/origin/main >/dev/null"}]
    elif slug == "pull-with-rebase":
        objective = "Pull from `origin/main` with rebase so history stays linear."
        solution_cmds = ["git pull --rebase origin main"]
        validators = [{"type": "no_merge_commit", "branch": "HEAD", "description": "History stayed linear"}, {"type": "is_clean", "description": "Working tree is clean"}]
        setup += "\n\nprintf 'local line\n' > local.txt\ngit add local.txt\ngit commit -m \"Local work\"\ncd ..\ngit clone remote.git peer\ncd peer\ngit config user.email \"peer@example.com\"\ngit config user.name \"Peer\"\nprintf 'remote line\n' > remote.txt\ngit add remote.txt\ngit commit -m \"Remote work\"\ngit push origin main\ncd ../local"
    elif slug == "push-new-branch":
        objective = "Push `feature/ui` to `origin` and set upstream tracking."
        solution_cmds = ["git switch -c feature/ui", "printf 'ui\n' > ui.txt", "git add ui.txt", "git commit -m \"Add UI work\"", "git push -u origin feature/ui"]
        validators = [{"type": "branch_exists", "branch": "feature/ui", "description": "feature/ui exists locally"}, {"type": "script_passes", "description": "Remote branch exists", "script": "git -C ../remote.git rev-parse --verify refs/heads/feature/ui >/dev/null"}]
    elif slug == "delete-remote-branch":
        objective = "Delete the remote branch `feature/old` from `origin`."
        solution_cmds = ["git push origin --delete feature/old"]
        validators = [{"type": "script_passes", "description": "Remote branch was deleted", "script": "! git -C ../remote.git rev-parse --verify refs/heads/feature/old >/dev/null 2>&1"}]
        setup += "\n\ngit switch -c feature/old\nprintf 'old branch\n' > old.txt\ngit add old.txt\ngit commit -m \"Old branch\"\ngit push -u origin feature/old\ngit switch main"
    elif slug == "prune-stale-remotes":
        objective = "Prune stale remote-tracking references for `origin`."
        solution_cmds = ["git remote prune origin"]
        validators = [{"type": "script_passes", "description": "origin/feature/old was pruned", "script": "! git rev-parse --verify refs/remotes/origin/feature/old >/dev/null 2>&1"}]
        setup += "\n\ngit switch -c feature/old\nprintf 'old branch\n' > old.txt\ngit add old.txt\ngit commit -m \"Old branch\"\ngit push -u origin feature/old\ngit switch main\ngit push origin --delete feature/old\ngit fetch origin"
    elif slug == "track-remote-branch":
        objective = "Create a local branch that tracks `origin/feature/api`."
        solution_cmds = ["git checkout --track origin/feature/api"]
        validators = [{"type": "branch_exists", "branch": "feature/api", "description": "feature/api exists locally"}, {"type": "script_passes", "description": "feature/api tracks origin/feature/api", "script": "test \"$(git for-each-ref --format='%(upstream:short)' refs/heads/feature/api)\" = \"origin/feature/api\""}]
        setup += "\n\ncd ..\ngit clone remote.git seed2\ncd seed2\ngit config user.email \"seed@example.com\"\ngit config user.name \"Seed\"\ngit switch -c feature/api\nprintf 'api branch\n' > api.txt\ngit add api.txt\ngit commit -m \"API branch\"\ngit push -u origin feature/api\ncd ../local\ngit fetch origin"
    elif slug == "force-push-safely":
        objective = "Rewrite the local commit and force-push it safely with `--force-with-lease`."
        solution_cmds = ["git commit --amend -m \"Rewrite local commit\"", "git push --force-with-lease origin main"]
        validators = [{"type": "script_passes", "description": "Remote main has the rewritten commit message", "script": "test \"$(git -C ../remote.git log -1 --pretty=%s main)\" = \"Rewrite local commit\""}]
        setup += "\n\nprintf 'rewrite me\n' > rewrite.txt\ngit add rewrite.txt\ngit commit -m \"Old local commit\"\ngit push origin main"
    elif slug == "push-all-tags":
        objective = "Create tags `v1.0` and `v1.1`, then push all tags to `origin`."
        solution_cmds = ["git tag v1.0", "git tag v1.1", "git push --tags origin"]
        validators = [{"type": "script_passes", "description": "Remote tags exist", "script": "git -C ../remote.git rev-parse --verify refs/tags/v1.0 >/dev/null && git -C ../remote.git rev-parse --verify refs/tags/v1.1 >/dev/null"}]
    else:
        objective = f"Complete the remote workflow for `{level['title']}` inside `local/`."
        solution_cmds = ["git fetch origin"]
        validators = [{"type": "remote_exists", "name": "origin", "description": "origin remote exists"}]
    mission["description"] = "This mission uses a local bare repository to simulate a remote server."
    mission["objective"] = objective
    mission["hints"] = ["Work in the `local/` directory inside the sandbox.", "Inspect remotes with `git remote -v` and branches with `git branch -a`.", "Use the remote command named in the mission objective."]
    mission["guide"] = guide_steps("cd local", *solution_cmds)
    mission["debrief"] = debrief_text(level["title"], "Local bare repos are a great way to practice remote workflows without needing any network services.")
    mission["validators"] = validators
    return {"mission": mission, "setup": setup, "solution": solution_script(solution_cmds)}


def remote_base_setup() -> str:
    return "\n\n".join([shell_header(), "git init --bare remote.git", "git clone remote.git local", "cd local", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("README.md", "remote sandbox\n"), "git add README.md", "git commit -m \"Initial scaffold\"", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main"])


def clone_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A bare repo already exists, and your task is to create a fresh local clone from it."
    mission["objective"] = "Clone `remote.git` into a directory named `clone/`."
    mission["hints"] = ["Run the clone from the sandbox root, not inside another repo.", "Use `git clone remote.git clone`."]
    mission["guide"] = guide_steps("git clone remote.git clone")
    mission["debrief"] = debrief_text(level["title"], "Cloning gives you a working tree, object database, and a configured `origin` remote in one step.")
    mission["validators"] = [{"type": "script_passes", "description": "clone/ is a Git repository", "script": "git -C clone rev-parse --is-inside-work-tree >/dev/null"}]
    setup = "\n\n".join([shell_header(), "git init --bare remote.git", "git clone remote.git seed", "cd seed", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("README.md", "clone me\n"), "git add README.md", "git commit -m \"Initial scaffold\"", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main", "cd ..", "rm -rf seed"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git clone remote.git clone"])}


def fetch_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["repo_path"] = "local"
    mission["description"] = "The remote has new work, but the local repo has not fetched it yet."
    mission["objective"] = "Fetch from `origin` so the local repo sees `origin/main` move forward."
    mission["hints"] = ["Work in `local/`.", "Use `git fetch origin`.", "After fetching, inspect `origin/main`."]
    mission["guide"] = guide_steps("cd local", "git fetch origin")
    mission["debrief"] = debrief_text(level["title"], "Fetching updates remote-tracking refs without changing your current branch.")
    mission["validators"] = [{"type": "script_passes", "description": "origin/main points at the newest remote commit", "script": "test \"$(git log origin/main -1 --pretty=%s)\" = \"Remote update\""}]
    setup = "\n\n".join([shell_header(), "git init --bare remote.git", "git clone remote.git local", "cd local", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("README.md", "base\n"), "git add README.md", "git commit -m \"Initial scaffold\"", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main", "cd ..", "git clone remote.git peer", "cd peer", "git config user.email \"peer@example.com\"", "git config user.name \"Peer\"", file_block("remote.txt", "new remote work\n"), "git add remote.txt", "git commit -m \"Remote update\"", "git push origin main", "cd ../local"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git fetch origin"])}


def multiple_remotes_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["repo_path"] = "local"
    mission["description"] = "This sandbox simulates a fork workflow with both `origin` and `upstream`."
    mission["objective"] = "Add a second remote named `upstream` that points to `../upstream.git`."
    mission["hints"] = ["Check existing remotes first.", "Use `git remote add upstream ../upstream.git`."]
    mission["guide"] = guide_steps("cd local", "git remote add upstream ../upstream.git")
    mission["debrief"] = debrief_text(level["title"], "Multiple remotes are common when you fork a project and also track the original repository.")
    mission["validators"] = [{"type": "remote_exists", "name": "upstream", "description": "upstream remote exists"}]
    setup = "\n\n".join([shell_header(), "git init --bare remote.git", "git init --bare upstream.git", "git clone remote.git local", "cd local", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("README.md", "fork workflow\n"), "git add README.md", "git commit -m \"Initial scaffold\"", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git remote add upstream ../upstream.git"])}


def shallow_clone_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "The mission is to produce a shallow clone from a multi-commit remote history."
    mission["objective"] = "Create a shallow clone in `shallow/` with depth 1."
    mission["hints"] = ["Run the clone from the sandbox root.", "Use `git clone --depth 1 remote.git shallow`."]
    mission["guide"] = guide_steps("git clone --depth 1 remote.git shallow")
    mission["debrief"] = debrief_text(level["title"], "Shallow clones reduce history transfer cost when you only need the newest snapshot.")
    mission["validators"] = [{"type": "script_passes", "description": "shallow clone has a single visible commit", "script": "test \"$(git -C shallow rev-list --count HEAD)\" = \"1\""}]
    setup = "\n\n".join([shell_header(), "git init --bare remote.git", "git clone remote.git seed", "cd seed", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("file.txt", "1\n"), "git add file.txt", "git commit -m \"Commit 1\"", "printf '2\n' > file.txt", "git add file.txt", "git commit -m \"Commit 2\"", "printf '3\n' > file.txt", "git add file.txt", "git commit -m \"Commit 3\"", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main", "cd ..", "rm -rf seed"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git clone --depth 1 file://$PWD/remote.git shallow"])}


def push_all_tags_level(level: dict) -> dict:
    return generic_remote_level(level)


def detached_level(level: dict) -> dict:
    slug = level["slug"]
    if slug in {"what-is-detached-head", "enter-detached-head", "checkout-tag-detached", "bisect-uses-detached", "compare-detached-to-branch"}:
        return enter_detached_level(level, via_tag=slug == "checkout-tag-detached")
    if slug in {"recover-detached-commits", "lost-detached-commit", "create-branch-to-save"}:
        return recover_detached_level(level, lost=slug == "lost-detached-commit")
    if slug == "commit-in-detached-head":
        return detached_commit_level(level)
    if slug == "switch-away-cleanly":
        return switch_away_level(level)
    return enter_detached_level(level, via_tag=False)


def enter_detached_level(level: dict, via_tag: bool) -> dict:
    target = "v1.0" if via_tag else "HEAD~1"
    solution_cmd = f"git checkout {target}"
    mission = mission_base(level)
    mission["description"] = "You are on `main`, and this mission asks you to move into a detached HEAD state."
    mission["objective"] = f"Check out `{target}` so that HEAD becomes detached."
    mission["hints"] = ["A detached HEAD happens when HEAD points directly to a commit or tag.", f"Use `{solution_cmd}`."]
    mission["guide"] = guide_steps(solution_cmd)
    mission["debrief"] = debrief_text(level["title"], "Detached HEAD is safe for exploration as long as you branch before you want to keep new commits.")
    mission["validators"] = [{"type": "is_detached", "description": "HEAD is detached"}]
    setup_parts = [shell_header(), repo_init(), file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Initial scaffold\"", "printf 'v2\n' > app.txt", "git add app.txt", "git commit -m \"Second commit\""]
    if via_tag:
        setup_parts.append("git tag v1.0 HEAD~1")
    return {"mission": mission, "setup": "\n\n".join(setup_parts), "solution": solution_script([solution_cmd])}


def detached_commit_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "The repo is already detached, and you need to make a commit there."
    mission["objective"] = "While detached, add `experiment.txt` and commit it with `Detached experiment`."
    mission["hints"] = ["Stay detached.", "Create the file, stage it, and commit normally."]
    mission["guide"] = guide_steps("printf 'experiment\n' > experiment.txt", "git add experiment.txt", "git commit -m \"Detached experiment\"")
    mission["debrief"] = debrief_text(level["title"], "Git allows commits in detached HEAD; they just are not referenced by a branch automatically.")
    mission["validators"] = [{"type": "is_detached", "description": "HEAD is still detached"}, {"type": "file_exists", "path": "experiment.txt", "description": "experiment.txt exists"}, {"type": "commit_message_contains", "text": "Detached experiment", "description": "Latest commit message is correct"}]
    setup = enter_detached_level(level, False)["setup"] + "\n\ngit checkout HEAD~1"
    return {"mission": mission, "setup": setup, "solution": solution_script(["printf 'experiment\n' > experiment.txt", "git add experiment.txt", "git commit -m \"Detached experiment\""])}


def recover_detached_level(level: dict, lost: bool) -> dict:
    mission = mission_base(level)
    mission["description"] = "A useful commit exists outside any branch, and you need to rescue it."
    mission["objective"] = "Create a branch named `rescue-detached` pointing at the detached commit."
    mission["hints"] = ["Use `git branch rescue-detached` while at the detached commit, or find it with `git reflog` first.", "After the branch exists, you can switch back if you want."]
    mission["guide"] = guide_steps("git branch rescue-detached")
    mission["debrief"] = debrief_text(level["title"], "Detached commits become safe as soon as a branch or tag points to them.")
    mission["validators"] = [{"type": "branch_exists", "branch": "rescue-detached", "description": "rescue-detached exists"}, {"type": "reflog_contains", "text": "Detached experiment", "description": "Reflog still records the detached commit"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Initial scaffold\"", "printf 'v2\n' > app.txt", "git add app.txt", "git commit -m \"Second commit\"", "git checkout HEAD~1", "printf 'experiment\n' > experiment.txt", "git add experiment.txt", "git commit -m \"Detached experiment\""] + (["git switch main"] if lost else []))
    solution = solution_script(
        [
            "git reflog",
            "git branch rescue-detached \"$(git reflog --grep-reflog='Detached experiment' --format=%H -n 1)\"",
        ]
        if lost
        else ["git branch rescue-detached"]
    )
    return {"mission": mission, "setup": setup, "solution": solution}


def switch_away_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "There are uncommitted changes while HEAD is detached, and you need to leave cleanly."
    mission["objective"] = "Stash the detached changes, then switch back to `main`."
    mission["hints"] = ["Save the changes first.", "Because the pending file is untracked, include untracked files in the stash.", "Then switch back to `main`."]
    mission["guide"] = guide_steps("git stash -u", "git switch main")
    mission["debrief"] = debrief_text(level["title"], "Stash is a handy escape hatch when you want to move away from a risky working state without losing changes.")
    mission["validators"] = [{"type": "is_on_branch", "branch": "main", "description": "HEAD is on main"}, {"type": "stash_not_empty", "description": "The stash contains the saved changes"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Initial scaffold\"", "printf 'v2\n' > app.txt", "git add app.txt", "git commit -m \"Second commit\"", "git checkout HEAD~1", "printf 'dirty change\n' > dirty.txt"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git stash -u", "git switch main"])}


def rebase_level(level: dict) -> dict:
    slug = level["slug"]
    if slug in {"basic-rebase", "what-is-rebase"}:
        return basic_rebase_level(level)
    if slug == "abort-rebase":
        return abort_rebase_level(level)
    if slug == "rebase-conflict":
        return rebase_conflict_level(level)
    if slug == "skip-commit-in-rebase":
        return skip_rebase_level(level)
    if slug in {"interactive-squash", "squash-all-to-one", "interactive-fixup", "autosquash"}:
        return squash_rebase_level(level)
    if slug in {"interactive-reorder"}:
        return reorder_rebase_level(level)
    if slug in {"interactive-drop"}:
        return drop_rebase_level(level)
    if slug in {"interactive-edit", "interactive-reword"}:
        return reword_rebase_level(level)
    if slug == "rebase-onto":
        return rebase_onto_level(level)
    if slug in {"rebase-multiple-conflicts", "rebase-broken-history", "golden-rule-of-rebase", "exec-in-rebase"}:
        return basic_rebase_level(level)
    return basic_rebase_level(level)


def basic_rebase_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A feature branch is behind `main` and should be replayed on top of the latest main history."
    mission["objective"] = "Rebase `feature/rebase` onto `main` and keep history linear."
    mission["hints"] = ["Switch to the feature branch first.", "Use `git rebase main`.", "A successful result has no merge commit."]
    mission["guide"] = guide_steps("git switch feature/rebase", "git rebase main")
    mission["debrief"] = debrief_text(level["title"], "Rebase rewrites commits so they appear as if they were created on top of a new base.")
    mission["validators"] = [{"type": "is_on_branch", "branch": "feature/rebase", "description": "HEAD is on feature/rebase"}, {"type": "no_merge_commit", "branch": "HEAD", "description": "History is linear"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = rebase_setup()
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch feature/rebase", "git rebase main"])}


def abort_rebase_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A rebase is already in progress and paused on a conflict."
    mission["objective"] = "Abort the rebase and return to the original branch state."
    mission["hints"] = ["Git leaves state files during an in-progress rebase.", "Use `git rebase --abort`."]
    mission["guide"] = guide_steps("git rebase --abort")
    mission["debrief"] = debrief_text(level["title"], "Aborting a rebase is the fastest way back when you decide not to continue rewriting history.")
    mission["validators"] = [{"type": "is_on_branch", "branch": "feature/rebase", "description": "HEAD is back on feature/rebase"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = rebase_conflict_setup() + "\n\ngit checkout feature/rebase\ngit rebase main || true"
    return {"mission": mission, "setup": setup, "solution": solution_script(["git rebase --abort"])}


def rebase_conflict_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A rebase onto `main` will stop on a conflict in `app.txt`."
    mission["objective"] = "Resolve the conflict so `app.txt` ends as `value=rebase`, then continue the rebase."
    mission["hints"] = ["Start the rebase on `feature/rebase`.", "When it stops, edit `app.txt`, stage it, and run `git rebase --continue`."]
    mission["guide"] = guide_steps("git switch feature/rebase", "git rebase main", "printf 'value=rebase\n' > app.txt", "git add app.txt", "GIT_EDITOR=true git rebase --continue")
    mission["debrief"] = debrief_text(level["title"], "Rebase conflicts are resolved the same way as merge conflicts, but you continue replaying commits afterward.")
    mission["validators"] = [{"type": "is_on_branch", "branch": "feature/rebase", "description": "HEAD is on feature/rebase"}, {"type": "file_content_equals", "path": "app.txt", "text": "value=rebase", "description": "app.txt contains the resolved content"}, {"type": "is_clean", "description": "Working tree is clean"}]
    return {"mission": mission, "setup": rebase_conflict_setup(), "solution": solution_script(["git switch feature/rebase", "git rebase main || true", "printf 'value=rebase\n' > app.txt", "git add app.txt", "GIT_EDITOR=true git rebase --continue"])}


def skip_rebase_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A bad commit on the feature branch should be skipped during a rebase."
    mission["objective"] = "Rebase `feature/rebase` onto `main` and skip the commit whose message is `Broken commit`."
    mission["hints"] = ["You want to replay only the good commit on top of `main`.", "A targeted `git rebase --onto` can exclude the bad commit in one step."]
    mission["guide"] = guide_steps("git switch feature/rebase", "git rebase --onto main HEAD~1 HEAD")
    mission["debrief"] = debrief_text(level["title"], "Skipping a commit during rebase drops it from the rewritten history.")
    mission["validators"] = [{"type": "script_passes", "description": "Broken commit is gone from history", "script": "! git log --pretty=%s | grep -q '^Broken commit$'"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "git checkout -b feature/rebase", "printf 'bad\n' > bad.txt", "git add bad.txt", "git commit -m \"Broken commit\"", "printf 'good\n' > good.txt", "git add good.txt", "git commit -m \"Good commit\"", "git checkout main", "printf 'main\n' > main.txt", "git add main.txt", "git commit -m \"Main update\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch feature/rebase", "git rebase --onto main HEAD~1 HEAD"])}


def squash_rebase_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "The feature branch has several tiny commits that should become one clean commit."
    mission["objective"] = "Squash the feature branch history so only one feature commit remains on top of `main`."
    mission["hints"] = ["An interactive rebase is the usual approach.", "Any valid Git method is okay if the final history has one feature commit."]
    mission["guide"] = guide_steps("git switch feature/rebase", "git reset --soft main", "git commit -m \"Squashed feature work\"")
    mission["debrief"] = debrief_text(level["title"], "Squashing is a history-cleanup step that trades granular checkpoints for a simpler review story.")
    mission["validators"] = [{"type": "commit_count_eq", "branch": "HEAD", "count": 3, "description": "Feature branch has one rebased feature commit plus main history"}, {"type": "commit_message_contains", "text": "Squashed feature work", "description": "Latest commit message is correct"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = rebase_setup(multi_feature=True)
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch feature/rebase", "git reset --soft main", "git commit -m \"Squashed feature work\""])}


def reorder_rebase_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "Two feature commits are in the wrong order."
    mission["objective"] = "Rewrite `feature/rebase` so the latest commit message becomes `Second step`."
    mission["hints"] = ["Interactive rebase is one option.", "Any valid method is fine if the final order matches the objective."]
    mission["guide"] = guide_steps("git switch feature/rebase", "git reset --hard HEAD~2", "printf 'one\n' > one.txt", "git add one.txt", "git commit -m \"First step\"", "printf 'two\n' > two.txt", "git add two.txt", "git commit -m \"Second step\"")
    mission["debrief"] = debrief_text(level["title"], "Reordering commits is another form of history surgery that can make a change set easier to understand.")
    mission["validators"] = [{"type": "commit_message_contains", "text": "Second step", "description": "Latest commit is 'Second step'"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "git checkout -b feature/rebase", "printf 'two\n' > two.txt", "git add two.txt", "git commit -m \"Second step\"", "printf 'one\n' > one.txt", "git add one.txt", "git commit -m \"First step\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git reset --hard HEAD~2", "printf 'one\n' > one.txt", "git add one.txt", "git commit -m \"First step\"", "printf 'two\n' > two.txt", "git add two.txt", "git commit -m \"Second step\""])}


def drop_rebase_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "One commit on the feature branch should disappear from history."
    mission["objective"] = "Drop the commit whose message is `Debug print`."
    mission["hints"] = ["Interactive rebase is designed for dropping commits.", "Another option is to rewrite the branch without that commit."]
    mission["guide"] = guide_steps("git switch feature/rebase", "git reset --hard HEAD~2", "printf 'final\n' > final.txt", "git add final.txt", "git commit -m \"Final work\"")
    mission["debrief"] = debrief_text(level["title"], "Dropping commits is useful when temporary or mistaken changes should not survive in the final branch history.")
    mission["validators"] = [{"type": "script_passes", "description": "Debug print commit is gone", "script": "! git log --pretty=%s | grep -q '^Debug print$'"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "git checkout -b feature/rebase", "printf 'debug\n' > debug.txt", "git add debug.txt", "git commit -m \"Debug print\"", "printf 'final\n' > final.txt", "git add final.txt", "git commit -m \"Final work\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git reset --hard HEAD~2", "printf 'final\n' > final.txt", "git add final.txt", "git commit -m \"Final work\""])}


def reword_rebase_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "The latest feature commit message should be rewritten to something cleaner."
    mission["objective"] = "Change the latest commit message to `feat: polished commit`."
    mission["hints"] = ["`git commit --amend -m ...` works for the latest commit.", "Interactive rebase is another valid option."]
    mission["guide"] = guide_steps("git commit --amend -m \"feat: polished commit\"")
    mission["debrief"] = debrief_text(level["title"], "Rewording improves commit history without changing the snapshot itself.")
    mission["validators"] = [{"type": "commit_message_contains", "text": "feat: polished commit", "description": "Latest commit message is correct"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "printf 'work\n' > work.txt", "git add work.txt", "git commit -m \"bad message\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git commit --amend -m \"feat: polished commit\""])}


def rebase_onto_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A branch was based on the wrong parent branch and needs to be transplanted."
    mission["objective"] = "Move `feature/rebase` so it is based directly on `main` instead of `old-base`."
    mission["hints"] = ["This is a classic `git rebase --onto` use case.", "The shape is `git rebase --onto new-base old-base branch`."]
    mission["guide"] = guide_steps("git rebase --onto main old-base feature/rebase")
    mission["debrief"] = debrief_text(level["title"], "Rebase onto is precise history surgery: choose the new base, the old base boundary, and the branch to rewrite.")
    mission["validators"] = [{"type": "script_passes", "description": "feature/rebase no longer contains old-base only commit", "script": "! git log feature/rebase --pretty=%s | grep -q '^Old base work$'"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "git checkout -b old-base", "printf 'old base\n' > old.txt", "git add old.txt", "git commit -m \"Old base work\"", "git checkout -b feature/rebase", "printf 'feature\n' > feature.txt", "git add feature.txt", "git commit -m \"Feature work\"", "git checkout main", "printf 'main\n' > main.txt", "git add main.txt", "git commit -m \"Main work\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git rebase --onto main old-base feature/rebase", "git switch feature/rebase"])}


def rebase_setup(multi_feature: bool = False) -> str:
    feature_lines = ["printf 'feature\n' > feature.txt", "git add feature.txt", "git commit -m \"Feature change\""]
    if multi_feature:
        feature_lines += ["printf 'extra1\n' > one.txt", "git add one.txt", "git commit -m \"Feature step 1\"", "printf 'extra2\n' > two.txt", "git add two.txt", "git commit -m \"Feature step 2\""]
    return "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "value=base\n"), "git add app.txt", "git commit -m \"Base commit\"", "git checkout -b feature/rebase", *feature_lines, "git checkout main", "printf 'main branch\n' > main.txt", "git add main.txt", "git commit -m \"Main change\""])


def rebase_conflict_setup() -> str:
    return "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "value=base\n"), "git add app.txt", "git commit -m \"Base commit\"", "git checkout -b feature/rebase", "printf 'value=rebase\n' > app.txt", "git add app.txt", "git commit -m \"Feature change\"", "git checkout main", "printf 'value=main\n' > app.txt", "git add app.txt", "git commit -m \"Main change\""])


def stash_level(level: dict) -> dict:
    slug = level["slug"]
    if slug == "basic-stash":
        return stash_basic(level)
    if slug == "stash-with-message":
        return stash_with_message(level)
    if slug == "stash-pop":
        return stash_pop(level)
    if slug == "stash-apply":
        return stash_apply(level)
    if slug == "multiple-stashes":
        return multiple_stashes(level)
    if slug == "stash-drop":
        return stash_drop(level)
    if slug == "stash-clear":
        return stash_clear(level)
    if slug == "stash-untracked":
        return stash_untracked(level)
    if slug == "stash-branch":
        return stash_branch(level)
    return stash_conflict(level)


def stash_base_setup() -> str:
    return "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "printf 'work in progress\n' > app.txt"])


def stash_basic(level: dict) -> dict:
    return generic_stash_action(level, "Save the current modifications into the stash.", ["git stash"], [{"type": "stash_not_empty", "description": "A stash entry exists"}, {"type": "is_clean", "description": "Working tree is clean"}], stash_base_setup())


def stash_with_message(level: dict) -> dict:
    return generic_stash_action(level, "Save the current modifications with the message `WIP login`.", ["git stash push -m \"WIP login\""], [{"type": "stash_not_empty", "description": "A stash entry exists"}, {"type": "script_passes", "description": "Stash message is correct", "script": "git stash list | grep -q 'WIP login'"}], stash_base_setup())


def stash_pop(level: dict) -> dict:
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "printf 'stashed change\n' > app.txt", "git stash"])
    return generic_stash_action(level, "Pop the stash back into the working tree.", ["git stash pop"], [{"type": "stash_empty", "description": "Stash is empty"}, {"type": "file_content_equals", "path": "app.txt", "text": "stashed change", "description": "app.txt contains the restored change"}], setup)


def stash_apply(level: dict) -> dict:
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "printf 'stashed change\n' > app.txt", "git stash"])
    return generic_stash_action(level, "Apply the stash without removing it from the stash list.", ["git stash apply"], [{"type": "stash_not_empty", "description": "Stash still has an entry"}, {"type": "file_content_equals", "path": "app.txt", "text": "stashed change", "description": "app.txt contains the restored change"}], setup)


def multiple_stashes(level: dict) -> dict:
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "printf 'first\n' > app.txt", "git stash push -m \"first\"", "printf 'second\n' > app.txt", "git stash push -m \"second\""])
    return generic_stash_action(level, "Apply the older stash so `app.txt` ends with `first`.", ["git stash apply stash@{1}"], [{"type": "file_content_equals", "path": "app.txt", "text": "first", "description": "The older stash was applied"}], setup)


def stash_drop(level: dict) -> dict:
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "printf 'first\n' > app.txt", "git stash push -m \"first\"", "printf 'second\n' > app.txt", "git stash push -m \"second\""])
    return generic_stash_action(level, "Drop `stash@{1}` so only one stash entry remains.", ["git stash drop stash@{1}"], [{"type": "script_passes", "description": "Only one stash remains", "script": "test \"$(git stash list | wc -l | tr -d ' ')\" = \"1\""}], setup)


def stash_clear(level: dict) -> dict:
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "printf 'first\n' > app.txt", "git stash push -m \"first\"", "printf 'second\n' > app.txt", "git stash push -m \"second\""])
    return generic_stash_action(level, "Clear all stash entries.", ["git stash clear"], [{"type": "stash_empty", "description": "Stash list is empty"}], setup)


def stash_untracked(level: dict) -> dict:
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", file_block("scratch.txt", "untracked\n")])
    return generic_stash_action(level, "Stash the untracked file as well.", ["git stash -u"], [{"type": "stash_not_empty", "description": "A stash entry exists"}, {"type": "file_not_exists", "path": "scratch.txt", "description": "scratch.txt was stashed away"}], setup)


def stash_branch(level: dict) -> dict:
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "printf 'branch me\n' > app.txt", "git stash"])
    return generic_stash_action(level, "Create a branch named `stash-work` from the stash.", ["git stash branch stash-work"], [{"type": "branch_exists", "branch": "stash-work", "description": "stash-work exists"}, {"type": "is_on_branch", "branch": "stash-work", "description": "HEAD is on stash-work"}], setup)


def stash_conflict(level: dict) -> dict:
    return generic_stash_action(level, "Apply the stash, resolve the conflict so `app.txt` becomes `resolved stash`, then commit the result and finish cleanly.", ["git stash pop || true", "printf 'resolved stash\n' > app.txt", "git add app.txt", "git commit -m \"Resolve stash conflict\""], [{"type": "file_content_equals", "path": "app.txt", "text": "resolved stash", "description": "Conflict was resolved"}, {"type": "is_clean", "description": "Working tree is clean"}], "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "printf 'stash version\n' > app.txt", "git stash", "printf 'main version\n' > app.txt"]))


def generic_stash_action(level: dict, objective: str, solution_cmds: list[str], validators: list[dict], setup: str) -> dict:
    mission = mission_base(level)
    mission["description"] = "This level starts with work in progress that should be managed through Git stash."
    mission["objective"] = objective
    mission["hints"] = generic_hints(level["concept"])
    mission["guide"] = guide_steps(*solution_cmds)
    mission["debrief"] = debrief_text(level["title"], "Stash is a useful side shelf for changes you are not ready to commit.")
    mission["validators"] = validators
    return {"mission": mission, "setup": setup, "solution": solution_script(solution_cmds)}


def history_level(level: dict) -> dict:
    reports = {
        "log-graph": ("graph.txt", "branches=3"),
        "log-all-branches": ("all-branches.txt", "subjects=4"),
        "log-file-history": ("file-history.txt", "app_changes=2"),
        "blame": ("blame.txt", "line1=Alice"),
        "log-pickaxe": ("pickaxe.txt", "matches=1"),
        "what-is-reflog": ("reflog.txt", "entries>=3"),
        "reflog-time-syntax": ("time-syntax.txt", "supported=yes"),
        "expire-reflog": ("expire.txt", "command=git reflog expire"),
        "log-merges-only": ("merges.txt", "merges=1"),
        "log-no-merges": ("no-merges.txt", "non_merges=3"),
        "shortlog": ("shortlog.txt", "Alice 2"),
    }
    recoveries = {"reflog-after-reset", "reflog-lost-branch", "reflog-after-rebase", "dangling-commits"}
    if level["slug"] in recoveries:
        return recovery_level(level)
    filename, expected = reports.get(level["slug"], ("history-report.txt", "done=1"))
    return history_report_level(level, filename, expected)


def recovery_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "Useful history was made unreachable, and your job is to recover it."
    mission["objective"] = "Recover the lost work so `recovered.txt` exists in the current branch, then commit it with `chore: recover history`."
    mission["hints"] = ["Use `git reflog` or `git fsck --lost-found` to find the lost commit.", "Restore the file or reset to the right commit.", "Commit the recovered file when needed."]
    mission["guide"] = guide_steps("git reflog", "git checkout <lost-commit> -- recovered.txt", "git add recovered.txt", "git commit -m \"chore: recover history\"")
    mission["debrief"] = debrief_text(level["title"], "Reflog and object recovery tools are the difference between panic and a calm recovery.")
    mission["validators"] = [{"type": "file_content_equals", "path": "recovered.txt", "text": "rescued", "description": "Recovered file is present"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", file_block("recovered.txt", "rescued\n"), "git add recovered.txt", "git commit -m \"Recovery point\"", "git reset --hard HEAD~1"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git reflog", "git checkout HEAD@{1} -- recovered.txt", "git add recovered.txt", "git commit -m \"chore: recover history\""])}


def reset_revert_level(level: dict) -> dict:
    slug = level["slug"]
    if slug == "soft-reset":
        return reset_level(level, "--soft", expect_staged=True)
    if slug == "mixed-reset":
        return reset_level(level, "", expect_staged=False)
    if slug == "hard-reset":
        return hard_reset_level(level)
    if slug == "reset-single-file":
        return reset_single_file(level)
    if slug in {"revert-a-commit", "revert-no-commit", "revert-a-merge"}:
        return revert_level(level)
    if slug in {"cherry-pick", "cherry-pick-range", "cherry-pick-conflict"}:
        return cherry_pick_level(level)
    if slug == "undo-a-cherry-pick":
        return abort_cherry_pick_level(level)
    if slug == "restore-file":
        return restore_file_level(level)
    if slug == "reset-to-remote":
        return reset_to_remote_level(level)
    return reset_level(level, "--soft", expect_staged=True)


def reset_level(level: dict, mode: str, expect_staged: bool) -> dict:
    mission = mission_base(level)
    mission["description"] = "The latest commit should be removed while preserving work according to the reset mode."
    mission["objective"] = f"Run `git reset {mode} HEAD~1` and leave the repo in the expected state."
    mission["hints"] = ["Look at `git status` before and after the reset.", f"Use `git reset {mode} HEAD~1`.".strip()]
    mission["guide"] = guide_steps(f"git reset {mode} HEAD~1".strip())
    mission["debrief"] = debrief_text(level["title"], "Reset moves the branch pointer; the mode determines what happens to the index and working tree.")
    mission["validators"] = [{"type": "commit_count_eq", "branch": "HEAD", "count": 1, "description": "Branch has one commit after reset"}, {"type": "script_passes", "description": "Status matches the reset mode", "script": ("git status --porcelain | grep -q '^M  change.txt'" if expect_staged else "git status --porcelain | grep -q '^ M change.txt'")}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("change.txt", "one\n"), "git add change.txt", "git commit -m \"Base commit\"", "printf 'two\n' > change.txt", "git add change.txt", "git commit -m \"Second commit\""])
    return {"mission": mission, "setup": setup, "solution": solution_script([f"git reset {mode} HEAD~1".strip()])}


def hard_reset_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "The latest commit should be discarded completely."
    mission["objective"] = "Hard reset to `HEAD~1` so `change.txt` goes back to `one`."
    mission["hints"] = ["This is destructive, but the sandbox is safe.", "Use `git reset --hard HEAD~1`."]
    mission["guide"] = guide_steps("git reset --hard HEAD~1")
    mission["debrief"] = debrief_text(level["title"], "Hard reset moves the branch, index, and working tree together.")
    mission["validators"] = [{"type": "commit_count_eq", "branch": "HEAD", "count": 1, "description": "Branch has one commit"}, {"type": "file_content_equals", "path": "change.txt", "text": "one", "description": "File content rolled back"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("change.txt", "one\n"), "git add change.txt", "git commit -m \"Base commit\"", "printf 'two\n' > change.txt", "git add change.txt", "git commit -m \"Second commit\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git reset --hard HEAD~1"])}


def reset_single_file(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "Two files are staged, but one should be removed from the index only."
    mission["objective"] = "Unstage `debug.txt` while keeping `app.txt` staged."
    mission["hints"] = ["Use file-specific reset or restore-staged.", "Check `git status --short` afterward."]
    mission["guide"] = guide_steps("git reset HEAD debug.txt")
    mission["debrief"] = debrief_text(level["title"], "File-scoped reset changes the index for one path without touching the committed history.")
    mission["validators"] = [{"type": "script_passes", "description": "debug.txt is unstaged and app.txt is still staged", "script": "git status --porcelain | grep -q '^M  app.txt' && git status --porcelain | grep -q '^ M debug.txt'"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "one\n"), file_block("debug.txt", "one\n"), "git add app.txt debug.txt", "git commit -m \"Base commit\"", "printf 'two\n' > app.txt", "printf 'two\n' > debug.txt", "git add app.txt debug.txt"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git reset HEAD debug.txt"])}


def revert_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A commit introduced a bad change that should be undone safely."
    mission["objective"] = "Revert the latest commit so `bad.txt` disappears from the working tree."
    mission["hints"] = ["Use `git revert` to create a new inverse commit.", "Keep the repo clean when you finish."]
    mission["guide"] = guide_steps("git revert --no-edit HEAD")
    mission["debrief"] = debrief_text(level["title"], "Revert is the safe undo tool for history that may already be shared.")
    mission["validators"] = [{"type": "file_not_exists", "path": "bad.txt", "description": "bad.txt was reverted away"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", file_block("bad.txt", "bad\n"), "git add bad.txt", "git commit -m \"Introduce bad file\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git revert --no-edit HEAD"])}


def cherry_pick_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A useful commit exists on another branch and should be copied onto `main`."
    mission["objective"] = "Cherry-pick the feature commit so `picked.txt` appears on `main`."
    mission["hints"] = ["Find the commit on `feature/pick`.", "Use `git cherry-pick <hash>` from `main`."]
    mission["guide"] = guide_steps("git switch main", "git cherry-pick feature/pick")
    mission["debrief"] = debrief_text(level["title"], "Cherry-pick copies a commit's change onto your current branch as a new commit.")
    mission["validators"] = [{"type": "is_on_branch", "branch": "main", "description": "HEAD is on main"}, {"type": "file_exists", "path": "picked.txt", "description": "picked.txt was cherry-picked"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "git checkout -b feature/pick", file_block("picked.txt", "picked\n"), "git add picked.txt", "git commit -m \"Pick me\"", "git checkout main"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git switch main", "git cherry-pick feature/pick"])}


def abort_cherry_pick_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A cherry-pick has already stopped on a conflict."
    mission["objective"] = "Abort the cherry-pick and return the repo to a clean state."
    mission["hints"] = ["Use `git cherry-pick --abort`."]
    mission["guide"] = guide_steps("git cherry-pick --abort")
    mission["debrief"] = debrief_text(level["title"], "Abort commands exist for the high-risk history-editing workflows so you can unwind safely.")
    mission["validators"] = [{"type": "is_clean", "description": "Working tree is clean"}, {"type": "is_on_branch", "branch": "main", "description": "HEAD is on main"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "git checkout -b feature/pick", "printf 'feature\n' > app.txt", "git add app.txt", "git commit -m \"Feature change\"", "git checkout main", "printf 'main\n' > app.txt", "git add app.txt", "git commit -m \"Main change\"", "git cherry-pick feature/pick || true"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git cherry-pick --abort"])}


def restore_file_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "A file should be restored from an older commit without resetting the whole branch."
    mission["objective"] = "Restore `config.txt` from `HEAD~1` so it contains `stable`."
    mission["hints"] = ["Use `git restore -s HEAD~1 -- config.txt` or checkout syntax."]
    mission["guide"] = guide_steps("git restore -s HEAD~1 -- config.txt")
    mission["debrief"] = debrief_text(level["title"], "File-level restore is a precise rollback tool for single paths.")
    mission["validators"] = [{"type": "file_content_equals", "path": "config.txt", "text": "stable", "description": "config.txt was restored"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("config.txt", "stable\n"), "git add config.txt", "git commit -m \"Stable config\"", "printf 'broken\n' > config.txt", "git add config.txt", "git commit -m \"Break config\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git restore -s HEAD~1 -- config.txt"])}


def reset_to_remote_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["repo_path"] = "local"
    mission["description"] = "The local branch drifted away from the remote and should be reset back to the remote state."
    mission["objective"] = "Hard reset `main` to `origin/main`."
    mission["hints"] = ["Fetch if you need to refresh origin first.", "Use `git reset --hard origin/main`."]
    mission["guide"] = guide_steps("git reset --hard origin/main")
    mission["debrief"] = debrief_text(level["title"], "Resetting to a remote ref discards local-only commits and makes your branch match the remote exactly.")
    mission["validators"] = [{"type": "script_passes", "description": "Local HEAD matches origin/main", "script": "test \"$(git rev-parse HEAD)\" = \"$(git rev-parse origin/main)\""}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), "git init --bare remote.git", "git clone remote.git local", "cd local", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main", file_block("local.txt", "local only\n"), "git add local.txt", "git commit -m \"Local only commit\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git reset --hard origin/main"])}


def tags_level(level: dict) -> dict:
    slug = level["slug"]
    mission = mission_base(level)
    mission["description"] = "This module practices creating, inspecting, and publishing tags."
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Release commit\""])
    solution_cmds = []
    validators = []
    objective = ""
    if slug == "lightweight-tag":
        objective = "Create a lightweight tag named `v1.0`."
        solution_cmds = ["git tag v1.0"]
        validators = [{"type": "tag_exists", "tag": "v1.0", "description": "Tag v1.0 exists"}]
    elif slug == "annotated-tag":
        objective = "Create an annotated tag named `v1.0` with the message `First release`."
        solution_cmds = ["git tag -a v1.0 -m \"First release\""]
        validators = [{"type": "tag_exists", "tag": "v1.0", "description": "Tag v1.0 exists"}, {"type": "script_passes", "description": "Tag is annotated", "script": "git for-each-ref refs/tags/v1.0 --format='%(objecttype)' | grep -q tag"}]
    elif slug == "tag-past-commit":
        objective = "Tag `HEAD~1` as `v0.9`."
        solution_cmds = ["git tag v0.9 HEAD~1"]
        setup += "\n\nprintf 'v2\n' > app.txt\ngit add app.txt\ngit commit -m \"Next commit\""
        validators = [{"type": "tag_exists", "tag": "v0.9", "description": "Tag v0.9 exists"}]
    elif slug == "list-tags":
        return history_report_level(level, "tags.txt", "tags=2")
    elif slug == "show-tag":
        return history_report_level(level, "show-tag.txt", "tag=v1.0")
    elif slug == "push-a-tag":
        mission["repo_path"] = "local"
        objective = "Push tag `v1.0` to `origin`."
        solution_cmds = ["git tag v1.0", "git push origin v1.0"]
        setup = "\n\n".join([shell_header(), "git init --bare remote.git", "git clone remote.git local", "cd local", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Release commit\"", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main"])
        validators = [{"type": "script_passes", "description": "Remote tag exists", "script": "git -C ../remote.git rev-parse --verify refs/tags/v1.0 >/dev/null"}]
    elif slug == "push-all-tags":
        mission["repo_path"] = "local"
        objective = "Create tags `v1.0` and `v1.1`, then push all tags."
        solution_cmds = ["git tag v1.0", "git tag v1.1", "git push origin --tags"]
        setup = "\n\n".join([shell_header(), "git init --bare remote.git", "git clone remote.git local", "cd local", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Release commit\"", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main"])
        validators = [{"type": "script_passes", "description": "Remote tags exist", "script": "git -C ../remote.git rev-parse --verify refs/tags/v1.0 >/dev/null && git -C ../remote.git rev-parse --verify refs/tags/v1.1 >/dev/null"}]
    elif slug == "delete-local-tag":
        objective = "Delete the local tag `v0.9`."
        solution_cmds = ["git tag -d v0.9"]
        setup += "\n\ngit tag v0.9"
        validators = [{"type": "tag_not_exists", "tag": "v0.9", "description": "Tag v0.9 no longer exists"}]
    elif slug == "delete-remote-tag":
        mission["repo_path"] = "local"
        objective = "Delete remote tag `v0.9` from `origin`."
        solution_cmds = ["git push origin --delete v0.9"]
        setup = "\n\n".join([shell_header(), "git init --bare remote.git", "git clone remote.git local", "cd local", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("app.txt", "v1\n"), "git add app.txt", "git commit -m \"Release commit\"", "git tag v0.9", "git branch -M main", "git push origin main", "git -C ../remote.git symbolic-ref HEAD refs/heads/main", "git push origin v0.9"])
        validators = [{"type": "script_passes", "description": "Remote tag was deleted", "script": "! git -C ../remote.git rev-parse --verify refs/tags/v0.9 >/dev/null 2>&1"}]
    else:
        objective = "Check out tag `v1.0` so HEAD becomes detached."
        solution_cmds = ["git tag v1.0", "git checkout v1.0"]
        validators = [{"type": "is_detached", "description": "HEAD is detached"}]
    mission["objective"] = objective
    mission["hints"] = generic_hints(level["concept"])
    mission["guide"] = guide_steps(*solution_cmds)
    mission["debrief"] = debrief_text(level["title"], "Tags mark important points in history, usually releases or audit checkpoints.")
    mission["validators"] = validators
    return {"mission": mission, "setup": setup, "solution": solution_script(solution_cmds)}


def hooks_level(level: dict) -> dict:
    slug = level["slug"]
    mission = mission_base(level)
    mission["description"] = "This module practices local and server-side Git hooks inside a sandbox."
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\""])
    if slug in {"hooks-intro", "pre-commit-basic", "pre-commit-lint", "commit-msg", "prepare-commit-msg", "pre-push"}:
        hook_name = "pre-commit" if slug != "pre-push" else "pre-push"
        mission["objective"] = f"Create an executable `{hook_name}` hook that prints `hook ok`."
        mission["hints"] = ["Hooks live in `.git/hooks/`.", "Remember to make the file executable."]
        mission["guide"] = guide_steps(f"printf '#!/usr/bin/env bash\\necho hook ok\\n' > .git/hooks/{hook_name}", f"chmod +x .git/hooks/{hook_name}")
        mission["debrief"] = debrief_text(level["title"], "Hooks let you automate checks at key points in the Git workflow.")
        mission["validators"] = [{"type": "hook_exists", "name": hook_name, "description": f"{hook_name} hook exists and is executable"}, {"type": "hook_output_contains", "name": hook_name, "text": "hook ok", "description": f"{hook_name} hook prints the expected output"}]
        return {"mission": mission, "setup": setup, "solution": solution_script([f"printf '#!/usr/bin/env bash\necho hook ok\n' > .git/hooks/{hook_name}", f"chmod +x .git/hooks/{hook_name}"])}
    if slug in {"server-side-pre-receive", "server-side-update"}:
        return hooks_report(level)
    return hooks_report(level)


def hooks_report(level: dict) -> dict:
    return history_report_level(level, "hooks-report.txt", "hook=understood")


def advanced_level(level: dict) -> dict:
    slug = level["slug"]
    if "worktree" in slug:
        return worktree_level(level)
    if "submodule" in slug:
        return submodule_level(level)
    if "bisect" in slug:
        return bisect_level(level)
    return history_report_level(level, "advanced-report.txt", "done=1")


def worktree_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "You need a second working tree attached to the same repository."
    mission["objective"] = "Create a worktree at `wt-feature/` for branch `feature/worktree`."
    mission["hints"] = ["Create the branch if needed while adding the worktree.", "Use `git worktree add`."]
    mission["guide"] = guide_steps("git worktree add wt-feature -b feature/worktree")
    mission["debrief"] = debrief_text(level["title"], "Worktrees let one repository checkout multiple branches at once without cloning again.")
    mission["validators"] = [{"type": "worktree_count", "count": 2, "description": "Two worktrees are registered"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\""])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git worktree add wt-feature -b feature/worktree"])}


def submodule_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "An external repository should be linked into this repo as a submodule."
    mission["objective"] = "Add `./lib.git` as a submodule at `vendor/lib`."
    mission["hints"] = ["Git needs a separate repository to point at.", "Use `git submodule add`."]
    mission["guide"] = guide_steps("git -c protocol.file.allow=always submodule add ./lib.git vendor/lib")
    mission["debrief"] = debrief_text(level["title"], "Submodules pin one repository inside another at a specific commit.")
    mission["validators"] = [{"type": "submodule_exists", "path": "vendor/lib", "description": "vendor/lib is registered as a submodule"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("app.txt", "base\n"), "git add app.txt", "git commit -m \"Base commit\"", "git init --bare lib.git", "git clone lib.git lib-seed", "cd lib-seed", "git config user.email \"player@gitmissions.local\"", "git config user.name \"Player\"", file_block("lib.txt", "library\n"), "git add lib.txt", "git commit -m \"Initial library commit\"", "git branch -M main", "git push origin main", "git -C ../lib.git symbolic-ref HEAD refs/heads/main", "cd ..", "rm -rf lib-seed"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git -c protocol.file.allow=always submodule add ./lib.git vendor/lib"])}


def bisect_level(level: dict) -> dict:
    return history_report_level(level, "bisect.txt", "bad_commit=known")


def internals_level(level: dict) -> dict:
    return history_report_level(level, "internals.txt", "object=known")


def war_games_level(level: dict) -> dict:
    mission = mission_base(level)
    mission["description"] = "This mission combines multiple Git problems into one recovery scenario."
    mission["objective"] = "Get the repository back to a clean `main` branch, ensure `rescue.txt` exists with `recovered`, and commit it as `fix: war game recovery`."
    mission["hints"] = ["Start with `git status` and `git log --graph --all`.", "Resolve conflicts or detached state first, then create the recovery commit."]
    mission["guide"] = guide_steps("git switch main || git switch -c main", "printf 'recovered\n' > rescue.txt", "git add rescue.txt", "git commit -m \"fix: war game recovery\"")
    mission["debrief"] = debrief_text(level["title"], "War-game missions are about staying calm, inspecting state carefully, and recovering in a controlled order.")
    mission["validators"] = [{"type": "is_on_branch", "branch": "main", "description": "HEAD is on main"}, {"type": "file_content_equals", "path": "rescue.txt", "text": "recovered", "description": "rescue.txt contains the recovered content"}, {"type": "is_clean", "description": "Working tree is clean"}]
    setup = "\n\n".join([shell_header(), repo_init(), file_block("base.txt", "base\n"), "git add base.txt", "git commit -m \"Base commit\"", "git checkout -b feature/incident", "printf 'feature\n' > incident.txt", "git add incident.txt", "git commit -m \"Incident change\"", "git checkout main", "printf 'main\n' > incident.txt", "git add incident.txt", "git commit -m \"Main incident\"", "git merge feature/incident --no-edit || true"])
    return {"mission": mission, "setup": setup, "solution": solution_script(["git merge --abort || true", "git switch main || git switch -c main", "printf 'recovered\n' > rescue.txt", "git add rescue.txt", "git commit -m \"fix: war game recovery\""])}


def mission_base(level: dict) -> dict:
    return {
        "name": level["title"],
        "module": level["module_dir"],
        "level": level["level_dir"],
        "order": level["order"],
        "difficulty": level["difficulty"],
        "xp": level["xp"],
        "expected_time": estimated_time(level["module_num"]),
        "concepts": [part.strip() for part in level["concept"].split(",")],
        "common_mistakes": common_mistakes_for(level["concept"]),
    }


def generic_hints(concept: str) -> list[str]:
    return [
        f"Start with the Git command related to `{concept}`.",
        "Use `git status` often so you can see the state change.",
        "Leave the repository in the exact end state described by the mission.",
    ]


def guide_steps(*steps: str) -> str:
    lines = ["## Step-by-step Guide", ""]
    for i, step in enumerate(steps, start=1):
        lines.append(f"{i}.")
        lines.append("   ```bash")
        lines.append(f"   {step}")
        lines.append("   ```")
        lines.append("")
    return "\n".join(lines).strip()


def debrief_text(title: str, body: str) -> str:
    return f"## What Just Happened\n\n**{title}**\n\n{body}\n"


def common_mistakes_for(concept: str) -> list[str]:
    return [
        f"Running commands related to {concept} without checking `git status` first, which hides the actual repository state.",
        "Stopping after changing files but forgetting the final Git step such as `git add`, `git commit`, `git push`, or `git rebase --continue`.",
        "Using a bigger hammer than needed, like resetting the whole repository when a single file, branch, or ref was the real target.",
    ]


def solution_script(commands: list[str], comment: str | None = None) -> str:
    lines = ["#!/usr/bin/env bash", "set -e"]
    if comment:
        lines.append(f"# {comment}")
    lines.append("")
    lines.extend(commands)
    return "\n".join(lines).strip() + "\n"


def render_level(level: dict) -> dict:
    module_num = level["module_num"]
    if module_num == 1:
        return foundation_level(level)
    if module_num == 2:
        return branching_level(level)
    if module_num == 3:
        return conflict_level(level)
    if module_num == 4:
        return remote_level(level)
    if module_num == 5:
        return detached_level(level)
    if module_num == 6:
        return rebase_level(level)
    if module_num == 7:
        return stash_level(level)
    if module_num == 8:
        return history_level(level)
    if module_num == 9:
        return reset_revert_level(level)
    if module_num == 10:
        return tags_level(level)
    if module_num == 11:
        return hooks_level(level)
    if module_num == 12:
        return advanced_level(level)
    if module_num == 13:
        return internals_level(level)
    return war_games_level(level)


def main() -> None:
    levels = parse_curriculum()
    if MODULES_DIR.exists():
        shutil.rmtree(MODULES_DIR)
    MODULES_DIR.mkdir(parents=True, exist_ok=True)

    for level in levels:
        rendered = render_level(level)
        level_dir = MODULES_DIR / level["module_dir"] / level["level_dir"]
        level_dir.mkdir(parents=True, exist_ok=True)
        dump_yaml(level_dir / "mission.yaml", rendered["mission"])
        write_text(level_dir / "setup.sh", rendered["setup"], executable=True)
        write_text(level_dir / "solution.sh", rendered["solution"], executable=True)

    print(f"Generated {len(levels)} levels under {MODULES_DIR}")


if __name__ == "__main__":
    main()
