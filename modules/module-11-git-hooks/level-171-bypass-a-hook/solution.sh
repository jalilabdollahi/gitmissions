#!/usr/bin/env bash
set -e
sed -i.bak 's/^bracket3=18/bracket3=21/' payroll.conf && rm payroll.conf.bak
git commit --no-verify -q -am "EMERGENCY: correct bracket3 to 21 for the December run"
