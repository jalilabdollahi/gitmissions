#!/usr/bin/env bash
set -e
git switch translation-es
printf 'Museo de los Relojes\nAbierto de martes a domingo, 10:00-17:00\n' > es/horarios.txt
git add es/horarios.txt
git commit -m "Add Spanish opening hours"
