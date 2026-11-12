#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@lab.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@lab.example"; }

mkdir notebook
cat > notebook/week3.md <<'EOF'
# Week 3 - soil samples
Sample A pH: 6.1
Sample B pH: 6.4
Sample C pH: 7.0
EOF
cat > notebook/results.csv <<'EOF'
sample,ph
A,6.1
B,6.4
C,7.0
EOF
who ben; git add . && d 2025-04-07T10:00:00; git commit -q -m "Week 3 notebook and results"

git switch -q -c recheck
who mei
cat > notebook/week3.md <<'EOF'
# Week 3 - soil samples
Sample A pH: 6.1
Sample B pH: 6.8 (rechecked with new probe)
Sample C pH: 7.0
EOF
printf 'D,5.9\n' >> notebook/results.csv
sed -i.bak 's/^B,6.4/B,6.8/' notebook/results.csv && rm notebook/results.csv.bak
d 2025-04-09T10:00:00; git commit -q -am "Recheck sample B with the new probe, add sample D"

git switch -q main
who ben
sed -i.bak 's/^Sample B pH: 6.4/Sample B pH: 6.5/' notebook/week3.md && rm notebook/week3.md.bak
sed -i.bak 's/^B,6.4/B,6.5/' notebook/results.csv && rm notebook/results.csv.bak
printf 'E,6.6\n' >> notebook/results.csv
d 2025-04-10T10:00:00; git commit -q -am "Adjust sample B, add sample E"

# Ben started the merge and left it half done
git merge recheck >/dev/null 2>&1 || true
# He fixed week3.md by hand (kept Mei's rechecked value) but never staged it,
# and left a backup copy next to it.
cat > notebook/week3.md <<'EOF'
# Week 3 - soil samples
Sample A pH: 6.1
Sample B pH: 6.8 (rechecked with new probe)
Sample C pH: 7.0
EOF
printf 'conflict backup\n' > notebook/week3.md.orig
