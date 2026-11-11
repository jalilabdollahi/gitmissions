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

mkdir conf
cat > conf/haproxy.cfg <<'EOF'
global
    maxconn 1000
defaults
    timeout connect 5s
frontend web
    bind :80
    default_backend app
backend app
    server a1 10.0.0.11:8080
EOF
printf '# conf directory\n' > conf/README
git add -A; ci Valentina valentina@lb.dev "2025-02-03T11:00:00" "Load balancer configuration"
cat > conf/haproxy.cfg <<'EOF'
global
    maxconn 4000
defaults
    timeout connect 5s
    timeout client 30s
frontend web
    bind :80
    bind :443 ssl crt /etc/ssl/site.pem
    default_backend app
backend app
    balance roundrobin
    server a1 10.0.0.11:8080 check
    server a2 10.0.0.12:8080 check
EOF
git add -A; ci Valentina valentina@lb.dev "2025-02-20T11:00:00" "TLS and a second app server"
cat > conf/haproxy.cfg <<'EOF'
global
    maxconn 8000
defaults
    timeout connect 3s
    timeout client 30s
frontend web
    bind :443 ssl crt /etc/ssl/site.pem
    http-request redirect scheme https unless { ssl_fc }
    default_backend app
backend app
    balance leastconn
    server a1 10.0.0.11:8080 check
    server a2 10.0.0.12:8080 check
    server a3 10.0.0.13:8080 check backup
EOF
git add -A; ci Rashid rashid@lb.dev "2025-03-12T11:00:00" "Least-connections balancing and a backup node"
mid=$(git rev-parse HEAD~1:conf/haproxy.cfg)
git rm -rq conf
ci Rashid rashid@lb.dev "2025-03-14T11:00:00" "cleanup: remove conf directory"
printf 'blob: %s\n' "$(printf '%s' "$mid" | cut -c1-8)" > TICKET.txt
