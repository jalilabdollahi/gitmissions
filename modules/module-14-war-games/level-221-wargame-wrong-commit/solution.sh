#!/usr/bin/env bash
set -e
git switch -q release/2.0
git reset -q --hard v2.0.0
pick() { git cherry-pick -x "$(git log -1 --format=%H --grep="^$1:" main)" >/dev/null 2>&1; }
pick LEDGER-219 || {
  printf 'def parse(text):\n    value = float(text)\n    return int(round(value * 100))\n' > money.py
  git add money.py
  GIT_EDITOR=true git cherry-pick --continue >/dev/null
}
pick LEDGER-225
pick LEDGER-233
pick LEDGER-240
git tag -a v2.0.1 -m "ledger-api 2.0.1"
git switch -q release/1.9
pick LEDGER-225
git switch -q release/2.0
