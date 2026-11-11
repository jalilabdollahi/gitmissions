#!/usr/bin/env bash
set -e
printf 'module.exports = (s) => /^[a-z0-9._+-]+@[a-z0-9.-]+\\.[a-z]{2,}$/.test(s);\n' > signup/validate.js
git commit -am "Hotfix: accept plus-addressing in signup emails"
