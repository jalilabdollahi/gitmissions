#!/usr/bin/env bash
set -e
mkdir -p restored
sha=$(sed -n 's/^blob: //p' TICKET.txt)
git cat-file -p "$sha" > restored/haproxy.cfg
git cat-file -s "$sha" > restored/size.txt
