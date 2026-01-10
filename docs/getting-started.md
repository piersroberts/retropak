# Getting Started

Learn how to create and use Retropak files.

---

## Creating Your First Retropak

### Step 1: Prepare Your Files

Gather everything for your title:

- ROM or disc image
- Box art and screenshots
- Manual (PDF or images)
- Soundtrack (optional)
- Any emulator configs (optional)

### Step 2: Organize the Structure

Create a directory with this structure:

```
my_game/
├── retropak.json
├── software/
│   └── game.rom
├── art/
│   ├── box_front.jpg
│   ├── box_back.jpg
│   └── screenshot1.png
├── audio/
│   └── soundtrack.mp3
└── docs/
    └── manual.pdf
```

### Step 3: Create the Manifest

The `retropak.json` file describes everything. Start with the minimum:

```json
{
  "specVersion": "1.0",
  "info": {
    "title": "Sonic the Hedgehog",
    "platform": "md"
  },
  "media": [{
    "filename": "software/game.rom",
    "type": "cartridge"
  }]
}
```

Only `title` and `platform` are required, but additional metadata provides more value:

```json
{
  "specVersion": "1.0",
  "info": {
    "title": "Sonic the Hedgehog",
    "platform": "md",
    "developer": "Sonic Team",
    "publisher": "Sega",
    "releaseDate": "1991-06-23",
    "description": "Sega's flagship platformer introducing the blue blur.",
    "category": ["game"],
    "genre": ["platformer", "action"],
    "players": {
      "min": 1,
      "max": 1
    }
  },
  "media": [{
    "filename": "software/game.rom",
    "type": "cartridge",
    "region": "ntsc-u",
    "md5": "d41d8cd98f00b204e9800998ecf8427e"
  }],
  "assets": {
    "boxFront": {
      "file": "art/box_front.jpg",
      "alt": "Sonic pointing forward with the game logo above"
    },
    "manual": "docs/manual.pdf"
  }
}
```

### Step 4: Package It

Zip the directory:

```bash
cd my_game
zip -r ../sonic.rpk .
```

Or on Windows:

- Right-click the folder
- Send to → Compressed (zipped) folder
- Rename from `.zip` to `.rpk`

### Step 5: Verify (Optional)

Validate your package:

```bash
rpk-verify sonic.rpk
```

---

## Adding Assets

### Box Art

Add box art with accessibility in mind:

```json
"assets": {
  "boxFront": {
    "file": "art/box_front.jpg",
    "alt": "Front cover showing Sonic running through Green Hill Zone"
  },
  "boxBack": {
    "file": "art/box_back.jpg",
    "alt": "Back cover with screenshots and game description"
  }
}
```

### Screenshots

Add multiple gameplay screenshots:

```json
"gameplay": [
  {
    "file": "art/gameplay1.png",
    "alt": "Sonic collecting rings in Green Hill Zone"
  },
  {
    "file": "art/gameplay2.png",
    "alt": "Sonic fighting Dr. Robotnik boss"
  }
]
```

### Soundtrack

Add music tracks:

```json
"music": [
  {
    "title": "Green Hill Zone",
    "file": "audio/green_hill.mp3",
    "background": true
  },
  {
    "title": "Boss Battle",
    "file": "audio/boss.mp3",
    "background": false
  }
]
```

The `background` flag indicates which tracks work well for menu music.

---

## Multi-Disc Games

### Sequential Discs (Final Fantasy VII)

```json
"media": [
  {
    "filename": "software/ff7_disc1.bin",
    "label": "Disc 1",
    "type": "cdrom",
    "index": 1,
    "bootable": true
  },
  {
    "filename": "software/ff7_disc2.bin",
    "label": "Disc 2",
    "type": "cdrom",
    "index": 2,
    "bootable": false
  },
  {
    "filename": "software/ff7_disc3.bin",
    "label": "Disc 3",
    "type": "cdrom",
    "index": 3,
    "bootable": false
  }
]
```

### Independent Discs (Gran Turismo 2)

```json
"media": [
  {
    "id": "arcade",
    "filename": "software/gt2_arcade.bin",
    "label": "Arcade Mode Disc",
    "type": "cdrom",
    "bootable": true
  },
  {
    "id": "simulation",
    "filename": "software/gt2_sim.bin",
    "label": "Simulation Mode Disc",
    "type": "cdrom",
    "bootable": true
  }
]
```

---

## ROM Verification

Add checksums for verification:

```json
"media": [{
  "filename": "software/game.rom",
  "type": "cartridge",
  "md5": "d41d8cd98f00b204e9800998ecf8427e",
  "sha1": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
  "status": "good",
  "verified": true,
  "source": "No-Intro"
}]
```

Checksums must be valid hexadecimal strings:

- **MD5**: 32 characters (e.g., `d41d8cd98f00b204e9800998ecf8427e`)
- **SHA-1**: 40 characters (e.g., `da39a3ee5e6b4b0d3255bfef95601890afd80709`)
- **CRC32**: 8 characters (e.g., `00000000`)

Generate checksums:

```bash
md5sum game.rom
sha1sum game.rom
crc32 game.rom
```

---

## Date and Code Formats

The schema enforces standardized formats for consistency:

### Dates

Release dates must use ISO 8601 format (`YYYY-MM-DD`):

```json
{
  "releaseDate": "1991-06-23"
}
```

### Country Codes

Use ISO 3166-1 alpha-2 codes (2 lowercase letters):

```json
{
  "country": "jp"
}
```

Common examples: `us`, `jp`, `gb`, `de`, `fr`, `ca`, `au`

### Language Codes

Use ISO 639-1 codes (2 lowercase letters):

```json
{
  "languages": ["en", "ja", "de"]
}
```

Common examples: `en` (English), `ja` (Japanese), `de` (German), `fr` (French), `es` (Spanish), `it` (Italian), `pt` (Portuguese), `ko` (Korean), `zh` (Chinese)

---

## Signing Your Retropak

Cryptographic signing ensures your package hasn't been tampered with:

```bash
# Sign with GPG
rpk-sign mygame.rpk

# Sign with SSH key
rpk-sign -t ssh -k ~/.ssh/id_ed25519 mygame.rpk
```

This creates a signed checksum of all files. Any modification will be detected during verification.

[Learn more about signing →](specification.md#signing-and-verification)

---

## Best Practices

### File Naming

- Use underscores instead of spaces
- Use lowercase for directories
- Be descriptive: `box_front.jpg` not `img1.jpg`

### Image Quality

- Box art: 1000×1400px minimum
- Screenshots: Native resolution preferred
- Use PNG for logos and pixel art
- Use JPEG for photos and scans

### Audio

- MP3 or OGG Vorbis at 192+ kbps
- Embed track metadata in files
- Use consistent volume levels

### Compression

- Use Deflate (standard ZIP)
- Don't nest compressed files
- Pre-compressed formats (CHD, JPEG, MP3) can use store-only

---

## Next Steps

- [View complete examples](examples.md)
- [Read the full specification](specification.md)
- [Browse the JSON schema](https://retropak.org/schemas/v1/retropak.schema.json)
- [Check the FAQ](faq.md)
