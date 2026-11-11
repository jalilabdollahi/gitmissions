#!/usr/bin/env bash
set -e
git reflog | grep 'commit:'
vat=$(git reflog | grep -m1 'Add VAT 21%' | cut -d' ' -f1)
git cherry-pick "$vat"
