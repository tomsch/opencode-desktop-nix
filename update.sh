#!/usr/bin/env bash
# Update script for opencode-desktop package
# Usage: ./update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"

# Get latest version from GitHub API
echo "Fetching latest version..."
LATEST_VERSION=$(curl -sL "https://api.github.com/repos/anomalyco/opencode/releases/latest" | jq -r '.tag_name' | sed 's/^v//')

# Get current version from package.nix
CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*"\(.*\)".*/\1/')

echo "Current version: $CURRENT_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Already up to date!"
    exit 0
fi

# Construct download URL
DOWNLOAD_URL="https://github.com/anomalyco/opencode/releases/download/v${LATEST_VERSION}/opencode-desktop-linux-amd64.AppImage"

# Fetch new hash
echo "Fetching hash for $LATEST_VERSION..."
NEW_HASH=$(nix-prefetch-url "$DOWNLOAD_URL" 2>&1 | tail -1)
SRI_HASH=$(nix hash convert --to sri --hash-algo sha256 "$NEW_HASH")

echo "New SRI hash: $SRI_HASH"

# Update package.nix - version
sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$LATEST_VERSION\"/" "$PACKAGE_NIX"

# Update package.nix - hash
sed -i "s|hash = \"sha256-.*\"|hash = \"$SRI_HASH\"|" "$PACKAGE_NIX"

echo "Updated package.nix to version $LATEST_VERSION"
