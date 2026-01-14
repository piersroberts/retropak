#!/bin/bash
set -e

echo "🔨 Building all packages..."
npm run build

echo "✅ Validating schema..."
npm run validate --workspace=@retropak/schema --if-present

echo "📦 Checking package contents..."
echo ""
echo "Schema package exports:"
cd packages/schema && npm pack --dry-run 2>&1 | grep -E "(schemas|locales)" || true
cd ../..

echo ""
echo "Types package exports:"
cd packages/types && npm pack --dry-run 2>&1 | grep -E "dist/" || true
cd ../..

echo ""
echo "✅ All checks passed!"
