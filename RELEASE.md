# Release Checklist

## Creating a New Release

### 1. Prepare the release

```bash
# Update versions in package.json files
cd packages/schema && npm version patch  # or minor/major
cd ../types && npm version patch
cd ../..

# Update Package.swift version if needed
```

### 2. Commit version changes

```bash
git add packages/*/package.json Package.swift
git commit -m "chore: bump version to 1.0.0"
git push
```

### 3. Create and push tag

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 4. GitHub Actions automatically:

- ✅ Syncs schema files to all locations
- ✅ Validates sync
- ✅ Builds all packages
- ✅ Creates release commit with synced files
- ✅ Moves tag to release commit
- ✅ Publishes to npm
- ✅ Creates GitHub release

### 5. Verify

- Check [GitHub Releases](https://github.com/piersroberts/retropak/releases)
- Check [npm packages](https://www.npmjs.com/~retropak)
- Test Swift Package Manager: `swift package resolve`

## Important Notes

- **Main branch**: Only contains `packages/schema/` (source of truth)
- **Release tags**: Contain synced files for all packages
- **Swift Package Manager**: Pulls from git tags (which have synced files)
- **npm packages**: Published from release commits (which have synced files)

## Manual Sync (for testing only)

```bash
npm run sync           # Copy files locally
npm run validate:sync  # Verify sync
```

Files synced locally will NOT be committed to main branch (they're gitignored).
