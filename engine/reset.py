from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

SANDBOX_BASE = Path("/tmp/gitmissions")


def get_sandbox_path(module: str, level: str) -> Path:
    return SANDBOX_BASE / module / level


def prepare_level(module: str, level: str, level_dir: Path) -> Path:
    sandbox = get_sandbox_path(module, level)
    if sandbox.exists():
        shutil.rmtree(sandbox)
    sandbox.mkdir(parents=True, exist_ok=True)
    setup_path = level_dir / "setup.sh"
    result = subprocess.run(
        ["bash", str(setup_path), str(sandbox)],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or "setup.sh failed")
    return sandbox
