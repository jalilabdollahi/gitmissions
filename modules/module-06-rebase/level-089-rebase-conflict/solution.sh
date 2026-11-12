#!/usr/bin/env bash
set -e
git rebase main || true
printf 'TAX_RATE = {"NL": 0.21, "DE": 0.19}\n\ndef total(net):\n    return net * (1 + TAX_RATE["NL"])\n' > billing.py
git add billing.py
git -c core.editor=true rebase --continue
