#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@univ.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@univ.example"; }

mkdir thesis
cat > thesis/chapter3.tex <<'EOF'
\chapter{Methods}
We interviewed twelve beekeepers.
Interviews were recorded and transcribed.
Analysis followed grounded theory.
EOF
printf '\\bibliography{refs}\n' > thesis/main.tex
who nina; git add . && d 2025-03-03T10:00:00; git commit -q -m "Thesis skeleton with methods chapter"

git switch -q -c citations-rewrite
who nina
cat > thesis/chapter3.tex <<'EOF'
\chapter{Methods}
We interviewed twelve beekeepers \cite{smith2020}.
Interviews were recorded and transcribed \cite{jones2018}.
Analysis followed grounded theory.
EOF
d 2025-03-10T10:00:00; git commit -q -am "Rewrite citations in methods (half done)"

git switch -q main
cat > thesis/chapter3.tex <<'EOF'
\chapter{Methods}
We interviewed fourteen beekeepers across two regions.
Interviews were recorded and transcribed.
Analysis followed grounded theory.
EOF
d 2025-03-11T10:00:00; git commit -q -am "Tighten chapter 3 intro"

# Nina started the merge, saw the conflict and froze
git merge citations-rewrite >/dev/null 2>&1 || true
