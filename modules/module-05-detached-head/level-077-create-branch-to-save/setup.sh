#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main refundly
cd refundly
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'def refund(amount):\n    return round(amount, 2)\n' > refund.py && c "Implement full refunds"
git tag v2.7.0
git branch release/2.7
printf 'def partial(amount, pct):\n    return amount * pct\n' > partial.py && c "Add partial refund API"
git switch -q --detach v2.7.0
printf 'from decimal import Decimal, ROUND_HALF_UP\n\ndef refund(amount):\n    return Decimal(amount).quantize(Decimal("0.01"), ROUND_HALF_UP)\n' > refund.py && c "Round refunds half-up"
printf 'from refund import refund\nassert str(refund("1.005")) == "1.01"\n' > test_refund.py && c "Cover half-up rounding with a test"
