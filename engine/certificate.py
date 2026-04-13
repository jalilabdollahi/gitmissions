from __future__ import annotations

from datetime import date
from pathlib import Path

from rich import box
from rich.panel import Panel
from rich.text import Text

from engine.ui import console


def generate_certificate(module_name: str, player_name: str, module_xp: int) -> str:
    return (
        "GITMISSIONS CERTIFICATE\n"
        f"Player: {player_name}\n"
        f"Module: {module_name}\n"
        f"XP: {module_xp}\n"
        f"Date: {date.today().isoformat()}\n"
    )


def save_certificate(repo_root: Path, module_name: str, content: str) -> Path:
    cert_dir = repo_root / "certificates"
    cert_dir.mkdir(parents=True, exist_ok=True)
    slug = module_name.replace("/", "-").replace(" ", "-")
    path = cert_dir / f"{slug}.txt"
    path.write_text(content, encoding="utf-8")
    return path


def render_certificate(module_name: str, player_name: str, module_xp: int) -> None:
    text = Text(
        f"Certificate of Completion\n\n{player_name}\ncompleted {module_name}\nand earned {module_xp} XP",
        justify="center",
        style="bold green",
    )
    console.print(Panel(text, box=box.DOUBLE, border_style="green"))
