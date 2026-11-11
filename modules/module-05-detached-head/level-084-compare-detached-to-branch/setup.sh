#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main pagecraft
cd pagecraft
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
mkdir pages
printf '# Home\n' > pages/home.md && c "Home page"
printf '# About\n' > pages/about.md && c "About page"
printf '# Pricing\n' > pages/pricing.md && c "Pricing page"
printf '# Contact\n' > pages/contact.md && c "Contact page"
git tag v5.0
printf '# Home\nNew hero section\n' > pages/home.md && c "New hero section"
git rm -q pages/contact.md && c "Retire contact page"
printf '# Blog\n' > pages/blog.md && c "Add blog"
printf '# Pricing\nTeam plan\n' > pages/pricing.md && c "Add team plan"
printf '# Blog\nFirst post\n' > pages/blog.md && c "Write first blog post"
printf 'About us, updated\n' >> pages/about.md && c "Refresh about copy"
git switch -q --detach v5.0
