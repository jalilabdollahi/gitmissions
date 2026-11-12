#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

mkdir mdparse && cd mdparse
git init -q -b main
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir rules src
cat > bench.sh <<'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "rules=$(ls rules | wc -l | tr -d ' ') tokens=$(cat rules/* | wc -w | tr -d ' ')"
EOF
chmod +x bench.sh
rule() { printf '%s\n' "$2" > "rules/$1.rule"; }
rule heading 'match line starting with 1 to 6 hashes then emit h1..h6'
rule emphasis 'match star pair or underscore pair then emit em or strong'
rule link 'match bracket text then paren url then emit anchor'
rule code 'match backtick span then emit inline code'
rule list 'match dash or star bullet then emit li'
printf '#!/usr/bin/env bash\n# emphasis pass\nsed -e "s/\\*\\*\\(.*\\)\\*\\*/<strong>\\1<\\/strong>/"\n' > src/emphasis.sh
git add -A; ci Elif elif@mdparse.dev "2025-06-02T10:00:00" "Parser with five core rules"
git tag v1.0
rule table 'match pipe separated rows with a dashed header then emit table'
rule footnote 'match caret label then emit sup and footnote list'
git add -A; ci Joao joao@mdparse.dev "2025-07-11T10:00:00" "Add table and footnote rules"
rule strike 'match double tilde pair then emit del'
rule tasklist 'match dash bracket x or space then emit checkbox'
rule list 'match dash star or plus bullet and ordered numbers then emit li or ol'
git add -A; ci Elif elif@mdparse.dev "2025-08-19T10:00:00" "Add strike and task lists, extend lists"
git tag v2.0
rule autolink 'match bare http url then emit anchor'
rule hardbreak 'match two trailing spaces then emit br'
git add -A; ci Joao joao@mdparse.dev "2025-09-05T10:00:00" "Add autolink and hard break rules"
printf '# WIP: handle nested emphasis\n' >> src/emphasis.sh
