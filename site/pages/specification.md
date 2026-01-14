# Retropak Specification

**Version 1.0**

Retropak is an open container format for distributing retro software with rich metadata, artwork, soundtracks, and documentation. A `.rpk` file is a single, self-contained package that preserves everything about a title.

---

## Why Retropak?

Retro software distribution is fragmented. ROMs live in one folder, box art in another, manuals scattered elsewhere. Frontends scrape metadata from various databases, often with inconsistent results. Retropak solves this by bundling everything together in a single, validated package.

### Design Principles

!!! success "Built for Preservation"
    Retropak isn't just for games - it's for preserving **all** retro software with complete context.

1. **Inclusive, not game-centric** - We use "title" and "software" instead of "game" because Retropak supports demos, applications, educational software, scene demos, and more.

2. **Self-describing** - A `.rpk` file contains everything needed to display, launch, and understand the software. No external scraping required.

3. **Preservation-focused** - Checksums, dump verification status, and ROM versioning help ensure authenticity.

4. **Accessibility-first** - All images support alt text for screen readers.

5. **Frontend-friendly** - Structured data with enums makes filtering, sorting, and displaying trivial.

6. **Simple container** - Just a ZIP file. Any tool can extract it.

---

## Versioning

Retropak uses **[Schemaver](https://snowplowanalytics.com/blog/2014/05/13/introducing-schemaver-for-semantic-versioning-of-schemas/)** (Schema Versioning) to track format evolution. Unlike semver, schemaver explicitly distinguishes between changes that break consumers, producers, or neither.

### Format: MODEL-REVISION-ADDITION

Retropak schema versions follow the pattern `MODEL-REVISION-ADDITION` (e.g., `1-0-0`):

- **MODEL** - Breaking changes that prevent consumers from reading old files
  - Example: Changing `title` from string to object
  - Example: Removing or renaming required fields
  - **Impact:** Frontends/emulators must update to support new files

- **REVISION** - Changes that break producers but not consumers
  - Example: Adding new required fields
  - Example: Stricter validation (removing enum values)
  - **Impact:** Tools creating .rpk files must update; old files still work

- **ADDITION** - Backward-compatible additions
  - Example: Adding optional fields
  - Example: Adding new platform/genre enum values
  - **Impact:** No one needs to update immediately

### Current Version

The current schema version is **1-0-0** (initial release). This version must be declared in every `retropak.json` manifest:

```json
{
  "$schema": "https://retropak.org/schemas/v1/retropak.schema.json",
  "schemaVersion": "1-0-0",
  "info": {
    "title": "Example Game",
    ...
  }
}
```

### Schema Organization

- Schema files are organized by MODEL version: `/schemas/v1/`, `/schemas/v2/`
- The URL `https://retropak.org/schemas/v1/retropak.schema.json` always points to the latest `1-x-x` version
- This ensures frontends can validate against `v1` and accept any `1-x-x` manifest

### Why Schemaver?

Schemaver provides critical clarity for data formats:

- **Semver's MINOR** conflates two very different things (new features vs. stricter validation)
- **Schemaver's REVISION** explicitly captures "old files work, but new files have stricter rules"
- Perfect for preservation: consumers can confidently read any `1-x-x` file regardless of REVISION/ADDITION changes

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

??? question "Why these specific names?"
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

| Format  | Header                          | Description                               |
| ------- | ------------------------------- | ----------------------------------------- |
| **GPG** | `-----BEGIN PGP SIGNATURE-----` | Armored detached GPG/PGP signature        |
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

!!! warning "Trust Is Not Automatic"
    Signature verification proves the archive is unmodified, but you must trust the signer's public key through your own verification process. A valid signature doesn't mean the content is safe—only that it hasn't been altered since signing!

---

## File Format Guidelines

### Software Files

Software files should be stored in their original, unmodified format. Do not re-compress ROMs inside the archive—the ZIP container handles compression.

#### Recommended Formats by Platform Type

| Platform Type   | Formats                                                                      | Notes                                               |
| --------------- | ---------------------------------------------------------------------------- | --------------------------------------------------- |
| **Cartridge**   | `.bin`, `.rom`, `.nes`, `.sfc`, `.md`, `.gb`, `.gba`, `.n64`, `.z64`, `.v64` | Use platform-standard extensions                    |
| **Floppy Disk** | `.adf`, `.d64`, `.g64`, `.dsk`, `.ima`, `.img`                               | Preserve original disk images                       |
| **CD-ROM**      | `.bin/.cue`, `.iso`, `.chd`, `.mds/.mdf`                                     | CHD recommended for size; BIN/CUE for compatibility |
| **DVD/Blu-ray** | `.iso`, `.chd`                                                               | CHD strongly recommended                            |
| **Tape**        | `.tap`, `.tzx`, `.t64`, `.cas`                                               | Platform-specific formats                           |
| **Archive**     | `.zip`, `.7z`                                                                | For DOS/PC games with multiple files                |
| **Hard Disk**   | `.hdf`, `.vhd`, `.img`, `.chd`                                               | Full disk images for computers                      |

#### Compression Notes

!!! tip "CHD for Disc Images"
    CHD (Compressed Hunks of Data) is highly recommended for optical media. It provides lossless compression with 40-60% size reduction and is widely supported by modern emulators like RetroArch.

- **Do not** use `.zip` or `.7z` for individual ROMs inside the archive—double compression wastes space and slows loading.
- Keep multi-file disc images together (e.g., `.bin` + `.cue`, `.mds` + `.mdf`).

### Image Files

All artwork should prioritize quality while remaining practical for distribution.

#### Supported Formats

| Format   | Use Case                                      | Notes                                                    |
| -------- | --------------------------------------------- | -------------------------------------------------------- |
| **PNG**  | Screenshots, logos, pixel art, transparencies | Lossless, supports alpha channel                         |
| **JPEG** | Box art, photos, backdrops                    | Lossy but smaller; use quality 85-95                     |
| **WebP** | Any (modern frontends)                        | Best compression, supports both lossy/lossless and alpha |

**Recommendation:** Use PNG for anything requiring transparency or pixel-perfect accuracy. Use JPEG or WebP for photographic content like box scans and backdrops.

#### Size Guidelines

| Asset Type             | Recommended Size  | Max Size  | Notes                                   |
| ---------------------- | ----------------- | --------- | --------------------------------------- |
| `boxFront`             | 1000×1400         | 2000×2800 | ~1.4:1 ratio (varies by region)         |
| `boxBack`              | 1000×1400         | 2000×2800 | Match front dimensions                  |
| `boxSpine`             | 100×1400          | 200×2800  | Narrow strip                            |
| `mediaItem.labelImage` | 1000×1000         | 2000×2000 | Square for discs; rectangular for carts |
| `logo`                 | 800×400           | 1600×800  | Transparent PNG, width > height         |
| `backdrop`             | 1920×1080         | 3840×2160 | 16:9 widescreen                         |
| `titleScreen`          | Native resolution | 1920×1080 | Preserve original aspect ratio          |
| `gameplay`             | Native resolution | 1920×1080 | Preserve original aspect ratio          |
| `map`                  | As needed         | 4000×4000 | Can be large for detailed maps          |

!!! warning "Preserve Aspect Ratios"
    Never stretch screenshots! A 4:3 game should remain 4:3. Distorted screenshots look unprofessional and misrepresent the original game.

**Notes:**

- For pixel art, use nearest-neighbor scaling or keep at native resolution.
- Backdrop images should be clean artwork without text/logos that clash with UI overlays.

### Audio Files

Soundtrack files should balance quality with practical file sizes.

#### Supported Formats

| Format         | Use Case          | Notes                                       |
| -------------- | ----------------- | ------------------------------------------- |
| **MP3**        | General use       | Widely compatible, 192-320 kbps recommended |
| **OGG Vorbis** | General use       | Better quality/size than MP3, open format   |
| **FLAC**       | Archival/lossless | For preservation; larger files              |
| **M4A/AAC**    | General use       | Good quality, Apple ecosystem friendly      |
| **OPUS**       | Modern use        | Best quality/size ratio, gaining support    |

**Recommendation:** OGG Vorbis or MP3 at 192+ kbps offers the best compatibility/quality balance. Use FLAC only when lossless preservation is important.

#### Guidelines

- **Bitrate:** 192 kbps minimum for lossy formats; 256-320 kbps preferred
- **Sample rate:** 44.1 kHz standard; 48 kHz acceptable
- **Channels:** Stereo preferred; mono acceptable for older titles
- **Tagging:** Embed track titles in file metadata when possible

### Documentation Files

| Format       | Use Case                       |
| ------------ | ------------------------------ |
| **PDF**      | Scanned manuals, official docs |
| **HTML**     | Formatted guides, walkthroughs |
| **TXT/MD**   | Plain text readme, notes       |
| **PNG/JPEG** | Scanned pages as images        |

---

## Schema Overview

The manifest has four top-level sections:

| Section         | Required | Purpose                                      |
| --------------- | -------- | -------------------------------------------- |
| `schemaVersion` | Yes      | Schema version using schemaver format        |
| `info`          | Yes      | Title metadata (name, platform, genre, etc.) |
| `media`         | Yes      | The actual software files                    |
| `assets`        | No       | Artwork, music, documentation                |
| `config`        | No       | Emulator configuration files                 |

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
  "title": "Final Fantasy VI", // (1)!
  "alternativeTitles": ["Final Fantasy III", "ファイナルファンタジーVI"] // (2)!
}
```

1. Primary display name - usually the most recent or widely recognized version
2. Regional variants, original titles, or localized names

!!! tip "Flexible Alternative Titles"
    Use an array because titles don't fit rigid regional categories. Some games have multiple names in the same language or region-specific variants that don't map to simple "US/EU/JP" fields.

### Category vs Genre

```json
{
  "category": ["game", "demo"], // (1)!
  "genre": ["platformer", "action"] // (2)!
}
```

1. **What it is**: game, demo, homebrew, educational software, etc.
2. **How it plays**: platformer, RPG, puzzle, strategy, etc.

!!! note "Why Two Fields?"
    Category describes *what the software is*, while genre describes *how it plays*. A shareware demo of an RPG would have `category: ["game", "demo", "shareware"]` and `genre: ["rpg"]`.

Category is an array because software can be multiple things—a "game" that's also a "demo," or "homebrew" that's also a "prototype."

#### Categories

`addon`, `application`, `beta`, `bios`, `compilation`, `coverdisk`, `demo`, `educational`, `enhanced`, `firmware`, `freeware`, `game`, `homebrew`, `multimedia`, `port`, `promotional`, `prototype`, `remake`, `remaster`, `rerelease`, `scene_demo`, `shareware`, `unlicensed`, `utility`

??? info "Rerelease Categories"
    - **`enhanced`** - Enhanced editions with patches, DLC, or improvements (e.g., Director's Cut, GOTY Edition)
    - **`port`** - Game ported to another platform with minimal changes
    - **`remaster`** - Enhanced graphics/audio but same core gameplay (e.g., HD remasters)
    - **`remake`** - Game rebuilt from scratch, may have gameplay changes
    - **`rerelease`** - Re-released on a new platform/medium with minimal changes

    These can be combined: `["game", "remaster"]` or `["compilation", "rerelease"]`

#### Genres

`action`, `action_rpg`, `adventure`, `american_football`, `arcade`, `artillery`, `athletics`, `baseball`, `basketball`, `beat_em_up`, `billiards`, `block_puzzle`, `board_game`, `bowling`, `boxing`, `bullet_hell`, `card_game`, `casino`, `casual`, `cricket`, `cute_em_up`, `dating_sim`, `dungeon_crawler`, `educational`, `endless_runner`, `extreme_sports`, `fighting`, `fishing`, `flight`, `fps`, `golf`, `hack_and_slash`, `hockey`, `horse_racing`, `horror`, `life_sim`, `light_gun`, `logic_puzzle`, `mahjong`, `management`, `match_3`, `maze`, `mech`, `metroidvania`, `minigames`, `mmorpg`, `moba`, `music_rhythm`, `open_world`, `pachinko`, `party`, `pinball`, `platformer`, `point_and_click`, `pool`, `puzzle`, `quiz`, `racing`, `rail_shooter`, `real_time_strategy`, `roguelike`, `rpg`, `run_and_gun`, `sandbox`, `shoot_em_up`, `shooter`, `simulation`, `skateboarding`, `skiing`, `snooker`, `snowboarding`, `soccer`, `sports`, `stealth`, `strategy`, `surfing`, `survival`, `tactical_rpg`, `tennis`, `text_adventure`, `tower_defense`, `trivia`, `turn_based_strategy`, `twin_stick`, `vehicle_combat`, `visual_novel`, `volleyball`, `word_puzzle`, `wrestling`

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

`analog_stick`, `arcade_stick`, `balance_board`, `bongos`, `buzzer`, `camera`, `crank`, `dance_mat`, `dongle`, `drums`, `fishing_rod`, `flight_stick`, `gamepad`, `guitar`, `keyboard`, `keyboard_controller`, `light_gun`, `link_cable`, `maracas`, `mech_controller`, `microphone`, `motion_controls`, `mouse`, `multitap`, `nfc_portal`, `online`, `paddle`, `pedals`, `pointer`, `rumble`, `save_file`, `spinner`, `steering_wheel`, `stylus`, `touch_screen`, `trackball`, `train_controller`, `turntable`, `twin_stick`, `vr_headset`, `zapper`

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
    { "name": "Koji Kondo", "roles": ["Composer"] },
    { "name": "Charles Martinet", "roles": ["Voice Actor"], "characters": ["Mario", "Luigi"] }
  ]
}
```

Roles are freeform strings because job titles vary enormously across eras and regions. Trying to enumerate every possible role would be futile.

The optional `characters` array can be used to specify which characters a person portrayed (useful for voice actors, motion capture performers, etc.).

### Compilations

```json
{
  "category": ["game", "compilation"],
  "contents": [
    "Pac-Man",
    "Galaga",
    "Dig Dug"
  ]
}
```

For compilation discs, include `"compilation"` in the `category` array and populate `contents` with the included titles as simple strings.

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
    "pegi": "7"
  }
}
```

Rating boards have different systems, so we support multiple:

| Field     | Type    | Values                                            |
| --------- | ------- | ------------------------------------------------- |
| `nsfw`    | boolean | Quick filter for adult content                    |
| `minimum` | integer | Generic age (0-21) when no official rating exists |
| `esrb`    | string  | `ec`, `e`, `e10`, `t`, `m`, `ao`, `rp`            |
| `pegi`    | string  | `3`, `7`, `12`, `16`, `18`                        |
| `cero`    | string  | `a`, `b`, `c`, `d`, `z`                           |
| `usk`     | string  | `0`, `6`, `12`, `16`, `18`                        |
| `acb`     | string  | `g`, `pg`, `m`, `ma15`, `r18`, `rc`               |
| `grac`    | string  | `all`, `12`, `15`, `18`                           |
| `bbfc`    | string  | `u`, `pg`, `12`, `12a`, `15`, `18`, `r18`         |

**Why `nsfw` inside rating?** - It's a content classification. Keeping all content filtering in one place makes frontend implementation simpler.

### License

```json
{
  "license": "freeware"
}
```

Indicates the software license type. Particularly useful for distinguishing freeware, shareware, and homebrew with specific open source licenses.

| License Type          | Description                                           |
| --------------------- | ----------------------------------------------------- |
| `commercial`          | Standard commercial software                          |
| `freeware`            | Free to use                                           |
| `shareware`           | Try before you buy                                    |
| `public_domain`       | No copyright restrictions                             |
| `open_source`         | Generic open source                                   |
| `gpl`, `gpl2`, `gpl3` | GNU General Public License variants                   |
| `lgpl`                | GNU Lesser General Public License                     |
| `mit`                 | MIT License                                           |
| `bsd`                 | BSD License                                           |
| `apache`              | Apache License                                        |
| `creative_commons`    | Generic Creative Commons                              |
| `cc_by`               | Creative Commons Attribution                          |
| `cc_by_sa`            | Creative Commons Attribution-ShareAlike               |
| `cc_by_nc`            | Creative Commons Attribution-NonCommercial            |
| `cc_by_nc_sa`         | Creative Commons Attribution-NonCommercial-ShareAlike |
| `cc0`                 | Creative Commons Zero (Public Domain)                 |
| `proprietary`         | Proprietary license                                   |
| `unknown`             | License status unclear                                |

**Note**: `freeware` and `shareware` appear in both `category` and `license` because they describe both the distribution model (category) and legal terms (license).

### Product Identifiers

```json
{
  "ean": "5060004761364",
  "upc": "047875840423",
  "isbn": "978-0-7615-3977-7",
  "issn": "1234-5678"
}
```

Barcode and standard identifiers from physical product packaging:

| Field  | Format      | Description                                                     |
| ------ | ----------- | --------------------------------------------------------------- |
| `ean`  | 13 digits   | European Article Number (EAN-13). Also covers JAN (Japan)       |
| `upc`  | 12 digits   | Universal Product Code (UPC-A) for North American products      |
| `isbn` | ISBN format | International Standard Book Number (for PC games sold as books) |
| `issn` | XXXX-XXXX   | International Standard Serial Number (for magazine coverdisks)  |

These identify the physical release packaging, not the software itself. Useful for cataloging physical collections and matching to retail databases.

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
  "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "crc32": "00000000",
  "version": "Rev A",
  "status": "good",
  "verified": true,
  "source": "No-Intro",
  "productCode": "SNS-MV-0"
}
```

- `md5`, `sha1`, `sha256`, `crc32` - Checksums for verification
- `version` - ROM revision (e.g., "Rev A", "v1.1")
- `status` - Dump quality: `good`, `bad`, `overdump`, `underdump`, `alternate`, `hacked`, `trained`, `translated`, `prototype`, `unlicensed`, `pirate`, `unknown`
- `verified` - Whether validated against a known database
- `source` - Which database verified it (No-Intro, Redump, TOSEC)
- `productCode` - Official product code or catalog number from the original media

### Regions

`asia`, `australia`, `brazil`, `canada`, `china`, `europe`, `france`, `germany`, `hong-kong`, `india`, `italy`, `japan`, `korea`, `mexico`, `netherlands`, `ntsc-j`, `ntsc-u`, `pal`, `pal-a`, `pal-b`, `pal-g`, `russia`, `scandinavia`, `spain`, `taiwan`, `uk`, `usa`, `world`

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

| Field         | Description                             |
| ------------- | --------------------------------------- |
| `boxFront`    | Front cover                             |
| `boxBack`     | Back cover                              |
| `boxSpine`    | Spine                                   |
| `logo`        | Title logo with transparency            |
| `backdrop`    | Widescreen background for TV interfaces |
| `titleScreen` | Title screen screenshot                 |
| `gameplay`    | Array of gameplay screenshots           |
| `manual`      | Path to manual (PDF, images, HTML)      |
| `map`         | World map or game chart                 |
| `music`       | Soundtrack files                        |

### Physical Media Images

Physical media images (cartridges, discs, tapes, etc.) are attached directly to each `mediaItem` object:

```json
{
  "media": [
    {
      "filename": "software/game.bin",
      "type": "cdrom",
      "labelImage": {
        "file": "art/disc.png",
        "alt": "Disc label showing the game logo"
      }
    }
  ]
}
```

This approach ensures each media item is directly linked to its image, avoiding any confusion with multi-disc or multi-cartridge releases.

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

125 platforms are currently supported. Platform IDs follow these rules:

- **Single-word names** stay as-is: `saturn`, `dreamcast`, `wii`
- **Multi-word names** become abbreviations: `pce`, `gba`, `sms`
- **Number-only names** get a manufacturer prefix: `a2600`, `a7800`, `ps2`

| ID              | Platform                                                                                  | Manufacturer       | Year  |
| --------------- | ----------------------------------------------------------------------------------------- | ------------------ | ----- |
| `bbc`           | [BBC Micro](https://en.wikipedia.org/wiki/BBC_Micro)                                      | Acorn              | 1981  |
| `electron`      | [Acorn Electron](https://en.wikipedia.org/wiki/Acorn_Electron)                            | Acorn              | 1983  |
| `archimedes`    | [Acorn Archimedes](https://en.wikipedia.org/wiki/Acorn_Archimedes)                        | Acorn              | 1987  |
| `cpc`           | [Amstrad CPC](https://en.wikipedia.org/wiki/Amstrad_CPC)                                  | Amstrad            | 1984  |
| `gx4000`        | [Amstrad GX4000](https://en.wikipedia.org/wiki/Amstrad_GX4000)                            | Amstrad            | 1990  |
| `apple2`        | [Apple II](https://en.wikipedia.org/wiki/Apple_II)                                        | Apple              | 1977  |
| `pippin`        | [Pippin](https://en.wikipedia.org/wiki/Apple_Bandai_Pippin)                               | Apple/Bandai       | 1995  |
| `mp1000`        | [APF-MP1000](https://en.wikipedia.org/wiki/APF_Imagination_Machine)                       | APF                | 1978  |
| `msx`           | [MSX](https://en.wikipedia.org/wiki/MSX)                                                  | ASCII Corporation  | 1983  |
| `msx2`          | [MSX2](https://en.wikipedia.org/wiki/MSX#MSX2)                                            | ASCII Corporation  | 1985  |
| `arduboy`       | [Arduboy](https://en.wikipedia.org/wiki/Arduboy)                                          | Arduboy            | 2016  |
| `a2600`         | [Atari 2600](https://en.wikipedia.org/wiki/Atari_2600)                                    | Atari              | 1977  |
| `a800`          | [Atari 8-bit](https://en.wikipedia.org/wiki/Atari_8-bit_family)                           | Atari              | 1979  |
| `a5200`         | [Atari 5200](https://en.wikipedia.org/wiki/Atari_5200)                                    | Atari              | 1982  |
| `st`            | [Atari ST](https://en.wikipedia.org/wiki/Atari_ST)                                        | Atari              | 1985  |
| `a7800`         | [Atari 7800](https://en.wikipedia.org/wiki/Atari_7800)                                    | Atari              | 1986  |
| `lynx`          | [Atari Lynx](https://en.wikipedia.org/wiki/Atari_Lynx)                                    | Atari              | 1989  |
| `jaguar`        | [Atari Jaguar](https://en.wikipedia.org/wiki/Atari_Jaguar)                                | Atari              | 1993  |
| `jaguarcd`      | [Jaguar CD](https://en.wikipedia.org/wiki/Atari_Jaguar_CD)                                | Atari              | 1993  |
| `astrocade`     | [Bally Astrocade](https://en.wikipedia.org/wiki/Bally_Astrocade)                          | Bally/Astrocade    | 1977  |
| `ws`            | [WonderSwan](https://en.wikipedia.org/wiki/WonderSwan)                                    | Bandai             | 1999  |
| `wsc`           | [WonderSwan Color](https://en.wikipedia.org/wiki/WonderSwan)                              | Bandai             | 2000  |
| `gamate`        | [Gamate](https://en.wikipedia.org/wiki/Gamate)                                            | Bit Corporation    | 1990  |
| `pv1000`        | [Casio PV-1000](https://en.wikipedia.org/wiki/Casio_PV-1000)                              | Casio              | 1983  |
| `coleco`        | [ColecoVision](https://en.wikipedia.org/wiki/ColecoVision)                                | Coleco             | 1982  |
| `pet`           | [Commodore PET](https://en.wikipedia.org/wiki/Commodore_PET)                              | Commodore          | 1977  |
| `vic20`         | [VIC-20](https://en.wikipedia.org/wiki/VIC-20)                                            | Commodore          | 1980  |
| `c64`           | [Commodore 64](https://en.wikipedia.org/wiki/Commodore_64)                                | Commodore          | 1982  |
| `plus4`         | [Commodore Plus/4](https://en.wikipedia.org/wiki/Commodore_Plus/4)                        | Commodore          | 1984  |
| `c128`          | [Commodore 128](https://en.wikipedia.org/wiki/Commodore_128)                              | Commodore          | 1985  |
| `amiga`         | [Amiga](https://en.wikipedia.org/wiki/Amiga)                                              | Commodore          | 1985  |
| `cdtv`          | [CDTV](https://en.wikipedia.org/wiki/Commodore_CDTV)                                      | Commodore          | 1991  |
| `cd32`          | [Amiga CD32](https://en.wikipedia.org/wiki/Amiga_CD32)                                    | Commodore          | 1993  |
| `dragon`        | [Dragon 32/64](https://en.wikipedia.org/wiki/Dragon_32/64)                                | Dragon Data        | 1982  |
| `emerson`       | [Emerson Arcadia 2001](https://en.wikipedia.org/wiki/Emerson_Arcadia_2001)                | Emerson            | 1982  |
| `enterprise`    | [Enterprise 64/128](https://en.wikipedia.org/wiki/Enterprise_(computer))                  | Enterprise         | 1984  |
| `vcg`           | [Cassette Vision](https://en.wikipedia.org/wiki/Cassette_Vision)                          | Epoch              | 1981  |
| `scv`           | [Super Cassette Vision](https://en.wikipedia.org/wiki/Super_Cassette_Vision)              | Epoch              | 1984  |
| `channelf`      | [Channel F](https://en.wikipedia.org/wiki/Fairchild_Channel_F)                            | Fairchild          | 1976  |
| `fmtowns`       | [FM Towns](https://en.wikipedia.org/wiki/FM_Towns)                                        | Fujitsu            | 1989  |
| `gp32`          | [GP32](https://en.wikipedia.org/wiki/GP32)                                                | GamePark           | 2001  |
| `gp2x`          | [GP2X](https://en.wikipedia.org/wiki/GP2X)                                                | GamePark Holdings  | 2005  |
| `vectrex`       | [Vectrex](https://en.wikipedia.org/wiki/Vectrex)                                          | GCE/Milton Bradley | 1982  |
| `dos`           | [DOS](https://en.wikipedia.org/wiki/DOS)                                                  | IBM/Microsoft      | 1981  |
| `o2`            | [Odyssey²](https://en.wikipedia.org/wiki/Magnavox_Odyssey_2)                              | Magnavox/Philips   | 1978  |
| `intellivision` | [Intellivision](https://en.wikipedia.org/wiki/Intellivision)                              | Mattel             | 1979  |
| `aquarius`      | [Aquarius](https://en.wikipedia.org/wiki/Mattel_Aquarius)                                 | Mattel             | 1983  |
| `hyperscan`     | [HyperScan](https://en.wikipedia.org/wiki/HyperScan)                                      | Mattel             | 2006  |
| `megaduck`      | [Mega Duck](https://en.wikipedia.org/wiki/Mega_Duck)                                      | Welback Holdings   | 1993  |
| `xbox`          | [Xbox](https://en.wikipedia.org/wiki/Xbox_(console))                                      | Microsoft          | 2001  |
| `x360`          | [Xbox 360](https://en.wikipedia.org/wiki/Xbox_360)                                        | Microsoft          | 2005  |
| `xone`          | [Xbox One](https://en.wikipedia.org/wiki/Xbox_One)                                        | Microsoft          | 2013  |
| `xsx`           | [Xbox Series X/S](https://en.wikipedia.org/wiki/Xbox_Series_X_and_Series_S)               | Microsoft          | 2020  |
| `sam`           | [SAM Coupé](https://en.wikipedia.org/wiki/SAM_Coup%C3%A9)                                 | Miles Gordon       | 1989  |
| `microvision`   | [Microvision](https://en.wikipedia.org/wiki/Microvision)                                  | Milton Bradley     | 1979  |
| `pc88`          | [PC-88](https://en.wikipedia.org/wiki/PC-8800_series)                                     | NEC                | 1981  |
| `pc98`          | [PC-98](https://en.wikipedia.org/wiki/PC-9800_series)                                     | NEC                | 1982  |
| `pce`           | [PC Engine / TurboGrafx-16](https://en.wikipedia.org/wiki/TurboGrafx-16)                  | NEC                | 1987  |
| `pcecd`         | [PC Engine CD](https://en.wikipedia.org/wiki/TurboGrafx-16#Add-ons)                       | NEC                | 1988  |
| `sgx`           | [SuperGrafx](https://en.wikipedia.org/wiki/PC_Engine_SuperGrafx)                          | NEC                | 1989  |
| `pcfx`          | [PC-FX](https://en.wikipedia.org/wiki/PC-FX)                                              | NEC                | 1994  |
| `gnw`           | [Game & Watch](https://en.wikipedia.org/wiki/Game_%26_Watch)                              | Nintendo           | 1980  |
| `nes`           | [NES / Famicom](https://en.wikipedia.org/wiki/Nintendo_Entertainment_System)              | Nintendo           | 1983  |
| `fds`           | [Famicom Disk System](https://en.wikipedia.org/wiki/Famicom_Disk_System)                  | Nintendo           | 1986  |
| `gb`            | [Game Boy](https://en.wikipedia.org/wiki/Game_Boy)                                        | Nintendo           | 1989  |
| `snes`          | [SNES / Super Famicom](https://en.wikipedia.org/wiki/Super_Nintendo_Entertainment_System) | Nintendo           | 1990  |
| `vb`            | [Virtual Boy](https://en.wikipedia.org/wiki/Virtual_Boy)                                  | Nintendo           | 1995  |
| `n64`           | [Nintendo 64](https://en.wikipedia.org/wiki/Nintendo_64)                                  | Nintendo           | 1996  |
| `gbc`           | [Game Boy Color](https://en.wikipedia.org/wiki/Game_Boy_Color)                            | Nintendo           | 1998  |
| `gba`           | [Game Boy Advance](https://en.wikipedia.org/wiki/Game_Boy_Advance)                        | Nintendo           | 2001  |
| `gamecube`      | [GameCube](https://en.wikipedia.org/wiki/GameCube)                                        | Nintendo           | 2001  |
| `pokemini`      | [Pokémon mini](https://en.wikipedia.org/wiki/Pok%C3%A9mon_Mini)                           | Nintendo           | 2001  |
| `nds`           | [Nintendo DS](https://en.wikipedia.org/wiki/Nintendo_DS)                                  | Nintendo           | 2004  |
| `wii`           | [Wii](https://en.wikipedia.org/wiki/Wii)                                                  | Nintendo           | 2006  |
| `3ds`           | [Nintendo 3DS](https://en.wikipedia.org/wiki/Nintendo_3DS)                                | Nintendo           | 2011  |
| `wiiu`          | [Wii U](https://en.wikipedia.org/wiki/Wii_U)                                              | Nintendo           | 2012  |
| `switch`        | [Nintendo Switch](https://en.wikipedia.org/wiki/Nintendo_Switch)                          | Nintendo           | 2017  |
| `ngage`         | [N-Gage](https://en.wikipedia.org/wiki/N-Gage_(device))                                   | Nokia              | 2003  |
| `3do`           | [3DO Interactive Multiplayer](https://en.wikipedia.org/wiki/3DO_Interactive_Multiplayer)  | Panasonic/others   | 1993  |
| `playdate`      | [Playdate](https://en.wikipedia.org/wiki/Playdate_(console))                              | Panic              | 2022  |
| `cdi`           | [CD-i](https://en.wikipedia.org/wiki/CD-i)                                                | Philips            | 1991  |
| `videopac`      | [Videopac+ / G7400](https://en.wikipedia.org/wiki/Videopac%2B_G7400)                      | Philips            | 1983  |
| `laseractive`   | [LaserActive](https://en.wikipedia.org/wiki/LaserActive)                                  | Pioneer            | 1993  |
| `studio2`       | [RCA Studio II](https://en.wikipedia.org/wiki/RCA_Studio_II)                              | RCA                | 1977  |
| `sg1000`        | [SG-1000](https://en.wikipedia.org/wiki/SG-1000)                                          | Sega               | 1983  |
| `markiii`       | [Sega Mark III](https://en.wikipedia.org/wiki/Master_System#Mark_III)                     | Sega               | 1985  |
| `sms`           | [Master System](https://en.wikipedia.org/wiki/Master_System)                              | Sega               | 1985  |
| `md`            | [Mega Drive / Genesis](https://en.wikipedia.org/wiki/Sega_Genesis)                        | Sega               | 1988  |
| `gg`            | [Game Gear](https://en.wikipedia.org/wiki/Game_Gear)                                      | Sega               | 1990  |
| `mcd`           | [Mega CD / Sega CD](https://en.wikipedia.org/wiki/Sega_CD)                                | Sega               | 1991  |
| `pico`          | [Sega Pico](https://en.wikipedia.org/wiki/Sega_Pico)                                      | Sega               | 1993  |
| `32x`           | [32X](https://en.wikipedia.org/wiki/32X)                                                  | Sega               | 1994  |
| `saturn`        | [Saturn](https://en.wikipedia.org/wiki/Sega_Saturn)                                       | Sega               | 1994  |
| `dreamcast`     | [Dreamcast](https://en.wikipedia.org/wiki/Dreamcast)                                      | Sega               | 1998  |
| `x68000`        | [X68000](https://en.wikipedia.org/wiki/X68000)                                            | Sharp              | 1987  |
| `zx80`          | [ZX80](https://en.wikipedia.org/wiki/ZX80)                                                | Sinclair           | 1980  |
| `zx81`          | [ZX81](https://en.wikipedia.org/wiki/ZX81)                                                | Sinclair           | 1981  |
| `spectrum`      | [ZX Spectrum](https://en.wikipedia.org/wiki/ZX_Spectrum)                                  | Sinclair           | 1982  |
| `ql`            | [Sinclair QL](https://en.wikipedia.org/wiki/Sinclair_QL)                                  | Sinclair           | 1984  |
| `ng`            | [Neo Geo](https://en.wikipedia.org/wiki/Neo_Geo_(system))                                 | SNK                | 1990  |
| `ngcd`          | [Neo Geo CD](https://en.wikipedia.org/wiki/Neo_Geo_CD)                                    | SNK                | 1994  |
| `ngp`           | [Neo Geo Pocket](https://en.wikipedia.org/wiki/Neo_Geo_Pocket)                            | SNK                | 1998  |
| `ngpc`          | [Neo Geo Pocket Color](https://en.wikipedia.org/wiki/Neo_Geo_Pocket_Color)                | SNK                | 1999  |
| `psx`           | [PlayStation](https://en.wikipedia.org/wiki/PlayStation_(console))                        | Sony               | 1994  |
| `ps2`           | [PlayStation 2](https://en.wikipedia.org/wiki/PlayStation_2)                              | Sony               | 2000  |
| `psp`           | [PlayStation Portable](https://en.wikipedia.org/wiki/PlayStation_Portable)                | Sony               | 2004  |
| `ps3`           | [PlayStation 3](https://en.wikipedia.org/wiki/PlayStation_3)                              | Sony               | 2006  |
| `vita`          | [PlayStation Vita](https://en.wikipedia.org/wiki/PlayStation_Vita)                        | Sony               | 2011  |
| `ps4`           | [PlayStation 4](https://en.wikipedia.org/wiki/PlayStation_4)                              | Sony               | 2013  |
| `ps5`           | [PlayStation 5](https://en.wikipedia.org/wiki/PlayStation_5)                              | Sony               | 2020  |
| `xavix`         | [XaviXPORT](https://en.wikipedia.org/wiki/XaviX)                                          | SSD Company        | 2004  |
| `trs80`         | [TRS-80](https://en.wikipedia.org/wiki/TRS-80)                                            | Tandy              | 1977  |
| `coco`          | [TRS-80 Color Computer](https://en.wikipedia.org/wiki/TRS-80_Color_Computer)              | Tandy              | 1980  |
| `oric`          | [Oric](https://en.wikipedia.org/wiki/Oric_(computer))                                     | Tangerine          | 1983  |
| `thomson`       | [Thomson MO5/TO7](https://en.wikipedia.org/wiki/Thomson_computers)                        | Thomson            | 1984  |
| `gizmondo`      | [Gizmondo](https://en.wikipedia.org/wiki/Gizmondo)                                        | Tiger Telematics   | 2005  |
| `einstein`      | [Tatung Einstein](https://en.wikipedia.org/wiki/Tatung_Einstein)                          | Tatung             | 1984  |
| `ti994a`        | [TI-99/4A](https://en.wikipedia.org/wiki/Texas_Instruments_TI-99/4A)                      | Texas Instruments  | 1981  |
| `tutor`         | [Tomy Tutor](https://en.wikipedia.org/wiki/Tomy_Tutor)                                    | Tomy               | 1983  |
| `tigerhandheld` | [Tiger Handhelds](https://en.wikipedia.org/wiki/Tiger_Electronics#Handheld_games)         | Tiger Electronics  | 1990s |
| `gamecom`       | [Game.com](https://en.wikipedia.org/wiki/Game.com)                                        | Tiger Electronics  | 1997  |
| `nuon`          | [NUON](https://en.wikipedia.org/wiki/Nuon_(DVD_technology))                               | VM Labs            | 2000  |
| `supervision`   | [Watara SuperVision](https://en.wikipedia.org/wiki/Watara_SuperVision)                    | Watara             | 1992  |
| `gamewave`      | [Game Wave](https://en.wikipedia.org/wiki/Game_Wave_Family_Entertainment_System)          | ZAPiT Games        | 2005  |
| `zeebo`         | [Zeebo](https://en.wikipedia.org/wiki/Zeebo)                                              | Zeebo Inc.         | 2009  |

---

## Complete Example

```json
{
  "schemaVersion": "1-0-0",
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
      "pegi": "3"
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

- **schemaVersion** - Format `MODEL-REVISION-ADDITION` using schemaver (e.g., `1-0-0`, `1-2-1`)
- **manifestVersion** - Flexible versioning supporting integers or dot-separated numbers (e.g., `1`, `2.1`, `3.2.1`)

These patterns ensure data consistency and make validation reliable across different tools and implementations.

### String Validation

All required string fields enforce non-empty values using `minLength: 1`. This prevents common data quality issues:

```json
{
  "info": {
    "title": "",  // ❌ Invalid - empty strings not allowed
    "title": "Sonic the Hedgehog"  // ✅ Valid
  }
}
```

**Affected fields:**

- `info.title` - Must have a visible title
- File paths in all objects (`configFile.file`, `image.file`, `musicTrack.file`, `mediaItem.filename`, `mediaItem.labelImage.file`) - Must reference an actual file
- `creditEntry.name` - Credits must have actual names

**Rationale:** Empty strings are almost always data errors. They break frontends, make archives harder to organize, and provide no value. If a field is optional, omit it entirely rather than using an empty string.

### Strict Property Validation

All object definitions use `additionalProperties: false` to reject unexpected or unknown properties:

```json
{
  "info": {
    "title": "Sonic",
    "platform": "md",
    "customField": "value"  // ❌ Invalid - unknown property
  }
}
```

**Rationale:**

1. **Catch typos early** - `"titl": "Sonic"` will fail validation instead of being silently ignored
2. **Prevent namespace pollution** - Custom fields would fragment the ecosystem and break portability
3. **Forward compatibility** - When new fields are added in future schema versions, old validators won't accidentally accept them
4. **Clear specification** - The schema explicitly defines what's allowed; there's no ambiguity

**What if I need custom data?** Use the `notes` field to store additional information as structured text. For tool-specific metadata, store it in a separate file in the archive (e.g., `config/mytool.json`).

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
