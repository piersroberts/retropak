#!/bin/bash
set -e

# Script to sync schema and locale files to the Swift package
# This ensures the Swift package has the latest schema and localization files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEMA_SOURCE="$ROOT_DIR/packages/schema"
SWIFT_TARGET="$ROOT_DIR/packages/swift/Sources/RetropakSchema"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Retropak Swift Package Sync             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Check if source directories exist
if [ ! -d "$SCHEMA_SOURCE" ]; then
    echo -e "${RED}✗${NC} Error: Schema source directory not found: $SCHEMA_SOURCE"
    exit 1
fi

if [ ! -d "$SWIFT_TARGET" ]; then
    echo -e "${RED}✗${NC} Error: Swift target directory not found: $SWIFT_TARGET"
    exit 1
fi

# Sync schemas
echo -e "${BLUE}→${NC} Syncing schemas..."
if [ -d "$SCHEMA_SOURCE/schemas" ]; then
    rsync -av --delete "$SCHEMA_SOURCE/schemas/" "$SWIFT_TARGET/schemas/"
    echo -e "${GREEN}✓${NC} Schemas synced"
else
    echo -e "${YELLOW}⚠${NC}  No schemas directory found in source"
fi

# Sync locales
echo -e "${BLUE}→${NC} Syncing locales..."
if [ -d "$SCHEMA_SOURCE/locales" ]; then
    rsync -av --delete "$SCHEMA_SOURCE/locales/" "$SWIFT_TARGET/locales/"
    echo -e "${GREEN}✓${NC} Locales synced"
else
    echo -e "${YELLOW}⚠${NC}  No locales directory found in source"
fi

# Show what was synced
echo ""
echo -e "${BLUE}Files in Swift package:${NC}"
echo -e "${YELLOW}Schemas:${NC}"
find "$SWIFT_TARGET/schemas" -type f | sed "s|$SWIFT_TARGET/||" | sort
echo ""
echo -e "${YELLOW}Locales:${NC}"
find "$SWIFT_TARGET/locales" -type f | sed "s|$SWIFT_TARGET/||" | sort

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Sync Complete!                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review the changes: git diff packages/swift/"
echo "  2. Test Swift package: swift build"
echo "  3. Commit if needed: git add packages/swift/ && git commit -m 'chore: sync Swift package resources'"
echo ""
