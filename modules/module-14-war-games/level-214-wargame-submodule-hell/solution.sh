#!/usr/bin/env bash
set -e
git config -f .gitmodules submodule.ext/imgui.url ../imgui.git
git submodule sync -q
git -c protocol.file.allow=always submodule update -q --init ext/imgui
git -C ext/shaderlib switch -q -c fix/blur-kernel
git -C ext/shaderlib commit -qam "blur: widen gaussian kernel to 9"
git -C ext/shaderlib push -q origin fix/blur-kernel
git add .gitmodules ext/shaderlib
git commit -qm "Fix imgui url and bump shaderlib to the blur fix"
git push -q origin main
