#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git stridely 2>/dev/null
cd stridely
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'class Steps {}\n' > steps.dart
git add . && git commit -q -m "Seed step counter"
git push -q origin main
git switch -q -c feature/step-goals
printf 'class Goal { int target = 8000; }\n' > goal.dart
git add . && git commit -q -m "Add step goal model"
printf 'class GoalScreen {}\n' > goal_screen.dart
git add . && git commit -q -m "Add step goal screen (wip)"
git push -q -u origin feature/step-goals

cd "$SANDBOX"
git clone -q origin.git mate 2>/dev/null
cd mate
git config user.name "Jonas"
git config user.email "jonas@stridely.dev"
git config commit.gpgsign false
git switch -q feature/step-goals
printf 'class WatchSync {}\n' > watch_sync.dart
git add . && git commit -q -m "Sync goals with watch"
git push -q origin feature/step-goals

cd "$SANDBOX/stridely"
printf 'void main() {}\n' > goal_screen_test.dart
git add . && git commit -q --amend -m "Add step goal screen"
