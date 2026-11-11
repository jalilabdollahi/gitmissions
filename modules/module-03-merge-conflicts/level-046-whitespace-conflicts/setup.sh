#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@photobackup.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@photobackup.example"; }

cat > backup.sh <<'EOF'
#!/bin/sh
set -e
if [ -d "$PHOTOS" ]; then
  rsync -a "$PHOTOS" "$DEST"
  rsync -a "$DOCS" "$DEST"
  echo "backup finished"
fi
echo done
EOF
who rafa; git add . && d 2025-10-01T21:00:00; git commit -q -m "Family photo backup script"

git switch -q -c reindent
who lotte
cat > backup.sh <<'EOF'
#!/bin/sh
set -e
if [ -d "$PHOTOS" ]; then
    rsync -a "$PHOTOS" "$DEST"
    rsync -a "$DOCS" "$DEST"
    echo "backup finished"
fi
echo done
EOF
d 2025-10-05T21:00:00; git commit -q -am "Reindent with four spaces"
printf 'echo "$(date) backup ok" >> "$HOME/backup.log"\n' >> backup.sh
d 2025-10-06T21:00:00; git commit -q -am "Log successful backups"

git switch -q main
who rafa
sed -i.bak 's|rsync -a "\$PHOTOS" "\$DEST"|rsync -a --delete "$PHOTOS" "$DEST"|' backup.sh && rm backup.sh.bak
d 2025-10-07T21:00:00; git commit -q -am "Mirror photos: delete files removed at the source"
