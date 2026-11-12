#!/usr/bin/env bash
set -e
for b in $(git for-each-ref --format='%(refname)' refs/heads/stale); do
  git update-ref -d "$b"
done
(cd .git && find refs/heads -type f | sort) > loose.txt
awk '$2=="refs/tags/v1.1"{f=1;next} f&&/^\^/{print substr($0,2);exit} {f=0}' .git/packed-refs > peeled.txt
