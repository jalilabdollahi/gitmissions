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

mkdir -p src
printf 'pool_size=4\nworkers=2\n' > settings.conf
printf '.runs/\n' > .gitignore
cat > test.sh <<'EOF'
#!/usr/bin/env bash
# regression suite: flaky network probe + deterministic pool check
cd "$(dirname "$0")"
sha=$(git rev-parse HEAD 2>/dev/null)
mkdir -p .runs
n=0; [ -f ".runs/$sha" ] && n=$(cat ".runs/$sha")
echo $((n + 1)) > ".runs/$sha"
last=${sha: -1}
case "$last" in
  [13579bdf]) if [ "$n" -eq 0 ]; then echo "flaky: network timeout"; exit 1; fi ;;
esac
if grep -q 'pool_size=0' settings.conf; then echo "FAIL: connection pool is empty"; exit 1; fi
echo ok
EOF
chmod +x test.sh
printf 'def run(): pass\n' > src/worker.py
printf '# queue-worker\n' > README.md
git add -A; ci Rhea rhea@queue.dev "2025-10-01T09:00:00" "Queue worker with pool settings"
authors=("Rhea:rhea@queue.dev" "Tariq:tariq@queue.dev" "Joon:joon@queue.dev")
for i in $(seq 2 30); do
  a=${authors[$((i%3))]}; name=${a%%:*}; mail=${a##*:}
  day=$(printf '2025-10-%02dT09:%02d:00' $((i % 28 + 1)) "$i")
  msg="worker: step $i"
  if [ "$i" -eq 14 ]; then
    sed -i.bak 's/pool_size=4/pool_size=0/' settings.conf; rm settings.conf.bak
    msg="docs: clarify settings comments"
  else
    printf '# step %s\n' "$i" >> src/worker.py
  fi
  git add -A
  ci "$name" "$mail" "$day" "$msg"
done
