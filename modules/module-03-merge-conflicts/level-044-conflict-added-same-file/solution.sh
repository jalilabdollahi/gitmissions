#!/usr/bin/env bash
set -e
git merge contributing-style || true     # CONFLICT (add/add)
cat > CONTRIBUTING.md <<'EOF'
# Contributing to knitgen

## Code style
- Format Python with black before committing.
- Keep functions under 40 lines.

## Commit messages
- Use the imperative mood: "Add chart legend".
- Reference the issue number, e.g. "Fixes #12".
EOF
git add CONTRIBUTING.md
git commit -m "Merge contributing-style: one guide with both sections"
