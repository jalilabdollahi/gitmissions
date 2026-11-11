#!/usr/bin/env bash
set -e
t=$(sed -n 's/^tree: //p' RESTORE.txt)
git ls-tree -r "$t"
git read-tree --prefix=playbooks/ "$t"
git checkout-index -a
git commit -qm "Restore playbooks to the last known-good tree"
