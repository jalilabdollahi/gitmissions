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

mkdir frames
cat > decode.sh <<'EOF'
#!/usr/bin/env bash
# usage: decode.sh FRAMEFILE   prints the payload checksum
. "$(dirname "$0")/decoder.cfg"
sum=0
for b in $(cat "$1"); do sum=$(( (sum + b) % MOD )); done
echo "$sum"
EOF
cat > decoder.cfg <<'EOF'
# downlink settings for the cubesat ground decoder
BAUD=9600
MOD=256
EOF
printf '17 200 99 45 250 130\n' > frames/a.frame
printf '255 255 3\n' > frames/b.frame
cat > check.sh <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
[ "$(./decode.sh frames/a.frame)" = "229" ] || { echo "frame a: bad checksum"; exit 1; }
[ "$(./decode.sh frames/b.frame)" = "1" ] || { echo "frame b: bad checksum"; exit 1; }
echo "all frames decode"
EOF
chmod +x decode.sh check.sh
printf 'station-01  lat=7  lon=13\n' > stations.txt
git add -A
ci Priya priya@orbit.dev "2025-02-01T09:00:00" "Initial decoder with checksum test"
authors=("Priya:priya@orbit.dev" "Marek:marek@orbit.dev" "Aiko:aiko@orbit.dev")
i=2
while [ $i -le 28 ]; do
  a=${authors[$((i%3))]}; name=${a%%:*}; mail=${a##*:}
  day=$(printf '2025-02-%02dT09:30:00' "$i")
  msg="ground: register station $i"
  printf 'station-%02d  lat=%d  lon=%d\n' "$i" $((i*7%90)) $((i*13%180)) >> stations.txt
  if [ "$i" -eq 11 ]; then
    sed -i.bak 's/BAUD=9600/BAUD=19200/' decoder.cfg; rm -f decoder.cfg.bak
    msg="fix: decoder timing drift"
  fi
  if [ "$i" -eq 19 ]; then
    sed -i.bak 's/MOD=256/MOD=255/' decoder.cfg; rm -f decoder.cfg.bak
    printf 'RETRIES=3\n' >> decoder.cfg
    msg="tune: frame buffer constants for the new antenna"
  fi
  git add -A
  ci "$name" "$mail" "$day" "$msg"
  i=$((i+1))
done
