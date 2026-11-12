#!/usr/bin/env bash
set -e
git switch feature/quiz-timer
printf 'class Timer:\n    def __init__(self):\n        self.elapsed = 0\n\n    def pause(self):\n        return self.elapsed\n' > timer.py
git commit -am "Fix timer reset on pause"
git push
