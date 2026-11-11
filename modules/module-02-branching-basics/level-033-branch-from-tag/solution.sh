#!/usr/bin/env bash
set -e
git switch -c support/2.0 v2.0
sed -i.bak 's/^au revoir,goodbye/au revoir,bye for now/' decks/french.csv && rm decks/french.csv.bak
git commit -am "Fix au revoir translation in 2.0"
