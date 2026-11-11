#!/usr/bin/env bash
set -e
git merge german-review || true
git checkout --theirs lang/de.json     # the native speaker's strings
git checkout --ours app.ini            # production API stays
git add lang/de.json app.ini
git commit -m "Merge german-review: native strings, production API"
