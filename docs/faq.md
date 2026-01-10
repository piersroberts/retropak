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

### Is it just a ZIP file?

Yes. Retropak files are standard ZIP archives with a manifest. Any tool can extract them.

---

## Technical

### What platforms are supported?

77 platforms from Atari 2600 to Xbox Series X. [See the full list →](specification.md#platforms)

### Can I add new platforms?

Yes! The specification is extensible. Propose additions via GitHub.

### How do I validate a Retropak?

Use the JSON schema or validation tools:

```bash
rpk-verify game.rpk
```

### What's the maximum file size?

ZIP format supports up to 4GB (ZIP64 extends this to 16EB, though practical limits apply).

### Can I stream from a Retropak without extracting?

Yes! ZIP allows random access. Emulators can read files directly from the archive.

---

## Content

### Do I have to include everything?

No. Only `retropak.json`, the `software/` directory, and at least one media file are required. Everything else (artwork, manuals, soundtracks) is optional.

### Can I include save files?

Yes, but consider:

- Save files are user-specific
- Put them in `docs/` or create a `saves/` directory
- Document them in `info.notes`

Better: Let emulators create saves externally.

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

Yes, but disclose it in `notes` or asset credits. Original scans are preferred for preservation.

### What about watermarked images?

Remove watermarks if possible. Preservation should be clean.

---

## Legal

### Is Retropak legal?

Yes. The format itself is legal and open (CC0 license). However:

- **ROMs:** May be copyrighted. Consult local laws.
- **Artwork:** May be copyrighted. Fair use varies by jurisdiction.
- **Homebrew:** Usually freely distributable, but check license.

### Can I distribute Retropaks commercially?

The format is open, but content may be restricted:

- **Homebrew with permissive licenses:** Usually yes
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

```bash
rpk-verify -S -K allowed_signers game.rpk
```

Users must trust your public key.

### Can signatures be faked?

No, if the private key is secure. Verification cryptographically proves authenticity.

---

## Compatibility

### Will my emulator support .rpk files?

Not yet, but we're working with emulator developers. For now, extract and use normally.

### Can I convert existing ROM sets?

Yes. Tools are planned for:

- No-Intro DAT → Retropak
- Redump DAT → Retropak
- EmulationStation gamelist.xml → Retropak

### How do I convert back to plain ROMs?

Extract the ZIP:

```bash
unzip game.rpk
cd software/
# ROMs are here
```

### Will this work with [my frontend]?

Native support depends on adoption. Plugins are planned for:

- EmulationStation
- Launchbox
- Kodi

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

- GitHub Issues
- Community forums (coming soon)
- Discord server (coming soon)

### Is there a mailing list?

Not yet. Check back soon.

### Can I get help creating Retropaks?

Yes! Share your use case and we'll help.

---

## Future Plans

### What's on the roadmap?

- Official Python/JavaScript libraries
- Web-based validator
- Emulator integration
- Frontend plugins
- Conversion tools

### Will the spec change?

The core spec (1.0) is stable. Future versions may add optional fields but won't break existing files.

### How is versioning handled?

The `specVersion` field indicates compatibility. Tools check this before parsing.

---

Still have questions? [Open an issue on GitHub →](#)
