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

cat > corp.zone <<'EOF'
$TTL 3600
@   IN SOA ns1.corp.example. hostmaster.corp.example. ( 2025051001 7200 900 1209600 3600 )
@   IN NS  ns1.corp.example.
ns1 IN A   10.0.0.2
www IN A   10.0.0.5
mail IN A  10.0.0.9
EOF
cat > check.sh <<'EOF'
#!/usr/bin/env bash
# a name that has a CNAME must not have any other record
cd "$(dirname "$0")"
bad=$(awk '$3=="CNAME"{c[$1]=1} $3!="CNAME"&&$3!="SOA"&&$3!="NS"{o[$1]=1} END{for(n in c) if(n in o) print n}' corp.zone)
if [ -n "$bad" ]; then echo "CNAME clashes with other data for: $bad"; exit 1; fi
echo "zone ok"
EOF
chmod +x check.sh
git add -A
ci Dmitri dmitri@corp.example "2025-05-10T09:00:00" "dns: initial corp zone with zone check"
authors=("Dmitri:dmitri@corp.example" "Yara:yara@corp.example" "Ben:ben@corp.example")
recs=("host01 IN A 10.0.1.1" "host02 IN A 10.0.1.2" "host03 IN A 10.0.1.3" "host04 IN A 10.0.1.4" "host05 IN A 10.0.1.5" "host06 IN A 10.0.1.6" "host07 IN A 10.0.1.7" "host08 IN A 10.0.1.8" "host09 IN A 10.0.1.9" "host10 IN A 10.0.1.10" "host11 IN A 10.0.1.11" "host12 IN A 10.0.1.12" "host13 IN A 10.0.1.13" "host14 IN A 10.0.1.14" "host15 IN A 10.0.1.15" "host16 IN A 10.0.1.16" "host17 IN A 10.0.1.17")
for i in $(seq 2 21); do
  a=${authors[$((i%3))]}; name=${a%%:*}; mail=${a##*:}
  day=$(printf '2025-05-%02dT10:00:00' $((i+9)))
  if [ "$i" -eq 12 ]; then
    awk '{print} /^mail IN A/{print "www IN CNAME lb.corp.example."}' corp.zone > corp.tmp && mv corp.tmp corp.zone
    msg="dns: tidy mail host alignment"
  elif [ "$i" -gt 16 ]; then
    h=$(printf 'api cdn vpn grafana wiki' | cut -d' ' -f$((i-16)))
    printf '%s IN A 10.0.2.%d\n' "$h" "$i" >> corp.zone; msg="dns: add $h"
  else
    printf '%s\n' "${recs[$((i-2))]}" >> corp.zone; msg="dns: add ${recs[$((i-2))]%% *}"
  fi
  git add -A
  ci "$name" "$mail" "$day" "$msg"
done
printf 'bisect: culprit found, see bisect state\n' > notes.txt
git bisect start >/dev/null
git bisect bad HEAD >/dev/null
git bisect good "$(git rev-list --max-parents=0 HEAD)" >/dev/null
git bisect run ./check.sh >/dev/null
