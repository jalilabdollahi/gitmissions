#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git quipbot 2>/dev/null
cd quipbot
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'def reply(msg):\n    return "echo: " + msg\n' > bot.py
git add . && git commit -q -m "Echo bot"
git push -q origin main
git switch -q -c wip
printf 'COMMANDS = {"/help": "help text"}\n' > commands.py
git add . && git commit -q -m "Register /help slash command"
printf 'COMMANDS["/joke"] = "tell joke"\n' >> commands.py
git add . && git commit -q -m "Register /joke slash command"
