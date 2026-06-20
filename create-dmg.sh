#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_BUNDLE="$ROOT_DIR/dist/MoPilot.app"
DMG_PATH="$ROOT_DIR/dist/MoPilot.dmg"

"$ROOT_DIR/build.sh" --release

rm -f "$DMG_PATH"
hdiutil create \
  -volname "MoPilot" \
  -srcfolder "$APP_BUNDLE" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Built $DMG_PATH"
