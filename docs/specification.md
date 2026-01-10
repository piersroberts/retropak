# Retropak Specification

**Version 1.0**

Retropak is an open container format for distributing retro software with rich metadata, artwork, soundtracks, and documentation. A `.rpk` file is a single, self-contained package that preserves everything about a title.

---

## Why Retropak?

Retro software distribution is fragmented. ROMs live in one folder, box art in another, manuals scattered elsewhere. Frontends scrape metadata from various databases, often with inconsistent results. Retropak solves this by bundling everything together in a single, validated package.

### Design Principles

1. **Inclusive, not game-centric** - We use "title" and "software" instead of "game" because Retropak supports demos, applications, educational software, scene demos, and more.

2. **Self-describing** - A `.rpk` file contains everything needed to display, launch, and understand the software. No external scraping required.

3. **Preservation-focused** - Checksums, dump verification status, and ROM versioning help ensure authenticity.

4. **Accessibility-first** - All images support alt text for screen readers.

5. **Frontend-friendly** - Structured data with enums makes filtering, sorting, and displaying trivial.

6. **Simple container** - Just a ZIP file. Any tool can extract it.

---

## Container Format

A `.rpk` file is a standard ZIP archive using Deflate compression. The extension must be `.rpk`.

### Directory Structure

```
/
├── retropak.json       (Required)
├── software/           (Required: ROMs, ISOs, tapes, etc.)
├── art/                (Optional: Visual assets)
├── audio/              (Optional: Soundtrack)
├── docs/               (Optional: Manuals, maps)
└── config/             (Optional: Emulator configs)
```

**Why `retropak.json`?** - We avoided the generic `manifest.json` (used by PWAs, Chrome extensions, etc.) to make files immediately identifiable and prevent format collisions.

**Why `software/`?** - The folder contains ROMs, disc images, and executables—not just "games." Using `software/` reflects our inclusive terminology.

---

## Signing and Verification

Retropak supports cryptographic signing to ensure archive integrity and authenticity. A signed `.rpk` guarantees that no files have been modified, deleted, or added since the creator signed it.

### How It Works

1. **Checksums** - SHA-256 hashes are computed for every file in the archive
2. **Signing** - The checksums manifest is cryptographically signed
3. **Storage** - Three files are added to the archive:
   - `retropak.checksums` - SHA-256 hash of every file
   - `retropak.sig` - Cryptographic signature
   - `retropak.sig.info` - Signature metadata (type, fingerprint, timestamp, public key)

### Signature Files

#### `retropak.checksums`

Plain text file listing SHA-256 checksums of all files in the archive (excluding signature files themselves):

```
# Retropak Archive Checksums
# Generated: 2026-01-07T12:00:00Z
# Format: SHA256 <hash> <filename>

SHA256 a1b2c3d4e5f6... retropak.json
SHA256 f6e5d4c3b2a1... software/game.bin
SHA256 1234567890ab... art/box_front.jpg
```

#### `retropak.sig`

Detached cryptographic signature over `retropak.checksums`. Supported formats:

| Format | Header | Description |
|--------|--------|-------------|
| **GPG** | `-----BEGIN PGP SIGNATURE-----` | Armored detached GPG/PGP signature |
| **SSH** | `-----BEGIN SSH SIGNATURE-----` | OpenSSH signature (namespace: `retropak`) |

#### `retropak.sig.info`

Human-readable metadata about the signature:

```
Type: SSH
Fingerprint: SHA256:abc123...
Signed: 2026-01-07T12:00:00Z
Scope: All files in archive (checksummed)
PublicKey: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... user@example.com
```

### Verification Process

A compliant verifier must:

1. **Verify the signature** - Confirm `retropak.sig` is a valid signature over `retropak.checksums`
2. **Check for modifications** - Verify each file's SHA-256 hash matches the checksums
3. **Check for deletions** - Ensure all files listed in checksums exist in the archive
4. **Check for additions** - Ensure no files exist in the archive that aren't in the checksums (excluding `retropak.sig`, `retropak.sig.info`, `retropak.checksums`)

### Trust Model

Signing establishes:

1. **Authenticity** - The signer approved this exact content
2. **Integrity** - Nothing has been tampered with
3. **Non-repudiation** - The signer cannot deny signing (with their key)

**Important:** Signature verification proves the archive is unmodified, but you must trust the signer's public key through your own verification process.

---

## File Format Guidelines

### Software Files

Software files should be stored in their original, unmodified format. Do not re-compress ROMs inside the archive—the ZIP container handles compression.

#### Recommended Formats by Platform Type

| Platform Type | Formats | Notes |
|---------------|---------|-------|
| **Cartridge** | `.bin`, `.rom`, `.nes`, `.sfc`, `.md`, `.gb`, `.gba`, `.n64`, `.z64`, `.v64` | Use platform-standard extensions |
| **Floppy Disk** | `.adf`, `.d64`, `.g64`, `.dsk`, `.ima`, `.img` | Preserve original disk images |
| **CD-ROM** | `.bin/.cue`, `.iso`, `.chd`, `.mds/.mdf` | CHD recommended for size; BIN/CUE for compatibility |
| **DVD/Blu-ray** | `.iso`, `.chd` | CHD strongly recommended |
| **Tape** | `.tap`, `.tzx`, `.t64`, `.cas` | Platform-specific formats |
| **Archive** | `.zip`, `.7z` | For DOS/PC games with multiple files |
| **Hard Disk** | `.hdf`, `.vhd`, `.img`, `.chd` | Full disk images for computers |

#### Compression Notes

- **CHD (Compressed Hunks of Data)** - Highly recommended for optical media. Lossless, significant size reduction, widely supported by emulators.
- **Do not** use `.zip` or `.7z` for individual ROMs inside the archive—double compression wastes space and slows loading.
- Keep multi-file disc images together (e.g., `.bin` + `.cue`, `.mds` + `.mdf`).

### Image Files

All artwork should prioritize quality while remaining practical for distribution.

#### Supported Formats

| Format | Use Case | Notes |
|--------|----------|-------|
| **PNG** | Screenshots, logos, pixel art, transparencies | Lossless, supports alpha channel |
| **JPEG** | Box art, photos, backdrops | Lossy but smaller; use quality 85-95 |
| **WebP** | Any (modern frontends) | Best compression, supports both lossy/lossless and alpha |

**Recommendation:** Use PNG for anything requiring transparency or pixel-perfect accuracy. Use JPEG or WebP for photographic content like box scans and backdrops.

#### Size Guidelines

| Asset Type | Recommended Size | Max Size | Notes |
|------------|------------------|----------|-------|
| `boxFront` | 1000×1400 | 2000×2800 | ~1.4:1 ratio (varies by region) |
| `boxBack` | 1000×1400 | 2000×2800 | Match front dimensions |
| `boxSpine` | 100×1400 | 200×2800 | Narrow strip |
| `physicalMedia` | 1000×1000 | 2000×2000 | Square for discs; rectangular for carts |
| `logo` | 800×400 | 1600×800 | Transparent PNG, width > height |
| `backdrop` | 1920×1080 | 3840×2160 | 16:9 widescreen |
| `titleScreen` | Native resolution | 1920×1080 | Preserve original aspect ratio |
| `gameplay` | Native resolution | 1920×1080 | Preserve original aspect ratio |
| `map` | As needed | 4000×4000 | Can be large for detailed maps |

**Notes:**

- Screenshots should preserve the original aspect ratio—don't stretch 4:3 to 16:9.
- For pixel art, use nearest-neighbor scaling or keep at native resolution.
- Backdrop images should be clean artwork without text/logos that clash with UI overlays.

### Audio Files

Soundtrack files should balance quality with practical file sizes.

#### Supported Formats

| Format | Use Case | Notes |
|--------|----------|-------|
| **MP3** | General use | Widely compatible, 192-320 kbps recommended |
| **OGG Vorbis** | General use | Better quality/size than MP3, open format |
| **FLAC** | Archival/lossless | For preservation; larger files |
| **M4A/AAC** | General use | Good quality, Apple ecosystem friendly |
| **OPUS** | Modern use | Best quality/size ratio, gaining support |

**Recommendation:** OGG Vorbis or MP3 at 192+ kbps offers the best compatibility/quality balance. Use FLAC only when lossless preservation is important.

#### Guidelines

- **Bitrate:** 192 kbps minimum for lossy formats; 256-320 kbps preferred
- **Sample rate:** 44.1 kHz standard; 48 kHz acceptable
- **Channels:** Stereo preferred; mono acceptable for older titles
- **Tagging:** Embed track titles in file metadata when possible

### Documentation Files

| Format | Use Case |
|--------|----------|
| **PDF** | Scanned manuals, official docs |
| **HTML** | Formatted guides, walkthroughs |
| **TXT/MD** | Plain text readme, notes |
| **PNG/JPEG** | Scanned pages as images |

---

## Schema Overview

The manifest has four top-level sections:

| Section | Required | Purpose |
|---------|----------|---------|
| `specVersion` | Yes | Schema version for compatibility |
| `info` | Yes | Title metadata (name, platform, genre, etc.) |
| `media` | Yes | The actual software files |
| `assets` | No | Artwork, music, documentation |
| `config` | No | Emulator configuration files |

---

## The `info` Object

This is where all the metadata lives.

### Required Fields

```json
{
  "info": {
    "title": "Sonic the Hedgehog",
    "platform": "md"
  }
}
```

Only `title` and `platform` are required. Everything else is optional but recommended.

### Titles and Naming

```json
{
  "title": "Final Fantasy VI",
  "alternativeTitles": ["Final Fantasy III", "ファイナルファンタジーVI"]
}
```

- `title` - The primary display name
- `alternativeTitles` - Regional variants, translated names, or original titles

**Why not separate fields for each region?** - Too rigid. A title might have 3 Japanese names and 2 English ones. An array handles any scenario.

### Category vs Genre

```json
{
  "category": ["game", "demo"],
  "genre": ["platformer", "action"]
}
```

These serve different purposes:

- **Category** describes *what the software is*: a game, demo, application, homebrew, prototype, etc.
- **Genre** describes *how it plays*: platformer, RPG, puzzle, etc.

Category is an array because software can be multiple things—a "game" that's also a "demo," or "homebrew" that's also a "prototype."

#### Categories

`game`, `demo`, `shareware`, `application`, `educational`, `multimedia`, `bios`, `homebrew`, `prototype`, `beta`, `coverdisk`, `scene_demo`, `firmware`, `utility`

#### Genres

`action`, `action_rpg`, `adventure`, `arcade`, `beat_em_up`, `board_game`, `card_game`, `casino`, `dating_sim`, `dungeon_crawler`, `educational`, `endless_runner`, `fighting`, `flight`, `fps`, `hack_and_slash`, `horror`, `life_sim`, `light_gun`, `maze`, `metroidvania`, `music_rhythm`, `open_world`, `party`, `pinball`, `platformer`, `point_and_click`, `puzzle`, `racing`, `roguelike`, `rpg`, `run_and_gun`, `sandbox`, `shoot_em_up`, `shooter`, `simulation`, `sports`, `stealth`, `strategy`, `survival`, `tactical_rpg`, `text_adventure`, `tower_defense`, `trivia`, `twin_stick`, `visual_novel`, `wrestling`

### Players

```json
{
  "players": {
    "min": 1,
    "max": 4,
    "coop": true
  }
}
```

- `min` - Minimum players required (defaults to 1)
- `max` - Maximum simultaneous players
- `coop` - Whether cooperative play is supported

**Why not just a number?** - "2 players" doesn't tell you if it's competitive, cooperative, or requires two people. This structure captures the nuance.

### Features

```json
{
  "features": {
    "required": ["light_gun"],
    "supported": ["rumble", "analog_stick"]
  }
}
```

Features include input devices, peripherals, and capabilities. We separate required from supported because:

- A light gun game *requires* a light gun
- A racing game *supports* a steering wheel but works fine with a gamepad

#### Feature Values

`analog_stick`, `dance_mat`, `drums`, `flight_stick`, `gamepad`, `guitar`, `keyboard`, `light_gun`, `link_cable`, `maracas`, `microphone`, `mouse`, `multitap`, `online`, `paddle`, `pointer`, `rumble`, `save_file`, `spinner`, `steering_wheel`, `stylus`, `touch_screen`, `trackball`, `twin_stick`, `vr_headset`, `zapper`

**Why is `online` a feature?** - It's a capability, like rumble support. Putting it here keeps player counts simple (local players only) while still indicating network play was available.

### Country of Origin

```json
{
  "country": "jp"
}
```

ISO 3166-1 alpha-2 country code indicating where the title was originally developed. This is different from `region` (which describes the release region of this specific copy).

Common codes: `jp` (Japan), `us` (United States), `gb` (United Kingdom), `fr` (France), `de` (Germany), `ca` (Canada), `au` (Australia), `kr` (South Korea), `cn` (China), `se` (Sweden), `fi` (Finland), `nl` (Netherlands), `es` (Spain), `it` (Italy), `ru` (Russia), `pl` (Poland), `cz` (Czech Republic), `ua` (Ukraine).

### Languages

```json
{
  "languages": ["en", "ja", "de", "fr"]
}
```

ISO 639-1 codes. Freeform because language support varies wildly—some titles have partial translations, fan translations, or multiple language variants.

### Credits

```json
{
  "credits": [
    { "name": "Shigeru Miyamoto", "roles": ["Producer", "Director"] },
    { "name": "Koji Kondo", "roles": ["Composer"] }
  ]
}
```

Roles are freeform strings because job titles vary enormously across eras and regions. Trying to enumerate every possible role would be futile.

### Compilations

```json
{
  "type": "compilation",
  "contents": [
    "Pac-Man",
    "Galaga",
    "Dig Dug"
  ]
}
```

For compilation discs, `type` switches to `"compilation"` and `contents` lists the included titles as simple strings.

**Why just strings?** - Originally we had full metadata for each included title, but it was overkill. If you need detailed info about Pac-Man, look up a Pac-Man retropak.

### External IDs

```json
{
  "externalIds": {
    "igdb": 1234,
    "mobygames": 5678,
    "screenscraper": 91011
  }
}
```

Cross-reference IDs for major databases. Useful for frontends that want to fetch additional data or link out to more information.

Supported databases: `igdb`, `mobygames`, `thegamesdb`, `screenscraper`, `rawg`, `gamefaqs`

### Age Ratings

```json
{
  "rating": {
    "nsfw": false,
    "esrb": "e",
    "pegi": 7
  }
}
```

Rating boards have different systems, so we support multiple:

| Field | Type | Values |
|-------|------|--------|
| `nsfw` | boolean | Quick filter for adult content |
| `minimum` | integer | Generic age (0-21) when no official rating exists |
| `esrb` | string | `ec`, `e`, `e10`, `t`, `m`, `ao`, `rp` |
| `pegi` | integer | `3`, `7`, `12`, `16`, `18` |
| `cero` | string | `a`, `b`, `c`, `d`, `z` |
| `usk` | integer | `0`, `6`, `12`, `16`, `18` |
| `acb` | string | `g`, `pg`, `m`, `ma15`, `r18`, `rc` |
| `grac` | string | `all`, `12`, `15`, `18` |
| `bbfc` | string | `u`, `pg`, `12`, `12a`, `15`, `18`, `r18` |

**Why `nsfw` inside rating?** - It's a content classification. Keeping all content filtering in one place makes frontend implementation simpler.

---

## The `media` Array

This is where the actual software files are defined.

```json
{
  "media": [
    {
      "filename": "software/game.bin",
      "type": "cartridge",
      "md5": "d41d8cd98f00b204e9800998ecf8427e"
    }
  ]
}
```

### Required Fields

- `filename` - Relative path within the archive
- `type` - The media format

### Media Types

`archive`, `bluray`, `cartridge`, `cdrom`, `download`, `dvd`, `floppy`, `gd_rom`, `hdd_image`, `laserdisc`, `memory_card`, `tape`, `umd`

### Multi-Disc Handling

Retropak handles multi-disc titles with two fields:

- `bootable` - Can the software be started from this disc?
- `index` - Sequence number for disc swapping

#### Scenario A: Both Discs Playable (Gran Turismo 2)

Each disc contains independent content:

```json
{
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
}
```

#### Scenario B: Sequential Discs (Final Fantasy VII)

Start from Disc 1, swap when prompted:

```json
{
  "media": [
    { "filename": "software/ff7_d1.bin", "label": "Disc 1", "type": "cdrom", "index": 1, "bootable": true },
    { "filename": "software/ff7_d2.bin", "label": "Disc 2", "type": "cdrom", "index": 2, "bootable": false },
    { "filename": "software/ff7_d3.bin", "label": "Disc 3", "type": "cdrom", "index": 3, "bootable": false }
  ]
}
```

#### Scenario C: Boot Disk + Data Disk (Amiga)

```json
{
  "media": [
    { "filename": "software/boot.adf", "label": "Boot Disk", "type": "floppy", "bootable": true },
    { "filename": "software/data.adf", "label": "Data Disk", "type": "floppy", "bootable": false }
  ]
}
```

### ROM Verification

```json
{
  "filename": "software/game.bin",
  "type": "cartridge",
  "md5": "d41d8cd98f00b204e9800998ecf8427e",
  "sha1": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
  "crc32": "00000000",
  "version": "Rev A",
  "status": "good",
  "verified": true,
  "source": "No-Intro",
  "serial": "SNS-MV-0"
}
```

- `md5`, `sha1`, `crc32` - Checksums for verification
- `version` - ROM revision (e.g., "Rev A", "v1.1")
- `status` - Dump quality: `good`, `bad`, `overdump`, `underdump`, `alternate`, `hacked`, `trained`, `translated`, `prototype`, `unlicensed`, `pirate`, `unknown`
- `verified` - Whether validated against a known database
- `source` - Which database verified it (No-Intro, Redump, TOSEC)
- `serial` - Official product serial from the original media

### Regions

`asia`, `brazil`, `china`, `korea`, `ntsc-j`, `ntsc-u`, `pal`, `pal-a`, `pal-b`, `world`

---

## The `assets` Object

All supplementary files: artwork, music, documentation.

### Images with Accessibility

All image fields use an object format with optional alt text:

```json
{
  "boxFront": {
    "file": "art/box_front.jpg",
    "alt": "Box art showing Sonic running through Green Hill Zone"
  }
}
```

**Why not just paths?** - Accessibility. Screen reader users deserve to know what's in the artwork.

### Available Asset Types

| Field | Description |
|-------|-------------|
| `boxFront` | Front cover |
| `boxBack` | Back cover |
| `boxSpine` | Spine |
| `physicalMedia` | Images of cartridges, discs, tapes |
| `logo` | Title logo with transparency |
| `backdrop` | Widescreen background for TV interfaces |
| `titleScreen` | Title screen screenshot |
| `gameplay` | Array of gameplay screenshots |
| `manual` | Path to manual (PDF, images, HTML) |
| `map` | World map or game chart |
| `music` | Soundtrack files |

### Physical Media Images

```json
{
  "physicalMedia": [
    {
      "file": "art/disc1.png",
      "alt": "Disc 1 label showing the game logo",
      "mediaId": "disc1",
      "type": "cdrom"
    }
  ]
}
```

The `mediaId` links the image to a specific entry in the `media` array.

### Backdrop

```json
{
  "backdrop": {
    "file": "art/backdrop.jpg",
    "alt": "Promotional artwork of the game's main characters"
  }
}
```

**Why "backdrop"?** - It's specifically for widescreen TV interfaces (like Kodi or EmulationStation). Should be clean artwork without text or logos that would clash with UI overlays.

### Music

```json
{
  "music": [
    {
      "title": "Main Theme",
      "file": "audio/main_theme.mp3",
      "background": true
    },
    {
      "title": "Boss Battle",
      "file": "audio/boss.mp3",
      "background": false
    }
  ]
}
```

The `background` flag indicates which tracks are suitable for menu music when browsing your library.

---

## The `config` Array

Optional emulator configuration files.

```json
{
  "config": [
    {
      "file": "config/retroarch.cfg",
      "target": "retroarch",
      "description": "Sets correct aspect ratio and shader"
    }
  ]
}
```

Use cases:

- Override video settings for a specific title
- Configure memory expansion requirements
- Set up controller mappings for unusual input schemes

---

## Platforms

92 platforms are currently supported. Platform IDs follow these rules:

- **Single-word names** stay as-is: `saturn`, `dreamcast`, `wii`
- **Multi-word names** become abbreviations: `pce`, `gba`, `sms`
- **Number-only names** get a manufacturer prefix: `a2600`, `a7800`, `ps2`

| ID | Platform | Manufacturer | Year |
|----|----------|--------------|------|
| `bbc` | BBC Micro | Acorn | 1981 |
| `cpc` | Amstrad CPC | Amstrad | 1984 |
| `apple2` | Apple II | Apple | 1977 |
| `a2600` | Atari 2600 | Atari | 1977 |
| `a800` | Atari 800 | Atari | 1979 |
| `a5200` | Atari 5200 | Atari | 1982 |
| `st` | Atari ST | Atari | 1985 |
| `a7800` | Atari 7800 | Atari | 1986 |
| `lynx` | Lynx | Atari | 1989 |
| `jaguar` | Jaguar | Atari | 1993 |
| `jaguarcd` | Jaguar CD | Atari | 1993 |
| `ws` | WonderSwan | Bandai | 1999 |
| `wsc` | WonderSwan Color | Bandai | 2000 |
| `coleco` | ColecoVision | Coleco | 1982 |
| `vic20` | VIC-20 | Commodore | 1980 |
| `c64` | Commodore 64 | Commodore | 1982 |
| `plus4` | Plus/4 | Commodore | 1984 |
| `c128` | Commodore 128 | Commodore | 1985 |
| `amiga` | Amiga | Commodore | 1985 |
| `cdtv` | CDTV | Commodore | 1991 |
| `cd32` | Amiga CD32 | Commodore | 1993 |
| `fmtowns` | FM Towns | Fujitsu | 1989 |
| `vectrex` | Vectrex | GCE/Milton Bradley | 1982 |
| `dos` | DOS | IBM/Microsoft | 1981 |
| `o2` | Odyssey² / Videopac | Magnavox/Philips | 1978 |
| `intellivision` | Intellivision | Mattel | 1979 |
| `xbox` | Xbox | Microsoft | 2001 |
| `x360` | Xbox 360 | Microsoft | 2005 |
| `xone` | Xbox One | Microsoft | 2013 |
| `xsx` | Xbox Series X/S | Microsoft | 2020 |
| `pce` | PC Engine / TurboGrafx-16 | NEC | 1987 |
| `pcecd` | PC Engine CD / TurboGrafx-CD | NEC | 1988 |
| `sgx` | SuperGrafx | NEC | 1989 |
| `pcfx` | PC-FX | NEC | 1994 |
| `gnw` | Game & Watch | Nintendo | 1980 |
| `nes` | NES / Famicom | Nintendo | 1983 |
| `fds` | Famicom Disk System | Nintendo | 1986 |
| `gb` | Game Boy | Nintendo | 1989 |
| `snes` | SNES / Super Famicom | Nintendo | 1990 |
| `vb` | Virtual Boy | Nintendo | 1995 |
| `n64` | Nintendo 64 | Nintendo | 1996 |
| `gbc` | Game Boy Color | Nintendo | 1998 |
| `gba` | Game Boy Advance | Nintendo | 2001 |
| `gamecube` | GameCube | Nintendo | 2001 |
| `pokemini` | Pokémon mini | Nintendo | 2001 |
| `nds` | Nintendo DS | Nintendo | 2004 |
| `wii` | Wii | Nintendo | 2006 |
| `3ds` | Nintendo 3DS | Nintendo | 2011 |
| `wiiu` | Wii U | Nintendo | 2012 |
| `switch` | Nintendo Switch | Nintendo | 2017 |
| `3do` | 3DO Interactive Multiplayer | Panasonic/others | 1993 |
| `cdi` | CD-i | Philips | 1991 |
| `sg1000` | SG-1000 | Sega | 1983 |
| `sms` | Master System | Sega | 1985 |
| `md` | Mega Drive / Genesis | Sega | 1988 |
| `gg` | Game Gear | Sega | 1990 |
| `mcd` | Mega CD / Sega CD | Sega | 1991 |
| `pico` | Pico | Sega | 1993 |
| `32x` | 32X | Sega | 1994 |
| `saturn` | Saturn | Sega | 1994 |
| `dreamcast` | Dreamcast | Sega | 1998 |
| `x68000` | X68000 | Sharp | 1987 |
| `spectrum` | ZX Spectrum | Sinclair | 1982 |
| `ng` | Neo Geo AES/MVS | SNK | 1990 |
| `ngcd` | Neo Geo CD | SNK | 1994 |
| `ngp` | Neo Geo Pocket | SNK | 1998 |
| `ngpc` | Neo Geo Pocket Color | SNK | 1999 |
| `psx` | PlayStation | Sony | 1994 |
| `ps2` | PlayStation 2 | Sony | 2000 |
| `psp` | PlayStation Portable | Sony | 2004 |
| `ps3` | PlayStation 3 | Sony | 2006 |
| `vita` | PlayStation Vita | Sony | 2011 |
| `ps4` | PlayStation 4 | Sony | 2013 |
| `ps5` | PlayStation 5 | Sony | 2020 |
| `ti994a` | TI-99/4A | Texas Instruments | 1981 |
| `trs80` | TRS-80 | Tandy | 1977 |
| `pet` | PET | Commodore | 1977 |
| `aquarius` | Aquarius | Mattel | 1983 |
| `einstein` | Einstein | Tatung | 1984 |
| `oric` | Oric-1 / Atmos | Tangerine | 1983 |
| `sam` | SAM Coupé | Miles Gordon | 1989 |
| `supervision` | SuperVision | Watara | 1992 |
| `vcg` | Cassette Vision / Super Cassette Vision | Epoch | 1981 |
| `gamewave` | Game Wave | ZAPiT Games | 2005 |
| `zeebo` | Zeebo | Zeebo Inc. | 2009 |
| `xavix` | XaviXPORT | SSD Company | 2004 |
| `hyperscan` | HyperScan | Mattel | 2006 |
| `tigerhandheld` | Tiger Electronics Handhelds | Tiger Electronics | 1990s |
| `microvision` | Microvision | Milton Bradley | 1979 |
| `laseractive` | LaserActive | Pioneer | 1993 |
| `nuon` | NUON | VM Labs | 2000 |
| `pippin` | Pippin | Apple/Bandai | 1995 |
| `gamecom` | Game.com | Tiger Electronics | 1997 |
| `ngage` | N-Gage | Nokia | 2003 |
| `msx` | MSX | Various | 1983 |
| `msx2` | MSX2 | Various | 1985 |

---

## Complete Example

```json
{
  "specVersion": "1.0",
  "manifestVersion": "1",
  "info": {
    "title": "Sonic the Hedgehog",
    "alternativeTitles": ["ソニック・ザ・ヘッジホッグ"],
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
    },
    "features": {
      "required": ["gamepad"]
    },
    "languages": ["en", "ja"],
    "credits": [
      { "name": "Yuji Naka", "roles": ["Lead Programmer"] },
      { "name": "Naoto Ohshima", "roles": ["Character Designer"] },
      { "name": "Masato Nakamura", "roles": ["Composer"] }
    ],
    "externalIds": {
      "igdb": 1234
    },
    "rating": {
      "esrb": "e",
      "pegi": 3
    }
  },
  "media": [
    {
      "filename": "software/sonic.bin",
      "type": "cartridge",
      "region": "ntsc-u",
      "md5": "...",
      "sha1": "...",
      "status": "good",
      "verified": true,
      "source": "No-Intro"
    }
  ],
  "assets": {
    "boxFront": {
      "file": "art/box_front.jpg",
      "alt": "Sonic pointing forward with the game logo above"
    },
    "logo": {
      "file": "art/logo.png",
      "alt": "Sonic the Hedgehog logo"
    },
    "backdrop": {
      "file": "art/backdrop.jpg",
      "alt": "Green Hill Zone landscape"
    },
    "titleScreen": {
      "file": "art/title.png",
      "alt": "Title screen with Sonic and logo"
    },
    "gameplay": [
      { "file": "art/screen1.png", "alt": "Sonic running through Green Hill Zone" },
      { "file": "art/screen2.png", "alt": "Sonic collecting rings" }
    ],
    "physicalMedia": [
      {
        "file": "art/cartridge.png",
        "alt": "Black Mega Drive cartridge with Sonic artwork",
        "type": "cartridge"
      }
    ],
    "manual": "docs/manual.pdf",
    "music": [
      { "title": "Green Hill Zone", "file": "audio/green_hill.mp3", "background": true }
    ]
  }
}
```

---

## Validation

Validate manifests against the JSON Schema:

```
schemas/retropak.schema.json
```

The schema uses `$defs` for all enums and complex types, making it easy to extend and maintain.

### Format Validation

The schema enforces strict format validation for several field types:

#### ISO Standards

- **Dates** - `releaseDate` uses ISO 8601 format (`YYYY-MM-DD`) with both the `format: "date"` hint and a regex pattern (`^\d{4}-\d{2}-\d{2}$`)
- **Country codes** - `country` must be a valid ISO 3166-1 alpha-2 code (2 lowercase letters, e.g., `jp`, `us`, `gb`)
- **Language codes** - `languages` array items must be ISO 639-1 codes (2 lowercase letters, e.g., `en`, `ja`, `de`)

#### Checksums

All checksum fields use regex patterns to ensure valid hexadecimal strings:

- **MD5** - 32 hexadecimal characters (`^[a-fA-F0-9]{32}$`)
- **SHA-1** - 40 hexadecimal characters (`^[a-fA-F0-9]{40}$`)
- **CRC32** - 8 hexadecimal characters (`^[a-fA-F0-9]{8}$`)

Example:

```json
{
  "md5": "d41d8cd98f00b204e9800998ecf8427e",
  "sha1": "da39a3ee5e6b4b0d3255bfef95601890afd80709",
  "crc32": "00000000"
}
```

#### Version Numbers

- **specVersion** - Format `MAJOR.MINOR` (e.g., `1.0`, `2.1`)
- **manifestVersion** - Flexible versioning supporting integers or dot-separated numbers (e.g., `1`, `2.1`, `3.2.1`)

These patterns ensure data consistency and make validation reliable across different tools and implementations.

---

## Technical Details

### MIME Type

`application/vnd.retropak+zip`

The `vnd.` prefix indicates a vendor-specific type not registered with IANA. The `+zip` suffix declares the underlying format per RFC 6839.

### Uniform Type Identifier (macOS)

`org.retropak.rpk`

Conforms to `com.pkware.zip-archive`. Uses reverse-DNS format based on the retropak.org domain.

### Character Encoding

All text files must be UTF-8 encoded:

- `retropak.json`
- `retropak.checksums`
- `retropak.sig.info`

### Path Conventions

- Paths use forward slashes (`/`) regardless of operating system
- Paths are case-sensitive
- No leading slashes (all paths relative to archive root)
- Allowed characters: alphanumeric, hyphen (`-`), underscore (`_`), period (`.`), forward slash (`/`)
- Avoid spaces in paths (use underscores)

### Compression

- Use Deflate compression (standard ZIP)
- Compression level 6-9 recommended for distribution
- Do not nest compressed files (no `.zip` or `.7z` inside `.rpk`)
- Store-only (no compression) is acceptable for pre-compressed formats like JPEG, MP3, CHD

### SSH Signing Namespace

`org.retropak`

SSH signatures use a namespace to prevent signature reuse across applications. All Retropak SSH signatures must use this namespace.

---

## File Extension

`.rpk` - Retropak

---

## License

This specification is released under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). Use it however you like.
