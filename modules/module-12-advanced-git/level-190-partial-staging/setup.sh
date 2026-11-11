#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

mkdir payroll && cd payroll
git init -q -b main
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
cat > payroll.py <<'EOF'
"""Monthly payroll runner."""
import csv
import sys

TAX_RATE = 0.20
OVERTIME_FACTOR = 1.5
STANDARD_HOURS = 160


def calc(hours, rate):
    base = min(hours, STANDARD_HOURS) * rate
    extra = max(hours - STANDARD_HOURS, 0) * rate * OVERTIME_FACTOR
    gross = base + extra
    net = gross * (1 - TAX_RATE)
    return round(net)


def load(path):
    with open(path) as handle:
        return list(csv.DictReader(handle))


def validate(rows):
    for row in rows:
        if float(row["hours"]) < 0:
            raise ValueError("negative hours for " + row["name"])
    return rows


def fmt_row(name, net):
    return "%-12s %10s" % (name, net)


def report(rows):
    lines = []
    for row in rows:
        net = calc(float(row["hours"]), float(row["rate"]))
        lines.append(fmt_row(row["name"], net))
    return "\n".join(lines)


def main(argv):
    rows = validate(load(argv[1]))
    print(report(rows))


if __name__ == "__main__":
    main(sys.argv)
EOF
git add -A; ci Ola ola@pay.dev "2025-03-03T09:00:00" "Payroll runner"
printf '# payroll\n' > README.md
git add -A; ci Ola ola@pay.dev "2025-03-04T09:00:00" "Add readme"
printf 'name,hours,rate\nanna,170,20\nben,150,22\n' > sample.csv
git add -A; ci Ola ola@pay.dev "2025-03-05T09:00:00" "Add sample data"
python3 - <<'EOF'
s = open('payroll.py').read()
s = s.replace("    gross = base + extra\n", '    gross = base + extra\n    print("DEBUG gross", gross)\n')
s = s.replace("return round(net)", "return round(net, 2)")
s = s.replace("fmt_row", "format_row")
open('payroll.py', 'w').write(s)
EOF
