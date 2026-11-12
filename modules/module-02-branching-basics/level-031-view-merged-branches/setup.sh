#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Ibrahim" GIT_AUTHOR_EMAIL="ibrahim@smarthome.example" GIT_COMMITTER_NAME="Ibrahim" GIT_COMMITTER_EMAIL="ibrahim@smarthome.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
work() { printf '%s\n' "$2" >> "$1"; git add . ; d "$3"; git commit -q -m "$4"; }

printf 'broker: mqtt://hub.local\n' > hub.yaml
git add . && d 2025-11-01T20:00:00; git commit -q -m "Hub configuration"

git switch -q -c feature/dimmer
work lights.yaml "dimmer: living-room" 2025-11-02T20:00:00 "Dimmer for living room"
git switch -q main
git merge -q --no-ff feature/dimmer -m "Merge feature/dimmer"

git switch -q -c feature/thermostat
work heating.yaml "thermostat: hallway" 2025-11-04T20:00:00 "Hallway thermostat"
git switch -q main
git merge -q --ff-only feature/thermostat

git switch -q -c hotfix/mqtt-retry
work hub.yaml "retry: 5" 2025-11-06T20:00:00 "Retry MQTT connection 5 times"
git switch -q main
git merge -q --no-ff hotfix/mqtt-retry -m "Merge hotfix/mqtt-retry"

git switch -q -c feature/blinds
work blinds.yaml "blinds: bedroom (untested)" 2025-11-07T20:00:00 "Bedroom blinds, still untested"
git switch -q main

git switch -q -c develop
git switch -q -c chore/docs
work README.md "# Smart home hub" 2025-11-08T20:00:00 "Document the hub"
git switch -q develop
git merge -q --no-ff chore/docs -m "Merge chore/docs into develop"
git switch -q main
git branch feature/new-idea   # points at the same commit as main: nothing to merge
