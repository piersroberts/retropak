#!/bin/bash
set -e

# Script to validate that all schema enum values have corresponding locale entries

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEMA_FILE="$ROOT_DIR/packages/schema/schemas/v1/retropak.schema.json"
LOCALE_FILE="$ROOT_DIR/packages/schema/locales/en.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Retropak Locale Validation              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Check if files exist
if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}✗${NC} Error: Schema file not found: $SCHEMA_FILE"
    exit 1
fi

if [ ! -f "$LOCALE_FILE" ]; then
    echo -e "${RED}✗${NC} Error: Locale file not found: $LOCALE_FILE"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗${NC} Error: jq is not installed"
    exit 1
fi

echo -e "${BLUE}→${NC} Validating locale entries for schema enums..."
echo ""

MISSING_COUNT=0
TOTAL_CHECKED=0

# Extract enum definitions from schema
# Find all paths that end with .enum in the $defs section
ENUM_PATHS=$(jq -r '."$defs" | paths(type == "array" and (. | length > 0) and (.[0] | type == "string")) | 
    select(.[1] == "enum") | 
    .[0]' "$SCHEMA_FILE")

# Process each enum type
while IFS= read -r ENUM_TYPE; do
    if [ -z "$ENUM_TYPE" ]; then
        continue
    fi
    
    echo -e "${YELLOW}Checking enum: ${BLUE}$ENUM_TYPE${NC}"
    
    # Get all enum values for this type
    ENUM_VALUES=$(jq -r ".\"\$defs\".\"$ENUM_TYPE\".enum[]" "$SCHEMA_FILE")
    
    # Check if locale has a section for this enum type
    if ! jq -e ".\"$ENUM_TYPE\"" "$LOCALE_FILE" > /dev/null 2>&1; then
        echo -e "  ${RED}✗${NC} Missing entire locale section: $ENUM_TYPE"
        MISSING_COUNT=$((MISSING_COUNT + $(echo "$ENUM_VALUES" | wc -l)))
        TOTAL_CHECKED=$((TOTAL_CHECKED + $(echo "$ENUM_VALUES" | wc -l)))
        continue
    fi
    
    # Check each enum value
    TYPE_MISSING=0
    TYPE_TOTAL=0
    while IFS= read -r ENUM_VALUE; do
        if [ -z "$ENUM_VALUE" ]; then
            continue
        fi
        
        TYPE_TOTAL=$((TYPE_TOTAL + 1))
        TOTAL_CHECKED=$((TOTAL_CHECKED + 1))
        
        # Check if locale has this specific value
        if ! jq -e ".\"$ENUM_TYPE\".\"$ENUM_VALUE\"" "$LOCALE_FILE" > /dev/null 2>&1; then
            if [ $TYPE_MISSING -eq 0 ]; then
                echo -e "  ${RED}Missing values:${NC}"
            fi
            echo -e "    ${RED}✗${NC} $ENUM_VALUE"
            TYPE_MISSING=$((TYPE_MISSING + 1))
            MISSING_COUNT=$((MISSING_COUNT + 1))
        fi
    done <<< "$ENUM_VALUES"
    
    if [ $TYPE_MISSING -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} All $TYPE_TOTAL values present"
    else
        echo -e "  ${RED}Missing $TYPE_MISSING of $TYPE_TOTAL values${NC}"
    fi
    echo ""
done <<< "$ENUM_PATHS"

# Check for extra locale entries that don't exist in schema
echo -e "${YELLOW}Checking for extra locale entries...${NC}"
echo ""

EXTRA_COUNT=0

LOCALE_TYPES=$(jq -r 'keys[]' "$LOCALE_FILE")

while IFS= read -r LOCALE_TYPE; do
    if [ -z "$LOCALE_TYPE" ]; then
        continue
    fi
    
    # Check if this type exists in schema
    if ! jq -e ".\"\$defs\".\"$LOCALE_TYPE\"" "$SCHEMA_FILE" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠${NC}  Extra locale section not in schema: ${BLUE}$LOCALE_TYPE${NC}"
        EXTRA_COUNT=$((EXTRA_COUNT + 1))
        continue
    fi
    
    # Check each locale value against schema
    LOCALE_VALUES=$(jq -r ".\"$LOCALE_TYPE\" | keys[]" "$LOCALE_FILE")
    TYPE_EXTRA=0
    
    while IFS= read -r LOCALE_VALUE; do
        if [ -z "$LOCALE_VALUE" ]; then
            continue
        fi
        
        # Check if this value exists in schema enum
        if ! jq -e ".\"\$defs\".\"$LOCALE_TYPE\".enum | index(\"$LOCALE_VALUE\")" "$SCHEMA_FILE" > /dev/null 2>&1; then
            if [ $TYPE_EXTRA -eq 0 ]; then
                echo -e "${YELLOW}⚠${NC}  Extra values in ${BLUE}$LOCALE_TYPE${NC}:"
            fi
            echo -e "    ${YELLOW}⚠${NC}  $LOCALE_VALUE"
            TYPE_EXTRA=$((TYPE_EXTRA + 1))
            EXTRA_COUNT=$((EXTRA_COUNT + 1))
        fi
    done <<< "$LOCALE_VALUES"
    
    if [ $TYPE_EXTRA -gt 0 ]; then
        echo ""
    fi
done <<< "$LOCALE_TYPES"

# Summary
echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "  Total enum values checked: $TOTAL_CHECKED"
echo -e "  Missing locale entries: ${RED}$MISSING_COUNT${NC}"
echo -e "  Extra locale entries: ${YELLOW}$EXTRA_COUNT${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""

# Exit with appropriate code
if [ $MISSING_COUNT -gt 0 ]; then
    echo -e "${RED}╔══════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  Validation Failed!                      ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Please add missing locale entries to:${NC}"
    echo "  $LOCALE_FILE"
    echo ""
    exit 1
elif [ $EXTRA_COUNT -gt 0 ]; then
    echo -e "${YELLOW}╔══════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  Validation Passed with Warnings         ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
else
    echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Validation Passed!                      ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
fi
