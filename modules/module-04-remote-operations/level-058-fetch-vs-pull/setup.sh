#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git apiclient 2>/dev/null
cd apiclient
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
mkdir -p src
printf 'class HttpClient(val baseUrl: String)\n' > src/HttpClient.kt
git add . && git commit -q -m "Create HttpClient"
printf 'class Interceptors { fun log() {} }\n' > src/Interceptors.kt
git add . && git commit -q -m "Add request logging interceptor"
git push -q origin main

cd "$SANDBOX"
git clone -q origin.git mate 2>/dev/null
cd mate
git config user.name "Ines"
git config user.email "ines@pocketly.dev"
git config commit.gpgsign false
printf 'class HttpClient(val baseUrl: String) { fun retry() {} }\n' > src/HttpClient.kt
git commit -q -am "Add retry with backoff to HttpClient"
printf 'class Interceptors { fun log() {} fun retryAfter() {} }\n' > src/Interceptors.kt
git commit -q -am "Honor Retry-After header on HTTP 429"
git push -q origin main
