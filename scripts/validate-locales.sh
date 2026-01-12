#!/bin/bash
set -euo pipefail

S="$(dirname "$0")/../schemas/v1/retropak.schema.json"
L="$(dirname "$0")/../locales"

for f in "$L"/*.json; do
  jq -s --arg n "$(basename "$f" .json)" '
    .[0]."$defs" as $defs |
    ($defs | to_entries | (map(select(.value.enum) | {name: .key, enum: .value.enum}) + map(.value.properties? // {} | to_entries[] | select(.value.enum) | {name: .key, enum: .value.enum})) | unique_by(.name)) as $allEnums |
    ($allEnums | map(.name)) as $valid |
    .[1] as $locale |
    {
      ($n): {
        missing: ($allEnums | map(. as $e | if ($locale | has($e.name)) then {key: $e.name, values: ($e.enum - ($locale[$e.name] | keys))} | select(.values != []) else {key: $e.name, values: "all"} end)),
        extra: (($locale | keys) - $valid)
      }
    }
  ' "$S" "$f"
done | jq -s '{locales: add}' | tee /tmp/locale-validation.json

jq -e '.locales | to_entries | all(.value.missing == [] and .value.extra == [])' /tmp/locale-validation.json >/dev/null
E=$?
rm -f /tmp/locale-validation.json
exit $E
