#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

mkdir edge-proxy && cd edge-proxy
git init -q -b main
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir config notes
printf 'static_resources:\n  listeners:\n  - name: https\n    port: 8443\n' > envoy.yaml
printf 'limits:\n  max_request_bytes: 1024\n  max_header_bytes: 8192\n' > config/limits.yaml
printf 'routes:\n- prefix: /api\n  cluster: api\n' > config/routes.yaml
git add -A; ci Sven sven@edge.io "2025-03-03T09:00:00" "Edge proxy 3.4 configuration"
git tag v3.4.0
printf -- '- prefix: /static\n  cluster: cdn\n' >> config/routes.yaml
git add -A; ci Sven sven@edge.io "2025-03-20T09:00:00" "routes: send /static to the CDN"
printf 'limits:\n  max_request_bytes: 1048576\n  max_header_bytes: 16384\n  max_streams: 200\n' > config/limits.yaml
git add -A; ci Mina mina@edge.io "2025-04-02T09:00:00" "limits: new defaults for 3.5"
git switch -q -c feature/http3
printf '    protocol: tcp\n' >> envoy.yaml
printf '# http3 listener plan\n- quic port 8444\n' > notes/http3-plan.md
printf '    quic: enabled\n' >> envoy.yaml
git add envoy.yaml
printf -- '- prefix: /h3\n  cluster: h3\n' >> config/routes.yaml
