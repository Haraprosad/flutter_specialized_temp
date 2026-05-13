#!/usr/bin/env bash
# Run after adding new @freezed, @injectable, or @JsonSerializable classes.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "▶ Running code generation..."
dart run build_runner build --delete-conflicting-outputs
echo "✓ Code generation complete."
