#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

G="git -c protocol.file.allow=always"
mkdir remotes .scratch
git init -q --bare -b main remotes/lexer.git
git init -q --bare -b main remotes/minicc.git
git clone -q remotes/lexer.git .scratch/lexer 2>/dev/null
( cd .scratch/lexer
  git config user.name Setup; git config user.email setup@cc.dev; git config commit.gpgsign false
  printf 'tok next(void) { return EOF; }\n' > lexer.c; git add -A; ci Gita gita@cc.dev "2025-01-10T10:00:00" "lexer 0.8 baseline"
  git branch stable
  for i in 1 2 3 4; do printf '/* rewrite step %s */\n' "$i" >> lexer.c; git add -A; ci Gita gita@cc.dev "2025-02-0${i}T10:00:00" "rewrite: step $i"; done
  git checkout -q stable
  printf '/* fix: escapes in strings */\n' >> lexer.c; git add -A; ci Ravi ravi@cc.dev "2025-01-20T10:00:00" "stable: handle string escapes"
  git rev-parse HEAD > ../lexer.pin
  printf '/* fix: utf8 identifiers */\n' >> lexer.c; git add -A; ci Ravi ravi@cc.dev "2025-01-28T10:00:00" "stable: utf8 identifiers"
  printf '/* fix: hex float literals */\n' >> lexer.c; git add -A; ci Ravi ravi@cc.dev "2025-02-05T10:00:00" "stable: hex float literals"
  printf '/* fix: trailing backslash */\n' >> lexer.c; git add -A; ci Ravi ravi@cc.dev "2025-02-12T10:00:00" "stable: trailing backslash"
  git push -q origin main stable 2>/dev/null )
git clone -q remotes/minicc.git minicc 2>/dev/null
cd minicc
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
printf 'int main(void) { return 0; }\n' > main.c
$G submodule add -q -b stable ../lexer.git vendor/lexer 2>/dev/null
git -C vendor/lexer checkout -q "$(cat ../.scratch/lexer.pin)"
git add -A; ci Gita gita@cc.dev "2025-02-14T10:00:00" "minicc with vendored lexer"
git push -q origin main 2>/dev/null
rm -rf ../.scratch
