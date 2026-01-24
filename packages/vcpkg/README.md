# vcpkg Support for Retropak

This document explains how to use and publish the Retropak package via vcpkg.

## Installation

### For Users

Once the Retropak port is added to the vcpkg registry, users can install it with:

```bash
vcpkg install retropak
```

Or add it to your `vcpkg.json`:

```json
{
  "dependencies": [
    "retropak"
  ]
}
```

### Using in CMake Projects

After installing via vcpkg, you can use Retropak in your CMakeLists.txt:

```cmake
find_package(retropak CONFIG REQUIRED)

# Access the schema and locale directories
message(STATUS "Retropak schemas: ${RETROPAK_SCHEMA_DIR}")
message(STATUS "Retropak locales: ${RETROPAK_LOCALE_DIR}")

# Example: Copy schema file to your build directory
configure_file(
    "${RETROPAK_SCHEMA_DIR}/v1/retropak.schema.json"
    "${CMAKE_BINARY_DIR}/schemas/retropak.schema.json"
    COPYONLY
)
```

## Testing Locally

To test the vcpkg port locally before submitting:

1. Clone vcpkg if you haven't already:
   ```bash
   git clone https://github.com/microsoft/vcpkg.git
   cd vcpkg
   ./bootstrap-vcpkg.sh  # or bootstrap-vcpkg.bat on Windows
   ```

2. Create an overlay port:
   ```bash
   mkdir -p overlays/retropak
   cp -r /path/to/retropak/ports/retropak/* overlays/retropak/
   ```

3. Install using the overlay:
   ```bash
   ./vcpkg install retropak --overlay-ports=overlays/retropak
   ```

## Publishing to vcpkg Registry

To submit Retropak to the official vcpkg registry:

1. Fork the [vcpkg repository](https://github.com/microsoft/vcpkg)

2. Copy the port files:
   ```bash
   cp -r ports/retropak /path/to/vcpkg/ports/
   ```

3. Update the SHA512 hash in `portfile.cmake`:
   - Create a GitHub release with a version tag (e.g., `v1.0.0`)
   - Download the source archive
   - Calculate the SHA512:
     ```bash
     sha512sum retropak-1.0.0.tar.gz
     ```
   - Update the `SHA512` value in `ports/retropak/portfile.cmake`

4. Test the port:
   ```bash
   cd /path/to/vcpkg
   ./vcpkg install retropak
   ./vcpkg x-add-version retropak
   ```

5. Commit and create a pull request:
   ```bash
   git checkout -b add-retropak
   git add ports/retropak versions/
   git commit -m "Add retropak port"
   git push origin add-retropak
   ```

6. Open a PR to [microsoft/vcpkg](https://github.com/microsoft/vcpkg)

## Files Overview

- **vcpkg.json** - Main manifest file at the project root
- **CMakeLists.txt** - CMake build configuration for installing schema files
- **cmake/retropak-config.cmake.in** - CMake package configuration template
- **ports/retropak/** - Reference port files for vcpkg registry submission
  - `portfile.cmake` - Build instructions for vcpkg
  - `vcpkg.json` - Port manifest
  - `usage` - Usage instructions shown after installation

## Package Contents

When installed via vcpkg, the package provides:

- **Schemas**: JSON schema files in `share/retropak/schemas/`
- **Locales**: Localization files in `share/retropak/locales/`
- **CMake Config**: Find package support with `RETROPAK_SCHEMA_DIR` and `RETROPAK_LOCALE_DIR` variables

## Requirements

- CMake 3.14 or later
- vcpkg package manager

## License

The vcpkg port follows the same CC0-1.0 license as the Retropak project.
