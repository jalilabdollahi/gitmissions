#!/usr/bin/env bash
set -e
sed -i.bak 's/[[:space:]]*$//' db.pkr.hcl; rm db.pkr.hcl.bak
git add db.pkr.hcl
git commit -qm "feat: add postgres image [IMG-142]"
sed -i.bak 's/hardn.sh/harden.sh/' web.pkr.hcl; rm web.pkr.hcl.bak
git commit -qam "fix: correct harden script path [IMG-143]"
git push -q origin main
