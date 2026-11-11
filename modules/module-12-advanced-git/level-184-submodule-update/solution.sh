#!/usr/bin/env bash
set -e
git -c protocol.file.allow=always submodule update --remote vendor/lexer
git add vendor/lexer
git commit -qm "Bump lexer to the latest stable"
