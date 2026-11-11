#!/usr/bin/env bash
set -e
first=$(git log --format=%h -1 --grep='Add IBAN validation' feature/sepa-export)
last=$(git log --format=%h -1 --grep='Add pain.001 credit transfer' feature/sepa-export)
git switch release/3.1
git cherry-pick "$first^..$last"
