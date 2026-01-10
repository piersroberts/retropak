# Retropak

**The modern container format for retro software preservation**

Retropak (`.rpk`) is an open standard for distributing retro software with everything in one place: ROMs, artwork, soundtracks, manuals, and metadata. A `.rpk` file is a single, self-contained package that preserves everything about a title.

---

## Why Retropak?

### Everything in One File

Box art, manuals, soundtracks, and save states all travel together with the software. No more scattered folders across different directories.

### Self-Describing

Rich metadata includes developer info, genre, player counts, peripheral requirements, and credits. No external scraping or database lookups required.

### Tamper-Proof

Optional cryptographic signing ensures files have not been modified, deleted, or added since the creator approved them.

### Accessible

Built-in alt text support for all images ensures screen reader compatibility.

### Frontend-Friendly

Structured JSON with enums makes filtering, sorting, and displaying straightforward. The schema is predictable and consistent.

### Simple

Retropak files are standard ZIP archives with a manifest. Any tool can extract them. No proprietary formats or special software required.

---

## Quick Start

### Creating a Retropak

```bash
# Create directory structure
mkdir mygame.rpk
cd mygame.rpk
mkdir software art audio docs

# Add your files
cp game.bin software/
cp boxart.jpg art/box_front.jpg
cp manual.pdf docs/

# Create manifest
cat > retropak.json << 'EOF'
{
  "specVersion": "1.0",
  "info": {
    "title": "My Game",
    "platform": "nes"
  },
  "media": [{
    "filename": "software/game.bin",
    "type": "cartridge"
  }]
}
EOF

# Package it
cd ..
zip -r mygame.rpk mygame.rpk/
```

### Using a Retropak

Extract with any ZIP tool:

```bash
unzip mygame.rpk
```

Or mount directly in supported emulators and frontends (coming soon).

---

## Features

- **77 supported platforms**: From Atari 2600 to Xbox Series X
- **Comprehensive metadata**: Genre, players, features, ratings, credits
- **Multi-disc support**: Handles CD swapping, boot disks, compilations
- **ROM verification**: MD5/SHA1/CRC32 checksums with database validation
- **Cryptographic signing**: GPG and SSH signatures for authenticity
- **Accessibility**: Alt text for all images
- **Preservation**: Version tracking, dump status, source attribution

---

## Platform Support

Retropak supports 92 platforms including:

**Cartridge-based:** NES, SNES, Genesis, Game Boy, N64, PSX, Saturn, Dreamcast

**Disc-based:** PlayStation, Saturn, Dreamcast, GameCube, Wii, PS2, Xbox

**Computer:** DOS, Amiga, C64, Apple II, ZX Spectrum, MSX

**Handheld:** Game Boy, GBA, DS, PSP, Vita, Switch

[See full platform list →](specification.md#platforms)

---

## Get Involved

Retropak is an open standard released under CC0 1.0. Anyone can implement it, use it, or extend it.

- [Read the full specification](specification.md)
- [View the schema](https://retropak.org/schemas/v1/retropak.schema.json)
- [Browse examples](examples.md)
- [Check the FAQ](faq.md)

---

## License

The Retropak specification is released under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/). Use it however you like.
