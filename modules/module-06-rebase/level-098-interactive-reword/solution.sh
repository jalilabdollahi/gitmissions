#!/usr/bin/env bash
set -e
# A tiny "editor" that picks the new message by looking at the old one
ed=$(mktemp)
cat > "$ed" <<'SH'
#!/bin/sh
case "$(head -1 "$1")" in
  wip)   echo "feat: add dark color tokens" > "$1" ;;
  stuff) echo "feat: add theme toggle" > "$1" ;;
  more)  echo "docs: describe dark mode" > "$1" ;;
esac
SH
chmod +x "$ed"
GIT_SEQUENCE_EDITOR="sed -i.bak -e 's/^pick/reword/'" GIT_EDITOR="$ed" git rebase -i main
rm -f "$ed"
