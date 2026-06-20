# Changelog

## v0.4.2

- Updated DMG packaging so the mounted installer shows `MoPilot.app` and an `Applications` shortcut side by side.
- Users can now drag `MoPilot.app` directly onto the `Applications` shortcut after opening the DMG.
- Updated app bundle metadata to version `0.4.2`.

## v0.4.1

- Tuned the Smart Care visual details: calmer scanner orb, lighter animated background, and more restrained gradients.
- Reduced title, card, and button sizing for a more polished desktop-tool feel.
- Simplified the custom sidebar by removing noisy secondary row text and tightening navigation spacing.
- Refined Dashboard and Clean layout density while preserving the scan-first workflow.
- Updated app bundle metadata to version `0.4.1`.

## v0.4.0

- Replaced the native sidebar with a custom grouped maintenance-tool sidebar.
- Rebuilt Dashboard around a Smart Care style scanner panel with a large animated orb, status modules, and a primary scan action.
- Reworked Clean into a scan-first screen with an animated dry-run orb and preview category tiles.
- Added reusable smart scanner, module tile, and gradient action components.
- Updated app bundle metadata to version `0.4.0`.

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
