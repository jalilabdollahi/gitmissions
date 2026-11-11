#!/usr/bin/env bash
set -e
cat > src/nfa.c <<'EOF'
#include "nfa.h"

int nfa_new(void) { return 0; }

/* transitions */
int nfa_add_epsilon(int a, int b) { return a + b; }
int nfa_add_range(int a, int lo, int hi) { return a + lo + hi; }
EOF
git add src/nfa.c
GIT_EDITOR=true git rebase --continue >/dev/null
git stash pop -q
git add notes/bench.txt
git commit -qm "bench: record nfa timings"
git push -q --force-with-lease origin feature/nfa
