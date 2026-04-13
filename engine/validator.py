from __future__ import annotations

import os
import subprocess
import tempfile
from pathlib import Path


def run_git(sandbox: Path, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", "-C", str(sandbox)] + list(args),
        capture_output=True,
        text=True,
        check=False,
    )


def _message(config: dict) -> str:
    return config.get("description", config["type"])


def _result(config: dict, passed: bool) -> dict:
    return {"name": config["type"], "passed": passed, "message": _message(config)}


def validate_all(sandbox: Path, validators: list[dict]) -> list[dict]:
    handlers = {
        "branch_exists": _branch_exists,
        "branch_not_exists": _branch_not_exists,
        "commit_message_contains": _commit_message_contains,
        "file_exists": _file_exists,
        "file_not_exists": _file_not_exists,
        "file_content_contains": _file_content_contains,
        "file_content_equals": _file_content_equals,
        "no_conflict_markers": _no_conflict_markers,
        "is_clean": _is_clean,
        "is_on_branch": _is_on_branch,
        "is_detached": _is_detached,
        "tag_exists": _tag_exists,
        "tag_not_exists": _tag_not_exists,
        "commit_count_gte": _commit_count_gte,
        "commit_count_eq": _commit_count_eq,
        "merge_commit_exists": _merge_commit_exists,
        "no_merge_commit": _no_merge_commit,
        "hook_exists": _hook_exists,
        "hook_output_contains": _hook_output_contains,
        "remote_exists": _remote_exists,
        "ahead_of": _ahead_of,
        "stash_empty": _stash_empty,
        "stash_not_empty": _stash_not_empty,
        "reflog_contains": _reflog_contains,
        "submodule_exists": _submodule_exists,
        "worktree_count": _worktree_count,
        "script_passes": _script_passes,
    }
    results = []
    for validator in validators:
        handler = handlers.get(validator["type"])
        if not handler:
            results.append(_result(validator, False))
            continue
        results.append(handler(sandbox, validator))
    return results


def _branch_exists(sandbox: Path, config: dict) -> dict:
    branch = config["branch"]
    result = run_git(sandbox, "rev-parse", "--verify", f"refs/heads/{branch}")
    return _result(config, result.returncode == 0)


def _branch_not_exists(sandbox: Path, config: dict) -> dict:
    return _result(config, not _branch_exists(sandbox, config)["passed"])


def _commit_message_contains(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "log", "-1", "--pretty=%B")
    return _result(config, config["text"] in result.stdout)


def _file_exists(sandbox: Path, config: dict) -> dict:
    return _result(config, (sandbox / config["path"]).exists())


def _file_not_exists(sandbox: Path, config: dict) -> dict:
    return _result(config, not (sandbox / config["path"]).exists())


def _file_content_contains(sandbox: Path, config: dict) -> dict:
    path = sandbox / config["path"]
    content = path.read_text(encoding="utf-8") if path.exists() else ""
    return _result(config, config["text"] in content)


def _file_content_equals(sandbox: Path, config: dict) -> dict:
    path = sandbox / config["path"]
    content = path.read_text(encoding="utf-8") if path.exists() else ""
    return _result(config, content.strip() == config["text"].strip())


def _no_conflict_markers(sandbox: Path, config: dict) -> dict:
    tracked = run_git(sandbox, "ls-files")
    for rel in [line.strip() for line in tracked.stdout.splitlines() if line.strip()]:
        path = sandbox / rel
        if path.exists():
            content = path.read_text(encoding="utf-8", errors="ignore")
            if "<<<<<<<" in content or ">>>>>>>" in content or "=======" in content:
                return _result(config, False)
    return _result(config, True)


def _is_clean(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "status", "--porcelain")
    return _result(config, result.stdout.strip() == "")


def _is_on_branch(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "symbolic-ref", "--short", "HEAD")
    if result.returncode != 0:
        return _result(config, False)
    allowed = [config["branch"]] + config.get("alt_branches", [])
    return _result(config, result.stdout.strip() in allowed)


def _is_detached(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "symbolic-ref", "HEAD")
    return _result(config, result.returncode != 0)


def _tag_exists(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "rev-parse", "--verify", f"refs/tags/{config['tag']}")
    return _result(config, result.returncode == 0)


def _tag_not_exists(sandbox: Path, config: dict) -> dict:
    return _result(config, not _tag_exists(sandbox, config)["passed"])


def _commit_count_gte(sandbox: Path, config: dict) -> dict:
    branch = config.get("branch", "HEAD")
    result = run_git(sandbox, "rev-list", "--count", branch)
    count = int((result.stdout or "0").strip() or "0")
    return _result(config, count >= int(config["count"]))


def _commit_count_eq(sandbox: Path, config: dict) -> dict:
    branch = config.get("branch", "HEAD")
    result = run_git(sandbox, "rev-list", "--count", branch)
    count = int((result.stdout or "0").strip() or "0")
    return _result(config, count == int(config["count"]))


def _merge_commit_exists(sandbox: Path, config: dict) -> dict:
    branch = config.get("branch", "HEAD")
    result = run_git(sandbox, "log", "--merges", "--oneline", branch)
    return _result(config, bool(result.stdout.strip()))


def _no_merge_commit(sandbox: Path, config: dict) -> dict:
    return _result(config, not _merge_commit_exists(sandbox, config)["passed"])


def _hook_exists(sandbox: Path, config: dict) -> dict:
    hook = sandbox / ".git" / "hooks" / config["name"]
    return _result(config, hook.exists() and os.access(hook, os.X_OK))


def _hook_output_contains(sandbox: Path, config: dict) -> dict:
    hook = sandbox / ".git" / "hooks" / config["name"]
    if not hook.exists():
        return _result(config, False)
    result = subprocess.run([str(hook)], cwd=sandbox, capture_output=True, text=True, check=False)
    return _result(config, config["text"] in result.stdout + result.stderr)


def _remote_exists(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "remote")
    return _result(config, config["name"] in result.stdout.split())


def _ahead_of(sandbox: Path, config: dict) -> dict:
    result = run_git(
        sandbox,
        "rev-list",
        "--left-right",
        "--count",
        f"{config['other']}...{config.get('branch', 'HEAD')}",
    )
    try:
        behind, ahead = [int(part) for part in result.stdout.strip().split()]
    except ValueError:
        return _result(config, False)
    return _result(config, ahead >= int(config["count"]) and behind >= 0)


def _stash_empty(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "stash", "list")
    return _result(config, result.stdout.strip() == "")


def _stash_not_empty(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "stash", "list")
    return _result(config, result.stdout.strip() != "")


def _reflog_contains(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "reflog", "--all")
    return _result(config, config["text"] in result.stdout)


def _submodule_exists(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "config", "--file", ".gitmodules", "--get-regexp", "path")
    return _result(config, config["path"] in result.stdout)


def _worktree_count(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "worktree", "list", "--porcelain")
    count = sum(1 for line in result.stdout.splitlines() if line.startswith("worktree "))
    return _result(config, count == int(config["count"]))


def _script_passes(sandbox: Path, config: dict) -> dict:
    with tempfile.NamedTemporaryFile("w", delete=False, suffix=".sh") as handle:
        handle.write("#!/usr/bin/env bash\nset -e\n")
        handle.write(config["script"])
        temp_path = Path(handle.name)
    temp_path.chmod(0o755)
    try:
        result = subprocess.run([str(temp_path)], cwd=sandbox, capture_output=True, text=True, check=False)
        return _result(config, result.returncode == 0)
    finally:
        temp_path.unlink(missing_ok=True)
