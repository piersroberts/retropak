#!/bin/bash
set -e

mkdir -p site
mkdir -p docs/schemas/v1

cp schemas/v1/retropak.schema.json docs/schemas/v1/retropak.schema.json

mkdocs build


echo "Build complete!"
