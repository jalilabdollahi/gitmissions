#!/usr/bin/env bash
set -e
git rebase --onto main feature/payments-api feature/refund-ui
