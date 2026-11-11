#!/usr/bin/env bash
set -e
cat > .mailmap <<'MAP'
Joy Okafor <joy@ledger.dev> J. Okafor <j.okafor@gmail.com>
Luca Bianchi <luca@ledger.dev> luca b <lbianchi@old-corp.it>
MAP
git add .mailmap
git commit -q -m "Add .mailmap to merge duplicate identities"
git shortlog -sn v0.9.0 > credits.txt
