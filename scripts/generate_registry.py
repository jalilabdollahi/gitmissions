#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent
MODULES_DIR = REPO_ROOT / "modules"
OUTPUT = REPO_ROOT / "levels.json"


def main() -> None:
    registry = []
    for mission_path in sorted(MODULES_DIR.glob("module-*/level-*/mission.yaml")):
        mission = yaml.safe_load(mission_path.read_text(encoding="utf-8"))
        registry.append(
            {
                "module": mission["module"],
                "level": mission["level"],
                "name": mission["name"],
                "xp": mission["xp"],
                "difficulty": mission["difficulty"],
                "order": mission["order"],
            }
        )
    registry.sort(key=lambda item: item["order"])
    OUTPUT.write_text(json.dumps(registry, indent=2), encoding="utf-8")
    print(f"Wrote {len(registry)} levels to {OUTPUT}")


if __name__ == "__main__":
    main()
