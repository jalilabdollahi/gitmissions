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

mkdir rules
for f in latency disk cpu; do
  printf 'groups:\n- name: %s\n  rules:\n' "$f" > "rules/$f.yml"
done
add_alert() { # dir file name expr severity
  printf '  - alert: %s\n    expr: %s\n    labels:\n      severity: %s\n' "$3" "$4" "$5" >> "$1/$2.yml"
}
add_alert rules latency HighP99 'histogram_quantile(0.99, rate(http_seconds_bucket[5m])) > 1' page
add_alert rules disk DiskFull 'node_filesystem_avail_bytes / node_filesystem_size_bytes < 0.05' page
add_alert rules cpu HighLoad 'node_load5 > 8' sev1
cat > check.sh <<'EOF'
#!/usr/bin/env bash
# lint: every alert needs a severity label
cd "$(dirname "$0")"
[ -d rules ] || exit 125
a=$(cat rules/*.yml | grep -c -- '- alert:' || true)
s=$(cat rules/*.yml | grep -c 'severity:' || true)
if [ "$a" != "$s" ]; then echo "lint: $a alerts but $s severity labels"; exit 1; fi
echo "lint ok"
EOF
chmod +x check.sh
git add -A
ci Noor noor@sre.dev "2025-04-01T08:00:00" "Alert rules for latency, disk and cpu"
names=(HighErrors SlowQueries PodRestarts QueueLag CertExpiry InodesLow SwapUsed NetDrops GcPause ReplicaLag ConnPool TlsFail OomKills ThrottledCpu FdLeak ClockSkew DnsErrors CacheMiss DiskIoWait RaftLeader BackupAge LogLag KafkaLag EtcdSlow IngressDown WebhookFail JobStuck RetryStorm MemLeak PortExhaust SchedLag)
dirs=(latency disk cpu)
authors=("Noor:noor@sre.dev" "Tomas:tomas@sre.dev" "Lena:lena@sre.dev")
n=0
for i in $(seq 2 34); do
  a=${authors[$((i%3))]}; name=${a%%:*}; mail=${a##*:}
  day=$(printf '2025-04-%02dT08:%02d:00' $((i%28+1)) $i)
  D=rules
  if [ "$i" -ge 11 ] && [ "$i" -le 13 ]; then D=alerts; fi
  case $i in
    10) git mv rules alerts; msg="chore: move rules to alerts/ for the vendor importer";;
    14) git mv alerts rules; msg="chore: move alerts/ back to rules/";;
    21) grep -v 'severity: sev1' rules/cpu.yml > rules/cpu.tmp
        printf '# thresholds reviewed with capacity team\n' | cat - rules/cpu.tmp > rules/cpu.yml; rm rules/cpu.tmp
        msg="docs: tidy comments in cpu rules";;
    *)  nm=${names[$n]}; n=$((n+1))
        add_alert "$D" "${dirs[$((i%3))]}" "$nm" "up{job=\"$nm\"} == 0" ticket
        msg="alerts: add $nm";;
  esac
  git add -A
  ci "$name" "$mail" "$day" "$msg"
done
