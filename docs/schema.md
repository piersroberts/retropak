# JSON Schema

The complete JSON Schema for Retropak manifests.

## Schema Definition

```json
--8<-- "schemas/retropak.schema.json"
```

## Using the Schema

You can use this schema to validate your Retropak manifest files with any JSON Schema validator.

### Schema URL

The schema is hosted at: `https://retropak.org/schemas/v1/retropak.schema.json`

### Validation Example

Using a JSON Schema validator, you can validate your manifest:

```bash
jsonschema -i manifest.json schemas/retropak.schema.json
```

Or reference it directly in your manifest file:

```json
{
  "$schema": "https://retropak.org/schemas/v1/retropak.schema.json",
  "version": "1.0.0",
  ...
}
```
