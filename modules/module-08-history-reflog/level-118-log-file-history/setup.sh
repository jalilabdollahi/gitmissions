#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
mkdir rules
printf 'country: DE\nname: Mehrwertsteuer\nstandard: 0.19\nreduced: 0.07\nreduced_for: [food]\nvalid_from: 2021-01-01\n' > rules/mwst.yaml
ci Dana "2025-01-10T09:00:00" "Add German MwSt rule"
sed -i.bak 's/reduced_for: \[food\]/reduced_for: [food, books]/' rules/mwst.yaml && rm rules/mwst.yaml.bak
ci Ravi "2025-01-14T10:00:00" "MwSt: reduced rate also for books"
printf 'country: FR\nname: TVA\nstandard: 0.20\nreduced: 0.055\nvalid_from: 2021-01-01\n' > rules/fr_tva.yaml
ci Dana "2025-01-20T11:00:00" "Add French TVA rule"
git mv rules/mwst.yaml rules/vat_de.yaml
ci Mei "2025-02-03T09:00:00" "Rename mwst.yaml to vat_de.yaml"
sed -i.bak 's/^name: Mehrwertsteuer/name: Mehrwertsteuer (VAT)/' rules/vat_de.yaml && rm rules/vat_de.yaml.bak
ci Ravi "2025-02-10T10:30:00" "Clarify DE rule display name"
printf 'country: ES\nname: IVA\nstandard: 0.21\nreduced: 0.10\nvalid_from: 2021-01-01\n' > rules/es_iva.yaml
ci Mei "2025-02-18T12:00:00" "Add Spanish IVA rule"
mkdir rules/de
git mv rules/vat_de.yaml rules/de/vat.yaml
ci Dana "2025-03-05T09:00:00" "Group DE rules in a country folder"
printf 'small_business_limit: 22000\n' >> rules/de/vat.yaml
ci Ravi "2025-03-12T15:00:00" "Add Kleinunternehmer threshold"
