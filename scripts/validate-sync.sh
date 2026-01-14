#!/bin/bash
set -e

# Source of truth
SOURCE_SCHEMA="packages/schema/schemas/v1/retropak.schema.json"
SOURCE_LOCALE="packages/schema/locales/en.json"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🔍 Validating schema and locale files are in sync..."
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

ERRORS=0

# Validate schema files
for target in "${TARGETS[@]}"; do
    if [ ! -f "$target" ]; then
        echo -e "${RED}✗${NC} $target (missing)"
        ERRORS=$((ERRORS + 1))
    elif ! cmp -s "$SOURCE_SCHEMA" "$target"; then
        echo -e "${RED}✗${NC} $target (out of sync)"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓${NC} $target"
    fi
done

# Validate locale files
for target in "${LOCALE_TARGETS[@]}"; do
    if [ ! -f "$target" ]; then
        echo -e "${RED}✗${NC} $target (missing)"
        ERRORS=$((ERRORS + 1))
    elif ! cmp -s "$SOURCE_LOCALE" "$target"; then
        echo -e "${RED}✗${NC} $target (out of sync)"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓${NC} $target"
    fi
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All files in sync!${NC}"
    exit 0
else
    echo -e "${RED}❌ $ERRORS file(s) out of sync!${NC}"
    echo ""
    echo "Run: npm run sync"
    exit 1
fi
