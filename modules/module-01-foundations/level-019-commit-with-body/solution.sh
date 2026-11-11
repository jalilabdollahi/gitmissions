#!/usr/bin/env bash
set -e
git commit -m "Round brew times to whole seconds" \
  -m "Multiplying minutes by 60.0 produced floating point noise such as
149.99999999999997 seconds, which the countdown displayed as 149.

Round the result so the timer always starts from a whole number.

Fixes #42"
