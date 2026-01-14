#!/bin/bash
set -e

# Source of truth
SOURCE_SCHEMA="packages/schema/schemas/v1/retropak.schema.json"
SOURCE_LOCALE="packages/schema/locales/en.json"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "📋 Syncing schema and locales from packages/schema/ (source of truth)..."
echo ""

# Target locations
TARGETS=(
    "schemas/v1/retropak.schema.json"
    "packages/swift/Sources/RetropakSchema/schemas/v1/retropak.schema.json"
    "docs/schemas/v1/retropak.schema.json"
)

LOCALE_TARGETS=(
    "locales/en.json"
    "packages/swift/Sources/RetropakSchema/locales/en.json"
)

# Copy schema files
for target in "${TARGETS[@]}"; do
    mkdir -p "$(dirname "$target")"
    if cmp -s "$SOURCE_SCHEMA" "$target"; then
        echo -e "${GREEN}✓${NC} $target (already in sync)"
    else
        cp "$SOURCE_SCHEMA" "$target"
        echo -e "${YELLOW}→${NC} $target (updated)"
    fi
done

# Copy locale files
for target in "${LOCALE_TARGETS[@]}"; do
    mkdir -p "$(dirname "$target")"
    if cmp -s "$SOURCE_LOCALE" "$target"; then
        echo -e "${GREEN}✓${NC} $target (already in sync)"
    else
        cp "$SOURCE_LOCALE" "$target"
        echo -e "${YELLOW}→${NC} $target (updated)"
    fi
done

echo ""
echo -e "${GREEN}✅ Sync complete!${NC}"
echo ""
echo "Source of truth: packages/schema/"
