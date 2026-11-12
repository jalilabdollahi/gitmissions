#!/usr/bin/env python3
"""Verify every level: schema, setup, unsolved state fails, solution passes, uniqueness.

Usage:
  python3 scripts/build_levels.py                      # all levels
  python3 scripts/build_levels.py --module module-03   # levels whose module starts with this
  python3 scripts/build_levels.py --level level-042    # levels whose folder starts with this
  python3 scripts/build_levels.py --keep               # keep sandboxes for inspection
"""
from __future__ import annotations

import argparse
import difflib
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from engine.reset import LevelSetupError, run_setup  # noqa: E402
from engine.validator import git_env, validate_all  # noqa: E402

MODULES_DIR = REPO_ROOT / "modules"
SOLUTION_TIMEOUT = 120
SIMILARITY_LIMIT = 0.85

REQUIRED_KEYS = {
    "name", "module", "level", "order", "difficulty", "xp", "expected_time", "concepts",
    "description", "objective", "hints", "guide", "debrief", "common_mistakes", "validators",
}
DIFFICULTIES = {"beginner", "intermediate", "advanced", "expert"}


def _body(text: str) -> str:
    """Drop shebang/set -e/SANDBOX boilerplate so similarity compares real content."""
    skip = ("#!", "set -e", "set -eu", 'SANDBOX="$1"', 'cd "$SANDBOX"')
    return "\n".join(
        line for line in text.splitlines() if line.strip() and not line.strip().startswith(skip)
    )


def check_level(level_dir: Path, tmp_root: Path) -> tuple[list[str], dict]:
    errors: list[str] = []
    mission_path = level_dir / "mission.yaml"
    try:
        mission = yaml.safe_load(mission_path.read_text(encoding="utf-8"))
    except (OSError, yaml.YAMLError) as exc:
        return [f"mission.yaml unreadable: {exc}"], {}

    missing = REQUIRED_KEYS - set(mission)
    if missing:
        errors.append(f"missing keys {sorted(missing)}")
    if mission.get("level") != level_dir.name or mission.get("module") != level_dir.parent.name:
        errors.append("module/level keys do not match the folder names")
    if mission.get("difficulty") not in DIFFICULTIES:
        errors.append(f"difficulty must be one of {sorted(DIFFICULTIES)}")
    if len(mission.get("hints") or []) < 2:
        errors.append("needs at least 2 hints")
    if not mission.get("validators"):
        errors.append("needs at least 1 validator")
    for name in ("setup.sh", "solution.sh"):
        if not (level_dir / name).is_file():
            errors.append(f"{name} missing")
    if errors:
        return errors, mission

    sandbox = tmp_root / level_dir.parent.name / level_dir.name
    try:
        run_setup(level_dir, sandbox)
    except LevelSetupError as exc:
        return [f"setup failed: {exc}"], mission

    repo_path = (sandbox / mission.get("repo_path", ".")).resolve()
    if not repo_path.is_dir():
        return [f"repo_path {repo_path} does not exist after setup"], mission

    before = validate_all(repo_path, mission["validators"])
    if all(item["passed"] for item in before):
        errors.append("validators already pass right after setup (level is solved before the player starts)")

    try:
        solution = subprocess.run(
            ["bash", str(level_dir / "solution.sh")],
            cwd=repo_path,
            capture_output=True,
            text=True,
            check=False,
            env=git_env(),
            timeout=SOLUTION_TIMEOUT,
            stdin=subprocess.DEVNULL,
        )
    except subprocess.TimeoutExpired:
        return errors + ["solution timed out (is something waiting for input or an editor?)"], mission
    if solution.returncode != 0:
        return errors + [f"solution failed:\n{(solution.stderr or solution.stdout).strip()}"], mission

    after = validate_all(repo_path, mission["validators"])
    failures = [item["message"] for item in after if not item["passed"]]
    if failures:
        errors.append(f"validators fail after solution: {failures}")
    return errors, mission


def similarity_report(focus: set[Path]) -> list[str]:
    """Flag pairs of levels whose setup+solution+validators are near-identical."""
    signatures = {}
    for level_dir in sorted(MODULES_DIR.glob("module-*/level-*")):
        try:
            mission = yaml.safe_load((level_dir / "mission.yaml").read_text(encoding="utf-8"))
            sig = "\n".join([
                _body((level_dir / "setup.sh").read_text(encoding="utf-8")),
                _body((level_dir / "solution.sh").read_text(encoding="utf-8")),
                yaml.safe_dump(mission.get("validators"), sort_keys=True),
            ])
        except (OSError, yaml.YAMLError, AttributeError):
            continue
        signatures[level_dir] = sig

    problems = []
    items = list(signatures.items())
    for i, (dir_a, sig_a) in enumerate(items):
        for dir_b, sig_b in items[i + 1:]:
            if dir_a not in focus and dir_b not in focus:
                continue
            matcher = difflib.SequenceMatcher(None, sig_a, sig_b, autojunk=False)
            if matcher.real_quick_ratio() < SIMILARITY_LIMIT or matcher.quick_ratio() < SIMILARITY_LIMIT:
                continue
            ratio = matcher.ratio()
            if ratio >= SIMILARITY_LIMIT:
                problems.append(f"{dir_a.name} ~ {dir_b.name}: {ratio:.0%} similar")
    return problems


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--module", default="")
    parser.add_argument("--level", default="")
    parser.add_argument("--keep", action="store_true")
    parser.add_argument("--no-similarity", action="store_true")
    args = parser.parse_args()

    level_dirs = [
        d for d in sorted(MODULES_DIR.glob("module-*/level-*"))
        if d.parent.name.startswith(args.module) and d.name.startswith(args.level)
    ]
    if not level_dirs:
        raise SystemExit("No levels matched.")

    tmp_root = Path(tempfile.mkdtemp(prefix="gitmissions-build-"))
    failed = 0
    orders: dict[int, str] = {}
    try:
        for level_dir in level_dirs:
            errors, mission = check_level(level_dir, tmp_root)
            order = mission.get("order") if isinstance(mission, dict) else None
            if order in orders:
                errors.append(f"order {order} also used by {orders[order]}")
            if order is not None:
                orders[order] = level_dir.name
            if errors:
                failed += 1
                print(f"FAIL {level_dir.parent.name}/{level_dir.name}")
                for error in errors:
                    print("     " + error.replace("\n", "\n     "))
    finally:
        if args.keep:
            print(f"Sandboxes kept in {tmp_root}")
        else:
            shutil.rmtree(tmp_root, ignore_errors=True)

    similar = [] if args.no_similarity else similarity_report(set(level_dirs))
    for line in similar:
        print(f"SIMILAR {line}")

    print(f"{len(level_dirs) - failed}/{len(level_dirs)} levels passed; {len(similar)} near-duplicate pairs.")
    if failed or similar:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
