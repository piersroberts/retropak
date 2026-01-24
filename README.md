# Retropak

> A modern container format for retro software preservation

Retropak (`.rpk`) is an open standard for distributing retro software with everything in one place: ROMs, artwork, soundtracks, manuals, and metadata.

## Features

- **Self-contained** — Box art, manuals, soundtracks, and software all in one file
- **Self-describing** — Rich metadata with no external database lookups required
- **Tamper-proof** — Optional cryptographic signing
- **Accessible** — Built-in alt text support for all images
- **Developer-friendly** — Structured JSON schema with TypeScript types

## Quick Start

### TypeScript/JavaScript
```bash
npm install @retropak/types
```

### Swift
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/piersroberts/retropak.git", from: "1.0.0")
]
```

### C++ (vcpkg)
```bash
vcpkg install retropak
```

## Documentation

Visit [retropak.org](https://retropak.org) for the full specification, examples, and tools.

## Packages

- [`@retropak/schema`](packages/schema) — JSON Schema definition
- [`@retropak/types`](packages/types) — TypeScript types
- [`RetropakSchema`](packages/swift) — Swift package
- [`retropak`](packages/vcpkg) — vcpkg package for C++ projects

## Development

### Setup

Clone the repository and install dependencies:
```bash
git clone https://github.com/piersroberts/retropak.git
cd retropak
npm install
```

Git hooks will be installed automatically via the `prepare` script.

### Available Scripts

- **`npm run sync-swift`** — Sync schema and locale files to the Swift package
- **`npm run validate-locales`** — Validate that all schema enum values have locale entries
- **`npm run update-vcpkg`** — Update vcpkg port version and SHA512 hash
- **`npm run install-hooks`** — Manually install git hooks

### Git Hooks

A pre-push hook is automatically installed that:
- Checks if the Swift package is in sync with the schema package
- Auto-syncs if needed
- Blocks the push if synced files are uncommitted

To skip the hook temporarily: `git push --no-verify`

### Updating vcpkg Port

The `update-vcpkg` script automates the tedious process of updating the vcpkg port:

```bash
npm run update-vcpkg
```

This will:
1. Prompt for the new version
2. Update version in `package.json` and vcpkg files
3. Download the GitHub release archive
4. Calculate and update the SHA512 hash in `portfile.cmake`
5. Provide next steps for committing and tagging

### Validating Locales

Ensure all enum values in the schema have corresponding locale entries:

```bash
npm run validate-locales
```

This validates 350+ enum values across platform, genre, category, feature, region, and other enums.

## License

[CC0-1.0](LICENSE)
