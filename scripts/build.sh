#!/bin/bash
set -e

mkdir -p site

mkdocs build

mkdir -p site/schemas/v1
cp schemas/v1/retropak.schema.json site/schemas/v1/retropak.schema.json

echo "Build complete!"
