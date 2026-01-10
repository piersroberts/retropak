# Contributing to Retropak

Thank you for your interest in contributing to the Retropak specification!

## Building the Documentation Site

### Prerequisites

```bash
pip install -r requirements.txt
```

### Build

```bash
mkdocs build
```

The site will be built to the `site/` directory with:

- Documentation pages
- JSON Schema at `/schemas/v1/retropak.schema.json`
- Cloudflare Pages `_headers` file for correct MIME types

### Local Development

```bash
mkdocs serve
```

Then open <http://127.0.0.1:8000> in your browser.

### Deploy to Cloudflare Pages

```bash
wrangler pages deploy site
```

## Project Structure

```
retropak/
├── docs/              # Documentation source files
│   ├── index.md
│   ├── getting-started.md
│   ├── examples.md
│   ├── faq.md
│   ├── tools.md
│   ├── _headers       # Cloudflare Pages headers config
│   └── schemas/       # JSON Schema definitions
│       └── v1/
│           └── retropak.schema.json
├── site/              # Built documentation (generated)
├── mkdocs.yml         # MkDocs configuration
├── wrangler.jsonc     # Cloudflare Pages configuration
└── RETROPAK_SPEC.md   # Full specification document
```

## Schema Validation

The JSON Schema enforces:

- **ISO Standards:** ISO 8601 dates, ISO 3166-1 country codes, ISO 639-1 language codes
- **Checksums:** Proper hexadecimal format for MD5, SHA-1, and CRC32
- **Version Numbers:** Semantic versioning for spec and manifest versions

## MIME Type Configuration

The schema is served with the correct MIME type via Cloudflare Pages `_headers`:

```
/schemas/v1/*.json
  Content-Type: application/schema+json
  Access-Control-Allow-Origin: *
  Cache-Control: public, max-age=3600
```

This ensures:

- JSON Schema tools can properly identify the schema
- CORS is enabled for cross-origin validation
- Browsers cache the schema for 1 hour

## Making Changes

1. Edit the relevant files in `docs/` for documentation updates
2. For schema changes, edit `docs/schemas/v1/retropak.schema.json`
3. Test locally with `mkdocs serve`
4. Submit a pull request with your changes

## License

This specification is released under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). Use it however you like.
