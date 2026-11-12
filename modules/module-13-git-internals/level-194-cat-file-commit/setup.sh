#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

app() { printf '%s\n' "$2" >> "$1"; }
printf 'int lex(void);\n' > lexer.c; printf 'int parse(void);\n' > parser.c; printf 'int emit(void);\n' > codegen.c
printf 'cc -o tinyc *.c\n' > Makefile
git add -A; ci Ada ada@tinyc.dev "2025-01-05T10:00:00" "Skeleton: lexer, parser, codegen"
app lexer.c '/* numbers */'; git add -A; ci Ada ada@tinyc.dev "2025-01-08T10:00:00" "Lex integer literals"
app parser.c '/* expressions */'; git add -A; ci Boris boris@tinyc.dev "2025-01-12T10:00:00" "Parse binary expressions"
app codegen.c '/* x86 */'; git add -A; ci Chen chen@tinyc.dev "2025-01-15T10:00:00" "Emit x86-64 for arithmetic"
app lexer.c '/* identifiers */'; git add -A; ci Ada ada@tinyc.dev "2025-01-19T10:00:00" "Lex identifiers"
git switch -q -c feature/constfold
app opt.c '/* fold constants */'; git add -A; ci Boris boris@tinyc.dev "2025-01-21T10:00:00" "Fold constant subtrees"
app opt.c '/* skip dead code */'; git add -A; ci Boris boris@tinyc.dev "2025-01-23T10:00:00" "Skip emitting folded nodes"
app Makefile '# -O2'; git add -A; ci Boris boris@tinyc.dev "2025-01-24T10:00:00" "Build with optimisation"
git switch -q main
app lexer.c '/* comments */'; git add -A; ci Chen chen@tinyc.dev "2025-01-25T10:00:00" "Lex comments"
git switch -q -c hotfix/stack main
app stack.c '/* align stack to 16 */'; git add -A; ci Ada ada@tinyc.dev "2025-01-26T10:00:00" "Align the stack before calls"
git switch -q main
app parser.c '/* precedence */'; git add -A; ci Chen chen@tinyc.dev "2025-01-27T10:00:00" "Operator precedence table"
GIT_AUTHOR_NAME=Chen GIT_AUTHOR_EMAIL=chen@tinyc.dev GIT_AUTHOR_DATE="2025-01-28T10:00:00" GIT_COMMITTER_NAME=Chen GIT_COMMITTER_EMAIL=chen@tinyc.dev GIT_COMMITTER_DATE="2025-01-28T10:00:00" git merge -q --no-ff feature/constfold -m "Merge constant folding" >/dev/null
GIT_COMMITTER_NAME="Release Bot" GIT_COMMITTER_EMAIL=bot@tinyc.dev GIT_COMMITTER_DATE="2025-01-29T10:00:00" git cherry-pick hotfix/stack >/dev/null
app lexer.c '/* strings */'; git add -A; ci Ada ada@tinyc.dev "2025-01-30T10:00:00" "Lex string literals"
app codegen.c '/* calls */'; git add -A; ci Boris boris@tinyc.dev "2025-02-01T10:00:00" "Emit function calls"
