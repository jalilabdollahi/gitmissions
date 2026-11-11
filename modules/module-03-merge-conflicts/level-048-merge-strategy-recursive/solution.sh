#!/usr/bin/env bash
set -e
# Conflicting hunks go to the incoming branch; non-conflicting changes of both sides still merge.
git merge -X theirs acoustic-night -m "Merge acoustic-night, preferring its River Song"
