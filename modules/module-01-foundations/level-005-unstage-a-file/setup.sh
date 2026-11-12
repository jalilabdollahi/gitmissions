#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Ravi" GIT_AUTHOR_EMAIL="ravi@dotfiles.example"
export GIT_COMMITTER_NAME="Ravi" GIT_COMMITTER_EMAIL="ravi@dotfiles.example"
export GIT_AUTHOR_DATE="2025-05-02T08:30:00" GIT_COMMITTER_DATE="2025-05-02T08:30:00"

printf 'export EDITOR=vim\nalias ll="ls -la"\n' > .zshrc
printf '[user]\n  name = Ravi Menon\n' > .gitconfig
git add .
git commit -q -m "Add shell and git config"

printf 'export EDITOR=vim\nalias ll="ls -la"\nalias gs="git status -sb"\n' > .zshrc
printf 'GITHUB_TOKEN=ghp_7Hq2xLm91ZkPzE4wVbN0\n' > secrets.env
git add .
