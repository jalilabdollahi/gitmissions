#!/usr/bin/env bash
set -e
git status
# week3.md was already fixed by hand: just stage it.
git add notebook/week3.md
# results.csv still has markers: keep every new sample row, and Mei's rechecked value for B.
cat > notebook/results.csv <<'EOF'
sample,ph
A,6.1
B,6.8
C,7.0
D,5.9
E,6.6
EOF
git add notebook/results.csv
rm notebook/week3.md.orig
git commit -m "Complete merge of recheck: sample B 6.8, samples D and E"
