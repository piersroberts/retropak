# Development Notes

## Schema File Management

### Source of Truth

**`packages/schema/`** is the authoritative source for:
- `schemas/v1/retropak.schema.json`
- `locales/en.json`

**This is the ONLY location committed to the main branch.**

### Synced Locations (Generated for Releases)

The schema and locales are copied to multiple locations during the release process:

```
packages/schema/                              ← SOURCE OF TRUTH (committed to main)
├── schemas/v1/retropak.schema.json          
└── locales/en.json

schemas/v1/retropak.schema.json              ← Generated for releases (gitignored)
locales/en.json                               ← Generated for releases (gitignored)

docs/schemas/v1/retropak.schema.json          ← Generated for releases (gitignored)

packages/swift/Sources/RetropakSchema/
├── schemas/v1/retropak.schema.json          ← Generated for releases (gitignored)
└── locales/en.json                           ← Generated for releases (gitignored)
```

### Why This Approach?

- **Clean main branch**: Only source of truth is version controlled
- **No duplication in development**: Reduces conflicts and confusion
- **Release tags have everything**: Swift Package Manager and npm packages work correctly
- **Single source of truth**: Edit once, sync on release

### Workflow

**During development:**

1. Edit files in `packages/schema/` only
2. Commit changes to main branch
3. No need to sync manually - synced files are gitignored

**Creating a release:**

```bash
# 1. Update version in package.json files
npm version patch  # or minor, major

# 2. Create and push a version tag
git tag v1.0.0
git push origin v1.0.0

# 3. GitHub Actions will:
#    - Sync all schema files
#    - Create release commit with synced files
#    - Move tag to release commit
#    - Publish npm packages
#    - Create GitHub release
```

**For local testing (optional):**

```bash
npm run sync           # Copy files locally
npm run validate:sync  # Verify sync worked
```

### Scripts

- `npm run sync` - Copy files from source of truth to all locations
- `npm run validate:sync` - Verify all locations are in sync
- `npm run build` - Automatically syncs before building
