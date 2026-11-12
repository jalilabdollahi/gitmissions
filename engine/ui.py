from __future__ import annotations

from datetime import datetime

from rich import box
from rich.console import Console, Group
from rich.markdown import Markdown
from rich.panel import Panel
from rich.prompt import Prompt
from rich.syntax import Syntax
from rich.table import Table
from rich.text import Text

console = Console()

DIFFICULTY_STYLE = {
    "beginner": "bold green",
    "intermediate": "bold yellow",
    "advanced": "bold red",
    "expert": "bold magenta",
}

_LOGO = """\
  ██████╗ ██╗████████╗███╗   ███╗██╗███████╗███████╗██╗ ██████╗ ███╗   ██╗███████╗
 ██╔════╝ ██║╚══██╔══╝████╗ ████║██║██╔════╝██╔════╝██║██╔═══██╗████╗  ██║██╔════╝
 ██║  ███╗██║   ██║   ██╔████╔██║██║███████╗███████╗██║██║   ██║██╔██╗ ██║███████╗
 ██║   ██║██║   ██║   ██║╚██╔╝██║██║╚════██║╚════██║██║██║   ██║██║╚██╗██║╚════██║
 ╚██████╔╝██║   ██║   ██║ ╚═╝ ██║██║███████║███████║██║╚██████╔╝██║ ╚████║███████║
  ╚═════╝ ╚═╝   ╚═╝   ╚═╝     ╚═╝╚═╝╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
"""

_MENU_ITEMS = [
    ("1", "check"), ("w", "watch"), ("2", "hint"), ("3", "solution"),
    ("4", "guide"), ("5", "debrief"), ("6", "reset"), ("7", "skip"),
    ("8", "status"), ("9", "help"), ("g", "handbook"), ("q", "quit"),
]

def _difficulty_badge(difficulty: str) -> Text:
    style = DIFFICULTY_STYLE.get(difficulty, "bold white")
    return Text(f"[{difficulty.upper()}]", style=style)


def _progress_bar(current: int, total: int, width: int = 20) -> Text:
    bar = Text()
    if total <= 0:
        bar.append("─" * width, style="grey35")
        return bar
    filled = max(0, min(width, int(width * (current / total))))
    bar.append("█" * filled, style="green")
    bar.append("░" * (width - filled), style="grey35")
    return bar


def _short_module(name: str) -> str:
    """'module-01-foundations' → '01 Foundations'"""
    parts = name.split("-", 2)
    if len(parts) >= 3:
        return f"{parts[1]} {parts[2].replace('-', ' ').title()}"
    return name.replace("-", " ").title()


def show_menu_bar() -> None:
    """Print a compact one-line menu."""
    text = Text()
    for i, (key, cmd) in enumerate(_MENU_ITEMS):
        if i:
            text.append("  ", style="dim")
        text.append(f"[{key}]", style="bold yellow")
        text.append(cmd, style="cyan")
    console.print(text)


def show_progress_summary(progress: dict, levels_registry: list[dict], current_level_name: str | None = None) -> None:
    completed = len(progress.get("completed_levels", []))
    total = len(levels_registry)
    xp = progress.get("total_xp", 0)
    player = progress.get("player_name") or "Player"
    percent = int((completed / total) * 100) if total else 0

    line = Text()
    line.append(f"  {player}", style="bold cyan")
    line.append(f"  ✦ {xp} XP", style="bold green")
    line.append(f"  Completed {completed}/{total} ({percent}%)  ", style="white")
    line.append_text(_progress_bar(completed, total, width=20))
    if current_level_name:
        line.append(f"  {current_level_name}", style="dim white")
    console.print(line)
    console.print()


def show_welcome(player_name: str, total_xp: int, current_module: str) -> None:
    body = Group(
        Text(_LOGO, style="bold green"),
        Text("Learn Git by breaking it — then fixing it.", style="bold yellow"),
        Text(""),
        Text(f"Player: {player_name or 'Player'}    XP: {total_xp}", style="bold cyan"),
        Text(f"Current module: {_short_module(current_module)}", style="white"),
        Text(""),
        Text("Shell commands (git, ls, cd, cat, …) work directly in this prompt.", style="dim"),
        Text("Type 'help' or press 9 for game commands.", style="dim"),
    )
    console.print(Panel(body, border_style="cyan", box=box.ROUNDED, padding=(1, 2)))


def show_mission_briefing(
    mission: dict,
    level_num: int,
    total_levels: int,
    sandbox_path: str,
) -> None:
    concepts = " · ".join(mission.get("concepts", []))
    badge = _difficulty_badge(mission.get("difficulty", "beginner"))
    lines = [
        Text.assemble(
            (f"MISSION {level_num:03d}/{total_levels:03d}  ", "bold white"),
            (mission["name"], "bold"),
            ("  ", ""),
            badge,
        ),
        Text(""),
        Text("SITUATION", style="bold yellow"),
        Text(mission.get("description", "").strip(), style="white"),
        Text(""),
        Text("OBJECTIVE", style="bold yellow"),
        Text(mission.get("objective", "").strip(), style="white"),
        Text(""),
        Text(f"CONCEPTS: {concepts}", style="cyan"),
        Text(
            f"XP: {mission.get('xp', 0)}   ESTIMATED: {mission.get('expected_time', '?')}",
            style="bold green",
        ),
        Text(""),
        Text.assemble(("SANDBOX: ", "dim"), (sandbox_path, "bold white")),
    ]
    console.print(Panel(Group(*lines), border_style="cyan", box=box.ROUNDED))


def show_hint(hint_text: str, hint_num: int, total_hints: int) -> None:
    console.print(
        Panel(
            Text(hint_text, style="white"),
            title=f"[yellow]HINT {hint_num}/{total_hints}[/yellow]",
            border_style="yellow",
            box=box.ROUNDED,
        )
    )


def show_all_hints_used(total: int) -> None:
    console.print(f"[yellow]All {total} hints revealed. Try 'guide' (4) for a walkthrough or 'solution' (3).[/yellow]")


def show_solution(solution_content: str) -> None:
    syntax = Syntax(solution_content.strip(), "bash", theme="monokai", line_numbers=False)
    console.print(Panel(syntax, title="[cyan]REFERENCE SOLUTION[/cyan]", border_style="cyan", box=box.ROUNDED))


def _show_paged_markdown(title: str, content: str, border_style: str = "cyan", lines_per_page: int = 22) -> None:
    lines = content.strip().splitlines()
    if not lines:
        console.print(Panel(Markdown("No content available."), title=title, border_style=border_style, box=box.ROUNDED))
        return

    total_pages = (len(lines) + lines_per_page - 1) // lines_per_page
    for page_index in range(total_pages):
        start = page_index * lines_per_page
        end = start + lines_per_page
        page_content = "\n".join(lines[start:end])
        console.clear()
        console.print(
            Panel(
                Markdown(page_content),
                title=f"{title} [dim]({page_index + 1}/{total_pages})[/dim]",
                border_style=border_style,
                box=box.ROUNDED,
            )
        )
        if page_index < total_pages - 1:
            action = Prompt.ask("[dim]Press Enter for next page or type q to stop[/dim]", default="")
            if action.strip().lower() == "q":
                break


def show_guide(guide_text: str) -> None:
    _show_paged_markdown("[cyan]GUIDE[/cyan]", guide_text, border_style="cyan")


def show_debrief(debrief_text: str, common_mistakes: list[str] | None = None) -> None:
    combined = debrief_text.strip()
    if common_mistakes:
        mistake_lines = ["## Common Mistakes", ""]
        for item in common_mistakes:
            mistake_lines.append(f"- {item}")
        combined = combined + "\n\n" + "\n".join(mistake_lines)
    _show_paged_markdown("[cyan]POST-MISSION DEBRIEF[/cyan]", combined, border_style="cyan")


def show_victory(mission_name: str, xp_earned: int, time_taken: str, next_mission: str | None) -> None:
    body = Group(
        Text(f"  ✓  {mission_name}", style="bold green"),
        Text(f"  +{xp_earned} XP    {time_taken}", style="green"),
        Text(""),
        Text(f"  Next: {next_mission}" if next_mission else "  Campaign complete!", style="white"),
    )
    console.print(Panel(body, title="[bold green]MISSION COMPLETE[/bold green]", border_style="green", box=box.ROUNDED))


def show_check_results(results: list[dict]) -> None:
    all_passed = all(r["passed"] for r in results)
    table = Table(show_header=False, box=box.SIMPLE, expand=True, padding=(0, 1))
    table.add_column("status", width=3)
    table.add_column("message")
    for result in results:
        icon = "[green]✓[/green]" if result["passed"] else "[red]✗[/red]"
        style = "white" if result["passed"] else "red"
        table.add_row(icon, Text(result["message"], style=style))

    if all_passed:
        title = "[bold green]PASS[/bold green]"
        border = "green"
    else:
        title = "[bold red]FAIL[/bold red] [dim]— type 'hint' for a clue[/dim]"
        border = "red"
    console.print(Panel(table, title=title, border_style=border, box=box.ROUNDED))


def show_status(progress: dict, levels_registry: list[dict]) -> None:
    completed = set(progress.get("completed_levels", []))
    skipped = set(progress.get("skipped_levels", [])) - completed
    modules: dict[str, list[dict]] = {}
    for entry in levels_registry:
        modules.setdefault(entry["module"], []).append(entry)

    table = Table(box=box.SIMPLE_HEAVY, expand=True, header_style="bold cyan", padding=(0, 1))
    table.add_column("Module")
    table.add_column("Done", justify="right")
    table.add_column("Skipped", justify="right")
    table.add_column("XP", justify="right")
    table.add_column("Progress")

    for module_name, entries in sorted(modules.items()):
        done = sum(1 for item in entries if item["level"] in completed)
        skip_count = sum(1 for item in entries if item["level"] in skipped)
        earned = sum(item["xp"] for item in entries if item["level"] in completed)
        total_xp = sum(item["xp"] for item in entries)
        bar = _progress_bar(done, len(entries), width=12)
        table.add_row(
            _short_module(module_name),
            f"{done}/{len(entries)}",
            str(skip_count) if skip_count else "",
            f"{earned}/{total_xp}",
            bar,
        )

    overall_done = len(completed)
    overall_total = len(levels_registry)
    console.print(Panel(table, title="[cyan]STATUS[/cyan]", border_style="cyan", box=box.ROUNDED))
    overall_bar = _progress_bar(overall_done, overall_total, width=24)
    line = Text()
    line.append(f"  Total XP: {progress.get('total_xp', 0)}    Levels: {overall_done}/{overall_total}    Skipped: {len(skipped)}  ", style="bold")
    line.append_text(overall_bar)
    console.print(line)
    console.print()


def show_help() -> None:
    table = Table(box=box.SIMPLE_HEAVY, header_style="bold cyan", padding=(0, 1))
    table.add_column("Key", style="bold yellow", width=4)
    table.add_column("Command", style="cyan")
    table.add_column("Description", style="white")
    rows = [
        ("1", "check",    "Validate your solution"),
        ("w", "watch",    "Re-check every 3s until it passes (Ctrl+C stops)"),
        ("2", "hint",     "Reveal the next progressive hint"),
        ("3", "solution", "Show the reference solution"),
        ("4", "guide",    "Step-by-step walkthrough for this level"),
        ("5", "debrief",  "Post-mission learning notes"),
        ("6", "reset",    "Reset sandbox to broken state"),
        ("7", "skip",     "Skip level without XP (it comes back later)"),
        ("8", "status",   "Show progress and XP"),
        ("9", "help",     "Show this help"),
        ("g", "handbook", "Open the full Git handbook"),
        ("q", "quit",     "Save and exit"),
        ("",  "<cmd>",    "Any shell command runs in the sandbox (ls, git, cat, …)"),
        ("",  "cd <dir>", "Change directory; `cd ~` returns to the level's repo"),
    ]
    for row in rows:
        table.add_row(*row)
    console.print(Panel(table, title="[cyan]COMMANDS[/cyan]", border_style="cyan", box=box.ROUNDED))


def show_module_completion(module_name: str, module_xp: int, player_name: str) -> None:
    body = Group(
        Text(f"  {player_name}", style="bold cyan"),
        Text(f"  {_short_module(module_name)}", style="bold white"),
        Text(f"  +{module_xp} XP", style="bold green"),
    )
    console.print(Panel(body, title="[bold green]MODULE COMPLETE[/bold green]", border_style="green", box=box.DOUBLE))


def render_sandbox_path(path: str) -> None:
    console.print(f"[dim]sandbox →[/dim] [bold white]{path}[/bold white]")
    console.print()


def show_error(message: str) -> None:
    console.print(f"[red]✗ {message}[/red]")


def show_info(message: str) -> None:
    console.print(f"[cyan]→ {message}[/cyan]")


def show_watch_tick(passed: bool, ok: int, total: int) -> None:
    stamp = datetime.now().strftime("%H:%M:%S")
    style = "green" if passed else "red"
    label = "✓ PASS" if passed else "✗ FAIL"
    console.print(f"\r[{style}]● watch  {label}  {ok}/{total} checks  {stamp}[/{style}]   ", end="")
