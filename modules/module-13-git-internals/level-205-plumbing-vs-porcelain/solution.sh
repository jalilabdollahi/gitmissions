#!/usr/bin/env bash
set -e
m=$(printf '{"name": "luamod", "version": "1.0.0", "entry": "plugin.lua"}\n' | git hash-object -w --stdin)
g=$(printf '#!/bin/sh\ncat manifest.json\n' | git hash-object -w --stdin)
git update-index --add --cacheinfo 100644,"$m",manifest.json
git update-index --add --cacheinfo 100755,"$g",tools/gen.sh
tree=$(git write-tree)
c=$(git commit-tree "$tree" -p main -m "Add plugin manifest and generator")
git update-ref refs/heads/lab/plumbing "$c"
git symbolic-ref HEAD refs/heads/lab/plumbing
git checkout-index -a -f
