#!/usr/bin/env python3
from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from engine.validator import validate_all

MODULES_DIR = REPO_ROOT / "modules"
TMP_ROOT = Path("/tmp/gitmissions-build")

REQUIRED_KEYS = {
    "name",
    "module",
    "level",
    "order",
    "difficulty",
    "xp",
    "expected_time",
    "concepts",
    "description",
    "objective",
    "hints",
    "guide",
    "debrief",
    "common_mistakes",
    "validators",
}


def main() -> None:
    level_dirs = sorted(MODULES_DIR.glob("module-*/level-*"))
    if TMP_ROOT.exists():
        shutil.rmtree(TMP_ROOT)
    TMP_ROOT.mkdir(parents=True, exist_ok=True)

    validated = 0
    for level_dir in level_dirs:
        mission_path = level_dir / "mission.yaml"
        mission = yaml.safe_load(mission_path.read_text(encoding="utf-8"))
        missing = REQUIRED_KEYS - set(mission)
        if missing:
            raise SystemExit(f"{mission_path}: missing keys {sorted(missing)}")

        sandbox = TMP_ROOT / mission["module"] / mission["level"]
        sandbox.mkdir(parents=True, exist_ok=True)
        setup = subprocess.run(["bash", str(level_dir / "setup.sh"), str(sandbox)], capture_output=True, text=True, check=False)
        if setup.returncode != 0:
            raise SystemExit(f"{level_dir}: setup failed\n{setup.stderr or setup.stdout}")

        repo_path = sandbox / mission.get("repo_path", ".")
        solution = subprocess.run(["bash", str(level_dir / "solution.sh")], cwd=repo_path, capture_output=True, text=True, check=False)
        if solution.returncode != 0:
            raise SystemExit(f"{level_dir}: solution failed\n{solution.stderr or solution.stdout}")

        results = validate_all(repo_path, mission["validators"])
        if not all(item["passed"] for item in results):
            failures = [item["message"] for item in results if not item["passed"]]
            raise SystemExit(f"{level_dir}: validation failed: {failures}")
        validated += 1

    print(f"Validated {validated} levels successfully.")


if __name__ == "__main__":
    main()
