from __future__ import annotations

from rich.prompt import Prompt


def prompt_player_name(progress: dict) -> str:
    if progress.get("player_name"):
        return progress["player_name"]
    name = Prompt.ask("[bold cyan]Enter your player name[/bold cyan]", default="Player").strip() or "Player"
    progress["player_name"] = name
    return name
