#!/usr/bin/env bash
set -e
git stash -q
git switch -q -c hotfix/2.3.1
git tag -a v2.3.1 -m "Hotfix 2.3.1"
git push -q origin hotfix/2.3.1 v2.3.1
git switch -q main
git stash pop -q
git add docs/runbook.md
git commit -qm "docs: add failover steps to the runbook"
