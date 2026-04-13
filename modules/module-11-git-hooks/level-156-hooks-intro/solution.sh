#!/usr/bin/env bash
set -e

printf '#!/usr/bin/env bash
echo hook ok
' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
