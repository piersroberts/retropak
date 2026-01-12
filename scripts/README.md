# Scripts

This directory contains utility scripts for the Retropak project.

## validate-locales.sh

Validates that locale files cover all schema enums and outputs JSON describing any issues.

### Requirements

- `jq` - Command-line JSON processor
  - macOS: `brew install jq`
  - Ubuntu/Debian: `sudo apt-get install jq`

### Usage

```bash
./scripts/validate-locales.sh
```

### Output

JSON format:
```json
{
  "locales": {
    "en": {
      "missing": [
        {"key": "platform", "values": ["n64", "ps2"]},
        {"key": "genre", "values": "all"}
      ],
      "extra": ["type", "custom"]
    }
  }
}
```

- `missing`: Enum keys or values absent from locale but present in schema
  - `values: "all"` = entire enum section missing
  - `values: [...]` = specific enum values missing
- `extra`: Keys in locale not defined in schema

### Exit Codes

- `0` - All validations passed
- `1` - Validation errors found

### CI/CD Integration

Runs automatically in GitHub Actions on changes to `locales/`, `schemas/`, or the script.

## build.sh

Builds the MkDocs documentation site.
