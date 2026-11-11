from __future__ import annotations

import os
import re
import subprocess
import tempfile
from pathlib import Path

# Seconds any single validator subprocess may run before it is treated as a failure.
VALIDATOR_TIMEOUT = 30

_CONFLICT_MARKER = re.compile(r"^(<{7}( .*)?|={7}|>{7}( .*)?|\|{7}( .*)?)$", re.MULTILINE)


def git_env(extra: dict | None = None) -> dict:
    """Environment for engine-run git commands (setup, validation, build).

    The player's global/system git config is ignored so that options such as
    core.hooksPath, init.defaultBranch, pull.rebase or commit.gpgsign cannot
    change how a level is set up or judged. Player shell commands do NOT use
    this environment.
    """
    env = dict(os.environ)
    env["GIT_CONFIG_NOSYSTEM"] = "1"
    env["GIT_CONFIG_GLOBAL"] = os.devnull
    env["GIT_TERMINAL_PROMPT"] = "0"
    env.setdefault("GIT_AUTHOR_NAME", "Player")
    env.setdefault("GIT_AUTHOR_EMAIL", "player@gitmissions.local")
    env.setdefault("GIT_COMMITTER_NAME", "Player")
    env.setdefault("GIT_COMMITTER_EMAIL", "player@gitmissions.local")
    env["GIT_EDITOR"] = "true"
    env["GIT_SEQUENCE_EDITOR"] = "true"
    env["GIT_MERGE_AUTOEDIT"] = "no"
    if extra:
        env.update(extra)
    return env


def run_git(sandbox: Path, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", "-C", str(sandbox)] + list(args),
        capture_output=True,
        text=True,
        check=False,
        env=git_env(),
        timeout=VALIDATOR_TIMEOUT,
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
        "commit_message_equals": _commit_message_equals,
        "file_exists": _file_exists,
        "file_not_exists": _file_not_exists,
        "file_content_contains": _file_content_contains,
        "file_content_equals": _file_content_equals,
        "file_tracked": _file_tracked,
        "file_not_tracked": _file_not_tracked,
        "file_ignored": _file_ignored,
        "no_conflict_markers": _no_conflict_markers,
        "no_unmerged_files": _no_unmerged_files,
        "is_clean": _is_clean,
        "is_on_branch": _is_on_branch,
        "is_detached": _is_detached,
        "tag_exists": _tag_exists,
        "tag_not_exists": _tag_not_exists,
        "tag_is_annotated": _tag_is_annotated,
        "commit_count_gte": _commit_count_gte,
        "commit_count_eq": _commit_count_eq,
        "merge_commit_exists": _merge_commit_exists,
        "no_merge_commit": _no_merge_commit,
        "hook_exists": _hook_exists,
        "hook_output_contains": _hook_output_contains,
        "remote_exists": _remote_exists,
        "ahead_of": _ahead_of,
        "is_ancestor": _is_ancestor,
        "refs_equal": _refs_equal,
        "config_equals": _config_equals,
        "stash_empty": _stash_empty,
        "stash_not_empty": _stash_not_empty,
        "stash_count_eq": _stash_count_eq,
        "reflog_contains": _reflog_contains,
        "submodule_exists": _submodule_exists,
        "worktree_count": _worktree_count,
        "script_passes": _script_passes,
    }
    results = []
    for validator in validators:
        handler = handlers.get(validator.get("type", ""))
        if not handler:
            results.append(_result(validator, False))
            continue
        try:
            results.append(handler(sandbox, validator))
        except (OSError, ValueError, KeyError, subprocess.TimeoutExpired):
            results.append(_result(validator, False))
    return results


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.is_file() else ""


def _branch_exists(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "rev-parse", "--verify", "--quiet", f"refs/heads/{config['branch']}")
    return _result(config, result.returncode == 0)


def _branch_not_exists(sandbox: Path, config: dict) -> dict:
    return _result(config, not _branch_exists(sandbox, config)["passed"])


def _commit_message(sandbox: Path, config: dict) -> str | None:
    result = run_git(sandbox, "log", "-1", "--pretty=%B", config.get("ref", "HEAD"))
    return result.stdout if result.returncode == 0 else None


def _commit_message_contains(sandbox: Path, config: dict) -> dict:
    message = _commit_message(sandbox, config)
    return _result(config, message is not None and config["text"] in message)


def _commit_message_equals(sandbox: Path, config: dict) -> dict:
    message = _commit_message(sandbox, config)
    return _result(config, message is not None and message.strip() == config["text"].strip())


def _file_exists(sandbox: Path, config: dict) -> dict:
    return _result(config, (sandbox / config["path"]).exists())


def _file_not_exists(sandbox: Path, config: dict) -> dict:
    return _result(config, not (sandbox / config["path"]).exists())


def _file_content_contains(sandbox: Path, config: dict) -> dict:
    return _result(config, config["text"] in _read(sandbox / config["path"]))


def _file_content_equals(sandbox: Path, config: dict) -> dict:
    path = sandbox / config["path"]
    return _result(config, path.is_file() and _read(path).strip() == config["text"].strip())


def _file_tracked(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "ls-files", "--error-unmatch", "--", config["path"])
    return _result(config, result.returncode == 0)


def _file_not_tracked(sandbox: Path, config: dict) -> dict:
    return _result(config, not _file_tracked(sandbox, config)["passed"])


def _file_ignored(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "check-ignore", "-q", "--no-index", "--", config["path"])
    return _result(config, result.returncode == 0)


def _no_conflict_markers(sandbox: Path, config: dict) -> dict:
    tracked = run_git(sandbox, "ls-files", "-z")
    for rel in [item for item in tracked.stdout.split("\0") if item]:
        content = _read(sandbox / rel)
        if _CONFLICT_MARKER.search(content):
            return _result(config, False)
    return _result(config, True)


def _no_unmerged_files(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "ls-files", "--unmerged")
    return _result(config, result.returncode == 0 and result.stdout.strip() == "")


def _is_clean(sandbox: Path, config: dict) -> dict:
    args = ["status", "--porcelain"]
    if config.get("ignore_untracked"):
        args.append("--untracked-files=no")
    result = run_git(sandbox, *args)
    return _result(config, result.returncode == 0 and result.stdout.strip() == "")


def _is_on_branch(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "symbolic-ref", "--short", "HEAD")
    if result.returncode != 0:
        return _result(config, False)
    allowed = [config["branch"]] + config.get("alt_branches", [])
    return _result(config, result.stdout.strip() in allowed)


def _is_detached(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "symbolic-ref", "-q", "HEAD")
    return _result(config, result.returncode != 0)


def _tag_exists(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "rev-parse", "--verify", "--quiet", f"refs/tags/{config['tag']}")
    return _result(config, result.returncode == 0)


def _tag_not_exists(sandbox: Path, config: dict) -> dict:
    return _result(config, not _tag_exists(sandbox, config)["passed"])


def _tag_is_annotated(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "cat-file", "-t", f"refs/tags/{config['tag']}")
    return _result(config, result.returncode == 0 and result.stdout.strip() == "tag")


def _count(sandbox: Path, config: dict) -> int:
    result = run_git(sandbox, "rev-list", "--count", config.get("branch", "HEAD"))
    if result.returncode != 0:
        return -1
    return int(result.stdout.strip() or "0")


def _commit_count_gte(sandbox: Path, config: dict) -> dict:
    return _result(config, _count(sandbox, config) >= int(config["count"]))


def _commit_count_eq(sandbox: Path, config: dict) -> dict:
    return _result(config, _count(sandbox, config) == int(config["count"]))


def _merge_commit_exists(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "log", "--merges", "--oneline", config.get("branch", "HEAD"))
    return _result(config, result.returncode == 0 and bool(result.stdout.strip()))


def _no_merge_commit(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "log", "--merges", "--oneline", config.get("branch", "HEAD"))
    return _result(config, result.returncode == 0 and not result.stdout.strip())


def _hooks_dir(sandbox: Path) -> Path:
    result = run_git(sandbox, "rev-parse", "--git-path", "hooks")
    hooks = Path(result.stdout.strip() or ".git/hooks")
    return hooks if hooks.is_absolute() else sandbox / hooks


def _hook_exists(sandbox: Path, config: dict) -> dict:
    hook = _hooks_dir(sandbox) / config["name"]
    return _result(config, hook.is_file() and os.access(hook, os.X_OK))


def _hook_output_contains(sandbox: Path, config: dict) -> dict:
    """Run a hook directly. Optional keys: args (list), stdin (str), expect_exit (int)."""
    hook = _hooks_dir(sandbox) / config["name"]
    if not (hook.is_file() and os.access(hook, os.X_OK)):
        return _result(config, False)
    result = subprocess.run(
        [str(hook)] + [str(arg) for arg in config.get("args", [])],
        cwd=sandbox,
        input=config.get("stdin", ""),
        capture_output=True,
        text=True,
        check=False,
        env=git_env(),
        timeout=VALIDATOR_TIMEOUT,
    )
    passed = config["text"] in result.stdout + result.stderr
    if "expect_exit" in config:
        passed = passed and result.returncode == int(config["expect_exit"])
    return _result(config, passed)


def _remote_exists(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "remote")
    return _result(config, config["name"] in result.stdout.split())


def _ahead_of(sandbox: Path, config: dict) -> dict:
    result = run_git(
        sandbox, "rev-list", "--left-right", "--count", f"{config['other']}...{config.get('branch', 'HEAD')}"
    )
    try:
        behind, ahead = [int(part) for part in result.stdout.strip().split()]
    except ValueError:
        return _result(config, False)
    passed = ahead >= int(config["count"])
    if "behind" in config:
        passed = passed and behind == int(config["behind"])
    return _result(config, passed)


def _is_ancestor(sandbox: Path, config: dict) -> dict:
    """`ancestor` is reachable from `descendant` (default HEAD)."""
    result = run_git(sandbox, "merge-base", "--is-ancestor", config["ancestor"], config.get("descendant", "HEAD"))
    return _result(config, result.returncode == 0)


def _refs_equal(sandbox: Path, config: dict) -> dict:
    left = run_git(sandbox, "rev-parse", "--verify", "--quiet", f"{config['left']}^{{commit}}")
    right = run_git(sandbox, "rev-parse", "--verify", "--quiet", f"{config['right']}^{{commit}}")
    passed = left.returncode == 0 and right.returncode == 0 and left.stdout.strip() == right.stdout.strip()
    return _result(config, passed)


def _config_equals(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "config", "--local", "--get", config["key"])
    return _result(config, result.returncode == 0 and result.stdout.strip() == str(config["value"]))


def _stash_list(sandbox: Path) -> list[str]:
    result = run_git(sandbox, "stash", "list")
    return [line for line in result.stdout.splitlines() if line.strip()]


def _stash_empty(sandbox: Path, config: dict) -> dict:
    return _result(config, not _stash_list(sandbox))


def _stash_not_empty(sandbox: Path, config: dict) -> dict:
    return _result(config, bool(_stash_list(sandbox)))


def _stash_count_eq(sandbox: Path, config: dict) -> dict:
    return _result(config, len(_stash_list(sandbox)) == int(config["count"]))


def _reflog_contains(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "reflog", "--all")
    return _result(config, config["text"] in result.stdout)


def _submodule_exists(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "config", "--file", ".gitmodules", "--get-regexp", r"submodule\..*\.path")
    paths = [line.split(" ", 1)[1].strip() for line in result.stdout.splitlines() if " " in line]
    return _result(config, config["path"] in paths)


def _worktree_count(sandbox: Path, config: dict) -> dict:
    result = run_git(sandbox, "worktree", "list", "--porcelain")
    count = sum(1 for line in result.stdout.splitlines() if line.startswith("worktree "))
    return _result(config, count == int(config["count"]))


def _script_passes(sandbox: Path, config: dict) -> dict:
    """Run a bash snippet in the repo; exit code 0 means pass. Runs with `set -e`."""
    with tempfile.NamedTemporaryFile("w", delete=False, suffix=".sh") as handle:
        handle.write("#!/usr/bin/env bash\nset -e\n")
        handle.write(config["script"])
        temp_path = Path(handle.name)
    temp_path.chmod(0o755)
    try:
        result = subprocess.run(
            ["bash", str(temp_path)],
            cwd=sandbox,
            capture_output=True,
            text=True,
            check=False,
            env=git_env(),
            timeout=VALIDATOR_TIMEOUT,
        )
        return _result(config, result.returncode == 0)
    finally:
        temp_path.unlink(missing_ok=True)
