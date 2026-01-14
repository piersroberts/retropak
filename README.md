# Retropak

> A modern container format for retro software preservation

Retropak (`.rpk`) is an open standard for distributing retro software with everything in one place: ROMs, artwork, soundtracks, manuals, and metadata.

## Quick Links

- **[Read the Specification](docs/specification.md)**: Complete technical specification
- **[Visit the Website](https://retropak.org)**: Documentation and guides
- **[View the Schema](docs/schemas/v1/retropak.schema.json)**: JSON Schema for validation
- **[Contributing](CONTRIBUTING.md)**: How to build and contribute to the docs

## What is Retropak?

A `.rpk` file is a ZIP archive containing:

- **Software**: ROMs, disc images, executables
- **Metadata**: Title, platform, genre, developer, release date
- **Artwork**: Box art, screenshots, logos
- **Documentation**: Manuals, maps, guides
- **Audio**: Soundtracks and music
- **Configuration**: Emulator settings

Everything needed to preserve and present retro software in one self-contained package.

## Features

- **92 supported platforms**: From Atari 2600 to Xbox Series X
- **Rich metadata**: Genre, players, features, ratings, credits
- **Multi-disc support**: CD swapping, boot disks, compilations
- **ROM verification**: MD5/SHA1/CRC32 checksums for database/DAT file validation
- **Cryptographic signing**: GPG and SSH signatures for authenticity
- **Accessibility**: Alt text support for all images
- **Preservation-focused**: Version tracking, dump status, source attribution

## Packages

### npm Packages

#### @retropak/schema

Install the schema and locales in your JavaScript/TypeScript project:

```bash
npm install @retropak/schema
```

**Usage:**

```javascript
// Import the JSON schema
import schema from '@retropak/schema/schema';

// Import English localization
import locales from '@retropak/schema/locales/en';

// Validate against the schema using your preferred validator
// (e.g., ajv, joi, zod)
```

The package includes:
- `@retropak/schema/schema` - JSON Schema for validation
- `@retropak/schema/locales/en` - English translations and labels

#### @retropak/types

Get full TypeScript type safety with auto-generated types from the JSON Schema:

```bash
npm install @retropak/types
```

**Usage:**

```typescript
import type { RetropakManifest, Platform, Category, Genre } from '@retropak/types';

// Create a type-safe manifest
const manifest: RetropakManifest = {
  schemaVersion: "1-0-0",
  schema: "https://retropak.org/schemas/v1/retropak.schema.json",
  id: "my.awesome.game",
  version: "1.0.0",
  
  info: {
    name: "My Awesome Game",
    developer: "Awesome Studios",
    publisher: "Great Publishers",
    releaseDate: "2024-01-01"
  },
  
  platform: "nes",
  category: "game",
  genre: ["platformer", "action"],
  
  media: [{
    file: "game.nes",
    type: "cartridge"
  }],
  
  language: ["en"],
  region: ["USA"]
};

// TypeScript catches errors at compile time!
// manifest.platform = "invalid"; // ❌ Type error!
```

The package includes:
- Full TypeScript type definitions for all manifest properties
- Auto-generated from the JSON Schema
- IntelliSense support for all platforms, genres, features, and more
- Compile-time validation

### Swift Package

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/retropak/retropak.git", from: "1.0.0")
]
```

**Usage:**

```swift
import RetropakSchema

// Access the schema as a Bundle resource
if let schemaURL = Bundle.module.url(forResource: "retropak.schema", withExtension: "json", subdirectory: "schemas/v1"),
   let schemaData = try? Data(contentsOf: schemaURL) {
    // Use the schema for validation
}

// Access localization
if let localeURL = Bundle.module.url(forResource: "en", withExtension: "json", subdirectory: "locales"),
   let localeData = try? Data(contentsOf: localeURL) {
    // Use locale data
}
```

The package includes schema and locale resources for use in iOS, macOS, tvOS, and watchOS apps.

## License

This specification is released under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). Use it however you like.
