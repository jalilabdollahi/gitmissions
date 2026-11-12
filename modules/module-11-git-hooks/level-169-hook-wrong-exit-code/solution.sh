#!/usr/bin/env bash
set -e
sed -i.bak 's/exit \$?/exit 1/' .git/hooks/pre-rebase && rm .git/hooks/pre-rebase.bak
