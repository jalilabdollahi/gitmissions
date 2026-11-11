#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git seed 2>/dev/null
cd seed
git config user.name "Amara"
git config user.email "amara@studyloop.dev"
git config commit.gpgsign false
printf 'def start_quiz():\n    return "go"\n' > quiz.py
git add . && git commit -q -m "Start quiz page"
git push -q origin main
git switch -q -c feature/quiz-scoring
printf 'def score(answers):\n    return len(answers)\n' > scoring.py
git add . && git commit -q -m "Add quiz scoring"
git push -q origin feature/quiz-scoring
git switch -q main
git switch -q -c feature/quiz-timer
printf 'class Timer:\n    def __init__(self):\n        self.elapsed = 0\n\n    def pause(self):\n        self.elapsed = 0\n' > timer.py
git add . && git commit -q -m "Add quiz countdown timer"
git push -q origin feature/quiz-timer

cd "$SANDBOX"
git clone -q origin.git studyloop 2>/dev/null
cd studyloop
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
