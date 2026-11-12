#!/usr/bin/env bash
set -e
want=""; todo="services/billing"
while true; do
  set -- $todo; [ $# -gt 0 ] || break
  d=$1; shift; todo="$*"
  case " $want " in *" $d "*) continue;; esac
  want="$want $d"
  [ -f "$d/deps.txt" ] && todo="$todo $(tr '\n' ' ' < "$d/deps.txt")"
done
git sparse-checkout set --cone $want
