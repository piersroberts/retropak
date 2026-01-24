#!/bin/bash
set -e

# Script to install git hooks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$ROOT_DIR/.git/hooks"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Skip in CI environments
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$GITLAB_CI" ] || [ -n "$CIRCLECI" ] || [ -n "$TRAVIS" ]; then
    echo -e "${YELLOW}Skipping git hooks installation in CI environment${NC}"
    exit 0
fi

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Installing Git Hooks                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Check if .git directory exists
if [ ! -d "$HOOKS_DIR" ]; then
    echo -e "${YELLOW}Skipping: .git/hooks directory not found${NC}"
    echo -e "${YELLOW}(This is normal for npm packages installed as dependencies)${NC}"
    exit 0
fi

# Install pre-push hook
echo -e "${BLUE}→${NC} Installing pre-push hook..."
cp "$SCRIPT_DIR/pre-push-hook" "$HOOKS_DIR/pre-push"
chmod +x "$HOOKS_DIR/pre-push"
echo -e "${GREEN}✓${NC} Pre-push hook installed"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Hooks Installed Successfully!           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo "The following hooks are now active:"
echo "  • pre-push: Syncs Swift package before pushing"
echo ""
