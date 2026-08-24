#!/usr/bin/env bash
set -euo pipefail

files=(index.html redoc.standalone.js logo.png CNAME)
branch=gh-pages
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for f in "${files[@]}"; do
  [ -f "$f" ] || { echo "missing $f"; exit 1; }
  cp "$f" "$tmp/"
done

source_commit=$(git rev-parse --short HEAD)
git fetch origin "$branch" 2>/dev/null || true
worktree=$(mktemp -d); rm -rf "$worktree"
git worktree add --force "$worktree" "origin/$branch" 2>/dev/null || git worktree add --force -b "$branch" "$worktree"
trap 'git worktree remove --force "$worktree" >/dev/null 2>&1; rm -rf "$tmp"' EXIT

( cd "$worktree" && git rm -rq . 2>/dev/null || true )
cp "$tmp"/* "$worktree/"
( cd "$worktree"
  git add -A
  git commit -q -m "Site updated to $source_commit" || { echo "nothing to publish"; exit 0; }
  git push -q origin "HEAD:$branch"
)
echo "published $source_commit to $branch"
