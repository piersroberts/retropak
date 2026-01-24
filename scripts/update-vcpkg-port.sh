#!/bin/bash
set -e

# Script to update the vcpkg port for retropak
# This automates the tedious process of updating versions and SHA512 hashes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PORTFILE="$ROOT_DIR/ports/retropak/portfile.cmake"
PORT_VCPKG_JSON="$ROOT_DIR/ports/retropak/vcpkg.json"
ROOT_VCPKG_JSON="$ROOT_DIR/vcpkg.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Retropak vcpkg Port Update Script       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Get current version from package.json
CURRENT_VERSION=$(node -p "require('$ROOT_DIR/package.json').version")
echo -e "${YELLOW}Current version:${NC} $CURRENT_VERSION"

# Prompt for new version
read -p "Enter new version (or press Enter to keep $CURRENT_VERSION): " NEW_VERSION
if [ -z "$NEW_VERSION" ]; then
    NEW_VERSION="$CURRENT_VERSION"
fi
echo -e "${GREEN}Using version:${NC} $NEW_VERSION"
echo ""

# Update package.json
echo -e "${BLUE}→${NC} Updating package.json..."
if command -v jq &> /dev/null; then
    jq --arg version "$NEW_VERSION" '.version = $version' "$ROOT_DIR/package.json" > "$ROOT_DIR/package.json.tmp"
    mv "$ROOT_DIR/package.json.tmp" "$ROOT_DIR/package.json"
else
    # Fallback to sed if jq is not available
    sed -i.bak "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" "$ROOT_DIR/package.json"
    rm -f "$ROOT_DIR/package.json.bak"
fi

# Update vcpkg.json files
echo -e "${BLUE}→${NC} Updating vcpkg.json files..."
for VCPKG_FILE in "$ROOT_VCPKG_JSON" "$PORT_VCPKG_JSON"; do
    if command -v jq &> /dev/null; then
        jq --arg version "$NEW_VERSION" '.version = $version' "$VCPKG_FILE" > "$VCPKG_FILE.tmp"
        mv "$VCPKG_FILE.tmp" "$VCPKG_FILE"
    else
        sed -i.bak "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" "$VCPKG_FILE"
        rm -f "$VCPKG_FILE.bak"
    fi
done

# Calculate SHA512 hash for the GitHub release archive
echo ""
echo -e "${BLUE}→${NC} Downloading release archive to calculate SHA512..."
GITHUB_REPO="piersroberts/retropak"
ARCHIVE_URL="https://github.com/$GITHUB_REPO/archive/refs/tags/v$NEW_VERSION.tar.gz"
TEMP_FILE=$(mktemp)

if curl -L -f -o "$TEMP_FILE" "$ARCHIVE_URL" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Downloaded archive from GitHub"
    
    # Calculate SHA512
    if command -v shasum &> /dev/null; then
        SHA512=$(shasum -a 512 "$TEMP_FILE" | awk '{print $1}')
    elif command -v sha512sum &> /dev/null; then
        SHA512=$(sha512sum "$TEMP_FILE" | awk '{print $1}')
    else
        echo -e "${RED}✗${NC} Error: Neither shasum nor sha512sum found"
        rm -f "$TEMP_FILE"
        exit 1
    fi
    
    rm -f "$TEMP_FILE"
    
    echo -e "${GREEN}✓${NC} Calculated SHA512 hash"
    echo -e "${YELLOW}SHA512:${NC} $SHA512"
    echo ""
    
    # Update portfile.cmake with new SHA512
    echo -e "${BLUE}→${NC} Updating portfile.cmake..."
    sed -i.bak "s/SHA512 [a-f0-9]*/SHA512 $SHA512/" "$PORTFILE"
    rm -f "$PORTFILE.bak"
    echo -e "${GREEN}✓${NC} Updated SHA512 in portfile.cmake"
else
    echo -e "${YELLOW}⚠${NC}  Could not download archive from GitHub"
    echo -e "${YELLOW}⚠${NC}  Make sure tag v$NEW_VERSION exists on GitHub first!"
    echo ""
    echo -e "${YELLOW}To update manually later:${NC}"
    echo "  1. Create and push tag: git tag v$NEW_VERSION && git push origin v$NEW_VERSION"
    echo "  2. Download: curl -L $ARCHIVE_URL -o archive.tar.gz"
    echo "  3. Calculate hash: shasum -a 512 archive.tar.gz"
    echo "  4. Update SHA512 in $PORTFILE"
    rm -f "$TEMP_FILE"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Update Complete!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the changes: git diff"
echo "  2. Commit changes: git add -A && git commit -m 'chore: bump version to $NEW_VERSION'"
echo "  3. Create tag: git tag v$NEW_VERSION"
echo "  4. Push: git push origin main --tags"
echo "  5. Test vcpkg port: vcpkg install retropak --overlay-ports=./ports"
echo ""
