#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

mkdir -p project/css project/img
cd project
cat > index.html <<'EOF'
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>Lena Park - Illustrator</title>
<link rel="stylesheet" href="css/site.css"></head>
<body>
  <h1>Lena Park</h1>
  <p>Children's book illustrator based in Leeds.</p>
  <a href="about.html">About me</a>
</body>
</html>
EOF
cat > about.html <<'EOF'
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>About - Lena Park</title></head>
<body><h1>About</h1><p>I paint with gouache and ink.</p></body>
</html>
EOF
cat > css/site.css <<'EOF'
body { font-family: Georgia, serif; max-width: 40rem; margin: 2rem auto; }
h1 { color: #3b5b4a; }
EOF
printf 'placeholder for cover art\n' > img/README.txt
