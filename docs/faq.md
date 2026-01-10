# Frequently Asked Questions

Common questions about Retropak.

---

## General

### What is Retropak?

Retropak is an open container format for distributing retro software with complete metadata, artwork, documentation, and soundtracks in a single file.

### Why create a new format?

Existing solutions are incomplete:

- **Plain ROMs**: No metadata, no artwork, scattered files
- **Frontend databases**: Inconsistent scraping, online dependency
- **Custom formats**: Proprietary, limited adoption

Retropak bundles everything in an open, standardized way.

### What's the file extension?

`.rpk` (Retropak)

### Why do all Retropaks use `.rpk` regardless of platform?

!!! tip "One Format, All Platforms"
    Every Retropak uses `.rpk` regardless of whether it contains NES, PlayStation, or DOS software. This design choice has important benefits.

**File format consistency** — Retropak is a container format, not a platform-specific format. Just like `.zip` works for any files inside, `.rpk` works for any platform. All platform information is stored in the JSON manifest's `platform` field inside the archive, not encoded in the file extension.

**Simplified tooling** — Emulators and frontends only need to recognize one extension (`.rpk`). They open the archive, read `retropak.json`, and determine the platform from the manifest—no filename parsing or extension variants needed.

**Flexible naming** — You can still include platform information in the filename if you want. For example: `Sonic.md.rpk`, `Zelda (NES).rpk`, or `Final Fantasy VII (PSX).rpk`. The filename is up to you—only the `.rpk` extension matters for file associations. Tools ignore the filename and read the platform from the manifest.

The platform-specific software files (ROMs, ISOs, etc.) inside each Retropak still retain their original extensions for emulator compatibility.

### Is it just a ZIP file?

Yes. Retropak files are standard ZIP archives with a manifest. Any tool can extract them.

---

## Technical

### What platforms are supported?

94 platforms from Atari 2600 to Xbox Series X. [See the full list →](specification.md#platforms)

### Can I add new platforms?

Yes! The specification is extensible. Propose additions via GitHub.

### Why is arcade not supported?

!!! info "Arcade Games Are Different"
    Arcade games don't fit the Retropak model because they're fundamentally different from home platforms.

Arcade games are fundamentally different from home platforms:

- **Board-specific**: Games are tied to specific arcade hardware (CPS1, CPS2, Neo Geo MVS, etc.), not a unified platform
- **Complex emulation**: Arcade ROMs require specific emulator configurations and BIOS files per board
- **ROM set fragmentation**: MAME ROM sets are split, merged, or use parent/clone relationships that don't fit the self-contained Retropak model
- **Metadata challenges**: Arcade games span decades and hundreds of board types with vastly different technical requirements

MAME and other arcade emulators already have robust distribution formats. Retropak focuses on home platforms with consistent hardware and media formats.

### How do I validate a Retropak?

Use the JSON schema with any standard JSON Schema validator. A dedicated validation tool does not currently exist but contributions are welcome.

### What's the maximum file size?

ZIP format supports up to 4GB (ZIP64 extends this to 16EB, though practical limits apply).

### Can I stream from a Retropak without extracting?

!!! success "Yes! Direct Access Works"
    ZIP format supports random access, so emulators can read files directly from the `.rpk` archive without extracting everything first. This saves disk space and load time.

---

## Content

### Do I have to include everything?

No. Only `retropak.json`, the `software/` directory, and at least one media file are required. Everything else (artwork, manuals, soundtracks) is optional.

### Can I include save files?

!!! danger "Never Include Save Files"
    Save files are user-specific and should **never** be included in Retropak archives. They can overwrite user progress and contain personal data. Let emulators create and manage saves externally.

### What about cheat codes?

Include them in `docs/` as text files or add to `info.notes`.

### Can I bundle multiple games?

For compilations (like Namco Museum), use:

```json
"type": "compilation",
"contents": ["Pac-Man", "Galaga", "Dig Dug"]
```

For separate games, create separate Retropaks.

### What about DLC or expansion packs?

Create separate Retropaks. Consider noting the relationship:

```json
"notes": "Requires base game: Doom (1993)"
```

---

## Metadata

### Where do I find metadata?

- **IGDB** — [igdb.com](https://www.igdb.com/)
- **MobyGames** — [mobygames.com](https://www.mobygames.com/)
- **No-Intro** — [datomatic.no-intro.org](https://datomatic.no-intro.org/)
- **Redump** — [redump.org](http://redump.org/)

### Do I have to fill in every field?

No. Only `title` and `platform` are required. Add what you know.

### What if metadata conflicts between databases?

Choose the most authoritative source. Note discrepancies in `info.notes`.

### How do I handle regional differences?

- Use `alternativeTitles` for regional names
- Use `languages` array for supported languages
- Set `releaseDate` to original release
- Use `region` in media for ROM region
- Use `country` for development country

---

## Assets

### What image formats are supported?

PNG, JPEG, and WebP. Use PNG for pixel art and transparency, JPEG for photos.

### Do I need to include alt text?

It's optional but strongly recommended for accessibility.

### What resolution should box art be?

- **Recommended:** 1000×1400px
- **Maximum:** 2000×2800px

### Can I use AI-generated artwork?

**Caution:** Always prioritize original scans and authentic artwork. Original materials are essential for proper preservation.

AI tools may be used to restore or enhance damaged original artwork, but should never be used to create entirely new original artwork. If AI restoration is used, disclose it in `notes` or asset credits.

### What about watermarked images?

Remove watermarks if possible. Preservation should be clean.

---

## Legal

### Is Retropak legal?

Yes. The format itself is legal and open (CC0 license). However:

- **ROMs:** May be copyrighted. Consult local laws.
- **Artwork:** May be copyrighted. Fair use varies by jurisdiction.
- **Homebrew:** Always check with the author and verify the license terms.

### Can I distribute Retropaks commercially?

The format is open, but content may be restricted:

- **Homebrew:** Check with the author and verify license terms
- **Copyrighted games:** Requires rights holder permission
- **Artwork/manuals:** May require separate permission

### What's the license for the specification?

CC0 1.0 Universal — public domain. Use it however you want.

### Do I need permission to implement Retropak support?

No. The specification is open. Build tools, emulators, or frontends freely.

---

## Signing & Security

### Why sign Retropaks?

Signing ensures:

- Files haven't been modified
- No malware added after signing
- Authenticity of the creator

### Do I have to sign Retropaks?

No. Signing is optional but recommended for distribution.

### What signature formats are supported?

- **GPG/PGP** — Traditional web of trust
- **SSH** — Simple key-based signing (OpenSSH 8.0+)

### How do users verify signatures?

Extract the signature files and verify using standard GPG or SSH tools. See the specification for detailed verification procedures.

Users must trust your public key.

### Can signatures be faked?

No, if the private key is secure. Verification cryptographically proves authenticity.

### How do I claim authorship of a Retropak?

Sign it. Your cryptographic signature is your identity. The `retropak.sig.info` file contains your public key fingerprint, which serves as your verifiable identity.

There is no author/packager name field in `retropak.json` because:

- **Names can be spoofed** — Anyone could claim to be anyone
- **Cryptographic identity is verifiable** — Key fingerprints cannot be faked without the private key
- **Separation of concerns** — The JSON describes the software, signatures describe the package

If you want to be known, publish your public key with your name on your website, GitHub, or Keybase. Build reputation through your fingerprint.

---

## Compatibility

### Will my emulator support .rpk files?

Not currently. We would like to work with emulator developers to add native `.rpk` support. For now, extract and use files normally.

### Can I convert existing ROM sets?

Conversion tools do not currently exist. Contributions of such tools are welcome.

### How do I convert back to plain ROMs?

Extract the ZIP:

```bash
unzip game.rpk
cd software/
# ROMs are here
```

### Will this work with [my frontend]?

Native support depends on adoption. We would love to see `.rpk` support in frontends such as EmulationStation, Launchbox, and similar software.

---

## Contributing

### How can I help?

- Create tools and libraries
- Build emulator/frontend plugins
- Convert existing ROM sets
- Write documentation
- Share feedback

### Where's the source code?

The specification is the source. It's all you need to implement support.

### Can I propose changes to the spec?

Yes! Open an issue or pull request on GitHub.

### How do I report bugs?

Open an issue with:

- What you expected
- What happened
- Example manifest (if applicable)

---

## Getting Help

### Where can I ask questions?

- [Retropak Discord](https://discord.gg/retropak)
- GitHub Issues

### Can I get help creating Retropaks?

Yes! Share your use case and we'll help.

### Will the spec change?

The core spec (1.0) is stable. Future versions may add optional fields but won't break existing files.

### How is versioning handled?

The `schemaVersion` field indicates compatibility. Tools check this before parsing.

---

Still have questions? [Open an issue on GitHub →](#)
