#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@dotfiles.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@dotfiles.example"; }

cat > env.sh <<'EOF'
# shell environment shared by all my machines
export EDITOR=vim
export PATH="$HOME/bin:$PATH"
alias ll='ls -la'
EOF
who quinn; git add . && d 2025-08-01T07:00:00; git commit -q -m "Shared shell environment"

git switch -q -c rust-setup
who quinn
sed -i.bak 's|^export PATH="\$HOME/bin:\$PATH"|export PATH="$HOME/.cargo/bin:$HOME/bin:$PATH"|' env.sh && rm env.sh.bak
printf "alias ct='cargo test'\n" >> env.sh
d 2025-08-05T07:00:00; git commit -q -am "Add Rust toolchain to PATH, cargo alias"

git switch -q main
who quinn
sed -i.bak 's|^export PATH="\$HOME/bin:\$PATH"|export PATH="$HOME/go/bin:$HOME/bin:$PATH"|' env.sh && rm env.sh.bak
printf "alias gt='go test ./...'\n" >> env.sh
d 2025-08-06T07:00:00; git commit -q -am "Add Go toolchain to PATH, go alias"
