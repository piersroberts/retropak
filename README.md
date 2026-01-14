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

```bash
npm install @retropak/types
```

## Documentation

Visit [retropak.org](https://retropak.org) for the full specification, examples, and tools.

## Packages

- [`@retropak/schema`](packages/schema) — JSON Schema definition
- [`@retropak/types`](packages/types) — TypeScript types
- [`RetropakSchema`](packages/swift) — Swift package

## License

[CC0-1.0](LICENSE)
