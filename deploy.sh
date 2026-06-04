#!/usr/bin/env bash
#
# Deploy this website to GitHub Pages.
#
# Usage:
#   ./deploy.sh                 # deploys to the user site  hibasameen.github.io
#   ./deploy.sh my-repo-name    # deploys to a project site hibasameen.github.io/my-repo-name
#
# If the GitHub CLI (`gh`) is installed and logged in, this script creates the
# repo and turns on Pages for you. Otherwise it pushes to a repo you create
# manually and prints the one remaining click.

set -euo pipefail

USER="hibasameen"
REPO="${1:-$USER.github.io}"
REMOTE="https://github.com/$USER/$REPO.git"

# Run from the folder this script lives in.
cd "$(dirname "$0")"

echo "→ Repository: $USER/$REPO"
echo

# 1. Clear any stale git lock left behind by iCloud.
rm -f .git/index.lock .git/HEAD.lock 2>/dev/null || true

# 2. Initialise the repo on first run.
if [ ! -d .git ]; then
  echo "→ Initialising git repository"
  git init -q
  git symbolic-ref HEAD refs/heads/main
fi

# 3. Make sure a commit identity exists.
git config user.name  >/dev/null 2>&1 || git config user.name  "Hiba Sameen"
git config user.email >/dev/null 2>&1 || git config user.email "hiba.sameen@gmail.com"

# 4. Commit any changes.
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "Update website ($(date +%Y-%m-%d))"
  echo "→ Committed latest changes"
else
  echo "→ No changes to commit"
fi
git branch -M main

# 5. Point 'origin' at the right remote.
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REMOTE"
else
  git remote add origin "$REMOTE"
fi

# 6. If gh is available and authenticated, create the repo + enable Pages.
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  echo "→ GitHub CLI detected — setting things up automatically"
  if ! gh repo view "$USER/$REPO" >/dev/null 2>&1; then
    echo "→ Creating repository $USER/$REPO"
    gh repo create "$USER/$REPO" --public --source=. --remote=origin --push
  else
    echo "→ Pushing to existing repository"
    git push -u origin main
  fi
  echo "→ Enabling GitHub Pages (GitHub Actions source)"
  gh api -X POST "repos/$USER/$REPO/pages" -f build_type=workflow >/dev/null 2>&1 \
    || gh api -X PUT "repos/$USER/$REPO/pages" -f build_type=workflow >/dev/null 2>&1 \
    || echo "  (Pages may already be enabled — check Settings → Pages)"
  echo
  if [ "$REPO" = "$USER.github.io" ]; then
    echo "✓ Done. Your site will be live at: https://$USER.github.io  (~1 min)"
  else
    echo "✓ Done. Your site will be live at: https://$USER.github.io/$REPO/  (~1 min)"
  fi
  exit 0
fi

# 7. Fallback: no gh. Push and print the one manual step.
echo
echo "GitHub CLI not found. Pushing with git instead."
echo "First, create an EMPTY repo named '$REPO' at: https://github.com/new"
echo "(no README, no .gitignore, no license), then this script will push."
echo
read -r -p "Press Enter once the empty repo exists..." _
git push -u origin main
echo
echo "✓ Pushed. Last step — turn on Pages:"
echo "  Settings → Pages → Build and deployment → Source → GitHub Actions"
if [ "$REPO" = "$USER.github.io" ]; then
  echo "  Then your site is live at: https://$USER.github.io"
else
  echo "  Then your site is live at: https://$USER.github.io/$REPO/"
fi
