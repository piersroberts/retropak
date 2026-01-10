# JSON Schema

The complete JSON Schema for Retropak manifests.

## Schema Definition

```json
--8<-- "./schemas/v1/retropak.schema.json"
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
