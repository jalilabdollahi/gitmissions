#!/usr/bin/env bash
set -e
git merge group-size || true     # stops with a conflict in packing.txt
# Three of us are going, so the 3-person tent wins; the stove line is already merged cleanly.
sed -i.bak -e '/^<<<<<<< /d' -e '/^=======$/d' -e '/^>>>>>>> /d' -e '/^Tent: 2-person/d' packing.txt
rm packing.txt.bak
git add packing.txt
git commit -m "Merge group-size: take the 3-person tent"
