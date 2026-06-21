#!/usr/bin/env bash
set -euo pipefail

CONFIGURATION="debug"
if [[ "${1:-}" == "--release" || "${1:-}" == "release" ]]; then
  CONFIGURATION="release"
fi

APP_DISPLAY_NAME="MoPilot"
EXECUTABLE_NAME="MoPilot"
BUNDLE_ID="io.github.mopilot.app"
APP_VERSION="0.6.0"
MIN_SYSTEM_VERSION="13.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_DISPLAY_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$EXECUTABLE_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
SOURCE_ICON="$ROOT_DIR/Sources/MoPilot/Resources/AppIcon.icns"

SWIFT_BIN="${SWIFT_BIN:-/usr/bin/swift}"
SWIFTC_BIN="${SWIFTC_BIN:-/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc}"
SDK_PATH="${SDKROOT:-/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk}"
MANUAL_BUILD_DIR="$ROOT_DIR/.build/manual/$CONFIGURATION"

if "$SWIFT_BIN" build -c "$CONFIGURATION"; then
  BUILD_BINARY="$("$SWIFT_BIN" build -c "$CONFIGURATION" --show-bin-path)/$EXECUTABLE_NAME"
else
  echo "SwiftPM build failed; falling back to direct swiftc build." >&2
  if [[ ! -x "$SWIFTC_BIN" ]]; then
    echo "swiftc not found at $SWIFTC_BIN" >&2
    exit 1
  fi
  if [[ ! -d "$SDK_PATH" ]]; then
    echo "macOS SDK not found at $SDK_PATH" >&2
    exit 1
  fi

  mkdir -p "$MANUAL_BUILD_DIR"
  BUILD_BINARY="$MANUAL_BUILD_DIR/$EXECUTABLE_NAME"
  SWIFT_SOURCES=()
  while IFS= read -r source_file; do
    SWIFT_SOURCES+=("$source_file")
  done < <(find "$ROOT_DIR/Sources/MoPilot" -name '*.swift' | sort)

  SWIFT_OPTIMIZATION="-Onone"
  if [[ "$CONFIGURATION" == "release" ]]; then
    SWIFT_OPTIMIZATION="-O"
  fi

  "$SWIFTC_BIN" \
    "$SWIFT_OPTIMIZATION" \
    -sdk "$SDK_PATH" \
    -target "$(uname -m)-apple-macosx$MIN_SYSTEM_VERSION" \
    -o "$BUILD_BINARY" \
    "${SWIFT_SOURCES[@]}"
fi

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"

if [[ -f "$SOURCE_ICON" ]]; then
  cp "$SOURCE_ICON" "$APP_RESOURCES/AppIcon.icns"
fi

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_DISPLAY_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_DISPLAY_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleVersion</key>
  <string>$APP_VERSION</string>
  <key>CFBundleShortVersionString</key>
  <string>$APP_VERSION</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

if command -v /usr/bin/xattr >/dev/null 2>&1; then
  /usr/bin/xattr -cr "$APP_BUNDLE" >/dev/null 2>&1 || true
fi

if command -v /usr/bin/codesign >/dev/null 2>&1; then
  /usr/bin/codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null
fi

echo "Built $APP_BUNDLE"
