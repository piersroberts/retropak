# Tools

Tools and libraries for working with Retropak files.

---

## Implementations

### Libraries

Want to build a library? [See the specification](specification.md)

### Emulator Integration

We would like to hear from emulator developers interested in adding native `.rpk` support. Retropak is designed to work with emulators for all supported platforms, making it simple to:

- Load software directly from `.rpk` archives
- Display embedded metadata and artwork
- Handle multi-disc titles seamlessly
- Verify ROM authenticity through checksums

If you develop or maintain an emulator and would like to integrate Retropak support, please get in touch via the [Retropak Discord](https://discord.gg/retropak).

---

## Frontend Integration

We are seeking contributions from frontend developers to add Retropak support. Potential features include:

- Direct `.rpk` loading
- Automatic metadata import
- Asset extraction and caching
- Signature verification
- Multi-disc handling

---

## Creating Tools

### JSON Schema

Validate manifests against the official schema:

```bash
curl https://retropak.org/schemas/v1/retropak.schema.json
```

Use with any JSON Schema validator:

- **Python:** `jsonschema`
- **JavaScript:** `ajv`
- **Go:** `gojsonschema`
- **Java:** `json-schema-validator`

### Reading Retropaks

Retropaks are standard ZIP files. Use any ZIP library:

**Python:**

```python
import zipfile
import json

with zipfile.ZipFile('game.rpk', 'r') as rpk:
    manifest = json.loads(rpk.read('retropak.json'))
    print(manifest['info']['title'])
```

**JavaScript:**

```javascript
const JSZip = require('jszip');
const fs = require('fs');

fs.readFile('game.rpk', (err, data) => {
  JSZip.loadAsync(data).then(zip => {
    zip.file('retropak.json').async('string').then(content => {
      const manifest = JSON.parse(content);
      console.log(manifest.info.title);
    });
  });
});
```

**Rust:**

```rust
use zip::ZipArchive;
use std::fs::File;
use serde_json::Value;

let file = File::open("game.rpk")?;
let mut archive = ZipArchive::new(file)?;
let manifest_file = archive.by_name("retropak.json")?;
let manifest: Value = serde_json::from_reader(manifest_file)?;
println!("{}", manifest["info"]["title"]);
```

### Signature Verification

**GPG:**

```bash
unzip -p game.rpk retropak.checksums > /tmp/checksums
unzip -p game.rpk retropak.sig > /tmp/sig
gpg --verify /tmp/sig /tmp/checksums
```

**SSH:**

```bash
unzip -p game.rpk retropak.checksums > /tmp/checksums
unzip -p game.rpk retropak.sig > /tmp/sig
ssh-keygen -Y verify -f allowed_signers -I signer@example.com \
  -n org.retropak -s /tmp/sig < /tmp/checksums
```

## Contributing

Want to build tools for Retropak?

1. Read the [specification](specification.md)
2. Use the [JSON schema](https://retropak.org/schemas/v1/retropak.schema.json)
3. Check existing examples
4. Join the discussion

The specification is CC0. Anyone can build tools and integrations for Retropak.

---

## Get Involved

Have an idea for a tool? Want to contribute an implementation?

1. Read the [specification](specification.md)
2. Use the [JSON schema](https://retropak.org/schemas/v1/retropak.schema.json) for validation
3. Review the code examples above
4. Join the [Retropak Discord](https://discord.gg/retropak) to discuss ideas
5. Build your implementation

Contributions of libraries, converters, and integrations are welcome.
