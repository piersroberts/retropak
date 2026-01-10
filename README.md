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

## License

This specification is released under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). Use it however you like.
