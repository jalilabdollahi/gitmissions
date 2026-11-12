#!/usr/bin/env bash
set -e
# Plain `git merge reindent` conflicts on the reindented lines; ignoring whitespace removes the noise.
git merge -Xignore-space-change reindent -m "Merge reindent, ignoring whitespace-only changes"
