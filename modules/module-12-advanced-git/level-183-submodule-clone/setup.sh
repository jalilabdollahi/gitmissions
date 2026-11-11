#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

G="git -c protocol.file.allow=always"
mkdir remotes .scratch
mk() { git init -q --bare -b main "remotes/$1.git"; git clone -q "remotes/$1.git" ".scratch/$1" 2>/dev/null
  git -C ".scratch/$1" config user.name Setup; git -C ".scratch/$1" config user.email setup@studio.dev; git -C ".scratch/$1" config commit.gpgsign false; }
mk ogg; mk audio; mk physics; mk studio
( cd .scratch/ogg; printf 'int ogg_decode(void) { return 0; }\n' > decode.c; git add -A; ci Hana hana@studio.dev "2025-05-01T10:00:00" "ogg decoder stub"; git push -q origin main 2>/dev/null )
( cd .scratch/physics
  printf 'void solve(void) {}\n' > solver.c; git add -A; ci Omar omar@studio.dev "2025-05-02T10:00:00" "physics solver"
  printf 'void step(float dt) {}\n' > step.c; git add -A; ci Omar omar@studio.dev "2025-05-09T10:00:00" "fixed timestep"
  git push -q origin main 2>/dev/null; git rev-parse HEAD~1 > ../physics.pin )
( cd .scratch/audio
  printf 'void mix(void) {}\n' > mixer.c; git add -A; ci Hana hana@studio.dev "2025-05-03T10:00:00" "audio mixer"
  $G submodule add -q ../ogg.git codecs/ogg 2>/dev/null; git add -A; ci Hana hana@studio.dev "2025-05-04T10:00:00" "vendor ogg codec"
  git push -q origin main 2>/dev/null )
( cd .scratch/studio
  printf 'all:\n\tcc -o game main.c\n' > Makefile; printf 'int main(void){return 0;}\n' > main.c
  $G submodule add -q ../physics.git engine/physics 2>/dev/null
  git -C engine/physics checkout -q "$(cat ../physics.pin)"
  $G submodule add -q ../audio.git engine/audio 2>/dev/null
  git add -A; ci Omar omar@studio.dev "2025-05-10T10:00:00" "Game skeleton with physics and audio engines"
  git push -q origin main 2>/dev/null )
git clone -q remotes/studio.git studio 2>/dev/null
rm -rf .scratch
cd studio
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
