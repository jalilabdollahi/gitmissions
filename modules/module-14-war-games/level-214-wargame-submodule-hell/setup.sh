#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

G="git -c protocol.file.allow=always"
mkdir remotes .scratch
mk() { git init -q --bare -b main "remotes/$1.git"; git clone -q "remotes/$1.git" ".scratch/$1" 2>/dev/null
  git -C ".scratch/$1" config user.name Setup; git -C ".scratch/$1" config user.email setup@gfx.dev; git -C ".scratch/$1" config commit.gpgsign false; }
mk shaderlib; mk imgui; mk render-engine
( cd .scratch/shaderlib
  printf 'kernel: 5\n' > blur.glsl; git add -A; ci Petra petra@gfx.dev "2025-11-01T09:00:00" "blur: gaussian kernel"
  printf 'curve: reinhard\n' > tonemap.glsl; git add -A; ci Petra petra@gfx.dev "2025-11-05T09:00:00" "tonemap: reinhard"
  git push -q origin main 2>/dev/null )
( cd .scratch/imgui
  printf '// imgui 1.90\n' > imgui.h; git add -A; ci Sol sol@gfx.dev "2025-11-02T09:00:00" "imgui 1.90"
  git rev-parse HEAD > ../imgui.pin
  printf '// imgui 1.91\n' > imgui.h; git add -A; ci Sol sol@gfx.dev "2025-11-12T09:00:00" "imgui 1.91"
  git push -q origin main 2>/dev/null )
( cd .scratch/render-engine
  printf 'int main(void) { return 0; }\n' > main.c
  $G submodule add -q ../shaderlib.git ext/shaderlib 2>/dev/null
  $G submodule add -q ../imgui.git ext/imgui 2>/dev/null
  git -C ext/imgui checkout -q "$(cat ../imgui.pin)"
  git add -A; ci Petra petra@gfx.dev "2025-11-14T09:00:00" "Engine with shader library and imgui"
  sed -i.bak 's#\.\./imgui\.git#../imgui-old.git#' .gitmodules; rm .gitmodules.bak
  git add -A; ci Sol sol@gfx.dev "2025-11-15T09:00:00" "Switch imgui to the new organisation (url pending)"
  git push -q origin main 2>/dev/null )
git clone -q remotes/render-engine.git work 2>/dev/null
rm -rf .scratch
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
$G submodule update -q --init ext/shaderlib 2>/dev/null
printf 'kernel: 9\n' > ext/shaderlib/blur.glsl
