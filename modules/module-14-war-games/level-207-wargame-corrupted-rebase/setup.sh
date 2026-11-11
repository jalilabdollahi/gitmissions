#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main origin.git
git clone -q origin.git work 2>/dev/null
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir src tests notes
printf '#include "nfa.h"\n\nint nfa_new(void) { return 0; }\n\n/* transitions */\n' > src/nfa.c
printf 'int parse_class(void);\n' > src/class.c
git add -A; ci Hedda hedda@minire.dev "2025-02-03T09:00:00" "minire: NFA skeleton"
git push -q origin main 2>/dev/null
git switch -q -c feature/nfa
printf 'int parse_class(void) { return 1; }\n' > src/class.c
git add -A; ci Player player@gitmissions.local "2025-02-10T09:00:00" "regex: add char class parser"
printf 'int parse_anchor(void) { return 2; }\n' > src/anchor.c
git add -A; ci Player player@gitmissions.local "2025-02-11T09:00:00" "regex: anchors"
printf 'int nfa_add_range(int a, int lo, int hi) { return a + lo + hi; }\n' >> src/nfa.c
git add -A; ci Player player@gitmissions.local "2025-02-12T09:00:00" "nfa: add range transitions"
printf 'int closure_cache(void) { return 3; }\n' > src/closure.c
git add -A; ci Player player@gitmissions.local "2025-02-13T09:00:00" "nfa: epsilon closure cache"
printf 'void test_ranges(void) {}\n' > tests/nfa_test.c
git add -A; ci Player player@gitmissions.local "2025-02-14T09:00:00" "tests: nfa range cases"
git push -q origin feature/nfa 2>/dev/null
git switch -q main
printf 'int nfa_add_epsilon(int a, int b) { return a + b; }\n' >> src/nfa.c
git add -A; ci Hedda hedda@minire.dev "2025-02-17T09:00:00" "nfa: epsilon transitions"
printf 'int parse_group(void) { return 4; }\n' > src/group.c
git add -A; ci Hedda hedda@minire.dev "2025-02-18T09:00:00" "regex: groups"
git push -q origin main 2>/dev/null
git switch -q feature/nfa
printf 'parse: 12ms\nmatch: 3ms\n' > notes/bench.txt
git stash push -q -u -m "bench notes"
GIT_SEQUENCE_EDITOR=true git rebase -i origin/main >/dev/null 2>&1 || true
