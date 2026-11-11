from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

from engine.validator import git_env

SANDBOX_BASE = Path("/tmp/gitmissions")
SETUP_TIMEOUT = 120


class LevelSetupError(RuntimeError):
    """Raised when a level's setup.sh fails."""


def get_sandbox_path(module: str, level: str) -> Path:
    return SANDBOX_BASE / module / level


def run_setup(level_dir: Path, sandbox: Path) -> None:
    """Create a fresh sandbox and run the level's setup.sh inside it."""
    if sandbox.exists():
        shutil.rmtree(sandbox)
    sandbox.mkdir(parents=True, exist_ok=True)
    try:
        result = subprocess.run(
            ["bash", str(level_dir / "setup.sh"), str(sandbox)],
            cwd=sandbox,
            capture_output=True,
            text=True,
            check=False,
            env=git_env(),
            timeout=SETUP_TIMEOUT,
        )
    except subprocess.TimeoutExpired as exc:
        raise LevelSetupError(f"setup.sh timed out after {SETUP_TIMEOUT}s") from exc
    if result.returncode != 0:
        raise LevelSetupError(result.stderr.strip() or result.stdout.strip() or "setup.sh failed")


def prepare_level(module: str, level: str, level_dir: Path) -> Path:
    sandbox = get_sandbox_path(module, level)
    run_setup(level_dir, sandbox)
    return sandbox
