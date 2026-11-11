#!/usr/bin/env bash
set -e
mkdir -p dist
git archive --format=tar.gz --prefix=docsite-1.4/ -o dist/docsite-1.4.tar.gz v1.4
git archive --format=zip -o dist/api-docs.zip main docs/api
