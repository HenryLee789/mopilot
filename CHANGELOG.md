# Changelog

## v0.3.0

- Added a richer MoPilot visual system with animated scan rings, soft glass panels, and subtle motion backgrounds.
- Reworked Dashboard into a maintenance cockpit with a live readiness panel, disk meter, and stronger tool tiles.
- Restyled command pages with product panels, an animated command status strip, and a polished console log area.
- Refined Uninstall selection rows with hover and selected states while preserving the dry-run-first workflow.
- Updated app bundle metadata to version `0.3.0`.

## v0.2.0

- Rebuilt Uninstall as a full GUI workflow.
- Added `mo uninstall --list` parsing for app selection.
- Added background `mo uninstall <app>` execution after dry-run preview and explicit confirmation.
- Removed Terminal.app handoff from the uninstall path.
- Cleaned TUI control sequences from displayed command logs.

## v0.1.0

- Renamed the app to MoPilot.
- Added GPL-3.0 licensing.
- Added productized SwiftUI dashboard and safety-first command pages.
- Added JSON capability detection for `mo analyze` and `mo status`.
- Added automatic fallback to raw logs when JSON is unavailable or invalid.
- Added DMG packaging through `create-dmg.sh`.
