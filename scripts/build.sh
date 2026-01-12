#!/bin/bash
set -e

echo "Copying static files..."

# Copy schema to root of site
mkdir -p site
cp schemas/v1/retropak.schema.json site/retropak.schema.json

# Copy locale files
mkdir -p site/locales
cp locales/en.json site/locales/en.json

echo "Building documentation with mkdocs..."
mkdocs build

echo "Build complete!"
