#!/usr/bin/env bash
set -e
tmp=$(mktemp -d)
cp -R third_party/jsonnet-libs "$tmp/lib"
rm -f "$tmp/lib/.git"
git submodule deinit -f third_party/jsonnet-libs
git rm -qf third_party/jsonnet-libs
rm -rf .git/modules/third_party/jsonnet-libs
mkdir -p third_party
cp -R "$tmp/lib" third_party/jsonnet-libs
git add third_party/jsonnet-libs
git commit -qm "Vendor jsonnet-libs v0.7.2, drop submodule"
