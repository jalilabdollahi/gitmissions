#!/usr/bin/env bash
set -e
cat > .git/hooks/pre-push <<'HOOK'
#!/bin/sh
# Run the test script before any push; abort the push if it fails
echo "pre-push: running tests..."
if ! ./run_tests.sh; then
  echo "pre-push: tests failed, push aborted" >&2
  exit 1
fi
exit 0
HOOK
chmod +x .git/hooks/pre-push
