#!/bin/bash

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./release.sh 1.0.2"
  exit 1
fi

echo "Releasing v$VERSION..."

# Commit source changes
git add .
git commit -m "release v$VERSION" || echo "Nothing to commit"
git push

# Tag release
git tag v$VERSION
git push origin v$VERSION

# Generate SHA256
SHA=$(curl -sL https://github.com/gabex47/ohsh/archive/refs/tags/v$VERSION.tar.gz | shasum -a 256 | awk '{print $1}')

echo "SHA256: $SHA"

# Go to tap repo
cd ../homebrew-ohsh

# Update formula
sed -i '' "s/version \".*\"/version \"$VERSION\"/" Formula/ohsh.rb
sed -i '' "s|refs/tags/v.*.tar.gz|refs/tags/v$VERSION.tar.gz|" Formula/ohsh.rb
sed -i '' "s/sha256 \".*\"/sha256 \"$SHA\"/" Formula/ohsh.rb

git add Formula/ohsh.rb
git commit -m "bump ohsh to $VERSION"
git push

echo "Release v$VERSION complete."
