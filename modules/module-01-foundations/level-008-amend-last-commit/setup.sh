#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Kofi" GIT_AUTHOR_EMAIL="kofi@tinytools.example"
export GIT_COMMITTER_NAME="Kofi" GIT_COMMITTER_EMAIL="kofi@tinytools.example"

cat > greet.py <<'EOF'
import sys

def greet(name):
    return "Hello, " + name

if __name__ == "__main__":
    print(greet(sys.argv[1] if len(sys.argv) > 1 else "world"))
EOF
printf '# greet\nA tiny greeting tool.\n' > README.md
git add .
GIT_AUTHOR_DATE="2025-06-01T10:00:00" GIT_COMMITTER_DATE="2025-06-01T10:00:00" git commit -q -m "Add greet script"

printf 'usage: python greet.py [name]\n' > USAGE.txt
git add USAGE.txt
GIT_AUTHOR_DATE="2025-06-02T10:00:00" GIT_COMMITTER_DATE="2025-06-02T10:00:00" git commit -q -m "Add usage note"

cat > greet.py <<'EOF'
import sys

def greet(name, shout=False):
    text = "Hello, " + name
    return text.upper() if shout else text

if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--shout"]
    print(greet(args[0] if args else "world", shout="--shout" in sys.argv))
EOF
printf 'def test_shout():\n    from greet import greet\n    assert greet("a", shout=True) == "HELLO, A"\n' > test_greet.py
git add greet.py
GIT_AUTHOR_DATE="2025-06-03T10:00:00" GIT_COMMITTER_DATE="2025-06-03T10:00:00" git commit -q -m "Add --shuot flag to greet"
