#!/usr/bin/env bash
set -euo pipefail

branch=gh-pages
files=(index.html redoc.standalone.js logo.png CNAME)

for f in "${files[@]}"; do
  [ -f "$f" ] || { echo "missing $f" >&2; exit 1; }
done

source_commit=$(git rev-parse --short HEAD)
staging=$(mktemp -d)
worktree=$(mktemp -d); rm -rf "$worktree"
cleanup() {
  git worktree remove --force "$worktree" >/dev/null 2>&1 || true
  rm -rf "$staging"
}
trap cleanup EXIT

cp "${files[@]}" "$staging/"

git fetch --no-tags origin "+refs/heads/$branch:refs/remotes/origin/$branch"
git worktree add --detach "$worktree" "refs/remotes/origin/$branch"

(
  cd "$worktree"
  git rm -rq . >/dev/null 2>&1 || true
  cp "$staging"/* .
  git add -A
  if git diff --cached --quiet; then
    echo "nothing to publish, $branch already matches $source_commit"
    exit 0
  fi
  git commit -q -m "Site updated to $source_commit"
  git push origin "HEAD:refs/heads/$branch"
  echo "published $source_commit to $branch"
)
