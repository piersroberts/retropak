# JSON Schema

The complete JSON Schema for Retropak manifests.

## Schema Definition

```json
--8<-- "schemas/v1/retropak.schema.json"
```

## Using the Schema

You can use this schema to validate your Retropak manifest files with any JSON Schema validator.

### Schema URL

The schema is hosted at: `https://retropak.org/schemas/v1/retropak.schema.json`

### Validation Example

Using a JSON Schema validator, you can validate your manifest:

```bash
jsonschema -i manifest.json schemas/v1/retropak.schema.json
```

Or reference it directly in your manifest file:

```json
{
  "$schema": "https://retropak.org/schemas/v1/retropak.schema.json",
  "schemaVersion": "1-0-0",
  ...
}
```

## Schema Versioning

Retropak uses [Schemaver](https://snowplowanalytics.com/blog/2014/05/13/introducing-schemaver-for-semantic-versioning-of-schemas/) (Schema Versioning) with the format `MODEL-REVISION-ADDITION`:

- `MODEL` - Breaking changes (consumers must update)
- `REVISION` - Stricter validation (producers must update, old files still work)
- `ADDITION` - Backward-compatible additions

The current schema version is **1-0-0**. See the [specification](specification.md#versioning) for details.

## Validation Rules

The schema enforces strict validation to ensure data quality and prevent common errors.

### Required Strings Cannot Be Empty

All required string fields use `minLength: 1` to reject empty strings:

- `info.title` - Titles must have actual text
- All file paths - Must reference actual files, not empty strings
- `creditEntry.name` - Credits must have names

This catches data errors early. If a field is optional, omit it entirely rather than using `""`.

### No Unknown Properties

All objects use `additionalProperties: false` to reject unexpected properties:

- Catches typos: `"titl"` instead of `"title"` will fail validation
- Prevents namespace pollution from custom fields
- Ensures strict specification compliance

If you need custom metadata, use the `notes` field or store separate files in the archive.

See the [specification](specification.md#validation) for detailed rationale.
