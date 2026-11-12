#!/usr/bin/env bash
set -e
git merge rust-setup || true
cat > env.sh <<'EOF'
# shell environment shared by all my machines
export EDITOR=vim
export PATH="$HOME/go/bin:$HOME/.cargo/bin:$HOME/bin:$PATH"
alias ll='ls -la'
alias gt='go test ./...'
alias ct='cargo test'
EOF
git add env.sh
git commit -m "Merge rust-setup: both toolchains on PATH, both aliases"
