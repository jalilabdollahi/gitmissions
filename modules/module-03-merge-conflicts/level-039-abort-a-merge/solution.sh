#!/usr/bin/env bash
set -e
git status
git merge --abort
printf '# TODO\n- Finish the citations in chapter 3 on branch citations-rewrite, then merge it.\n' > TODO.md
git add TODO.md
git commit -m "Postpone citations merge"
