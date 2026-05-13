#!/usr/bin/env bash
# Full clean: remove all generated files, flutter clean, get deps, regenerate.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "▶ Deleting generated files..."
find lib -name "*.g.dart" -delete
find lib -name "*.freezed.dart" -delete
find lib -name "*.mocks.dart" -delete
find test -name "*.mocks.dart" -delete 2>/dev/null || true

echo "▶ Running flutter clean..."
flutter clean

echo "▶ Getting dependencies..."
flutter pub get

echo "▶ Regenerating code..."
dart run build_runner build --delete-conflicting-outputs

echo "✓ Clean rebuild complete."
