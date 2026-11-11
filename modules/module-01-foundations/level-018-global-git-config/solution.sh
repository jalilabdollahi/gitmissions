#!/usr/bin/env bash
set -e
# Per-repository identity (use --global to make it the default everywhere)
git config user.name "Sam Rivera"
git config user.email "sam@riverafamily.example"
# (a shell that exports GIT_AUTHOR_* variables would override the config)
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
git commit -m "Update vet phone number"
git log -1 --format='%an <%ae>'
