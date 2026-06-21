# Changelog

## v0.6.3

- Replaced the MoPilot icon artwork with the newly provided blue-purple cleanup monitor image.
- Converted the source image's edge-connected black background into transparency for cleaner Finder and Dock rendering.
- Added transparent padding around the icon artwork so the Dock size matches neighboring macOS app icons more closely.
- Regenerated `AppIcon.icns` and `AppIcon.png`.
- Localized the visible app interface further into Chinese, including sidebar items, dashboard actions, module cards, command pages, settings diagnostics, and saved log labels.
- Localized the default macOS menu titles and common menu commands into Chinese at launch.
- Updated app bundle metadata to version `0.6.3`.

## v0.6.2

- Replaced the MoPilot app icon with the new blue-purple cleanup monitor artwork.
- Added `AppIcon.png` for in-app branding and updated the sidebar brand mark to use the real app icon.
- Updated app bundle resource copying so packaged builds include all files under `Sources/MoPilot/Resources`.
- Updated app bundle metadata to version `0.6.2`.

## v0.6.1

- Added visible hover feedback for sidebar rows, collapsible section headers, Settings footer, primary scan controls, secondary action buttons, feature cards, result pills, and Uninstaller app rows.
- Added pointing-hand cursor behavior for enabled interactive controls.
- Replaced remaining default Settings and Uninstaller toolbar buttons with the unified MoPilot secondary button style.
- Preserved the existing Mole CLI command execution, dry-run protection, confirmation dialogs, and logging behavior.
- Updated app bundle metadata to version `0.6.1`.

## v0.6.0

- Reworked the UI layer with Mac Sai-inspired SwiftUI structure and visual patterns while preserving MoPilot's own Mole CLI wrapper logic.
- Added adapted superellipse cards/buttons, module theme gradients, scan button/progress ring patterns, grouped sidebar structure, result pills, and themed module backgrounds.
- Updated Dashboard to a Mac Sai-style scan state layout with a large scan control, result pills, status cards, and category cards.
- Applied themed shells to System Junk, Large Files, Uninstaller, Privacy, System Status, and Settings.
- Added `THIRD_PARTY_NOTICES.md` with the Mac Sai BSD 3-Clause copyright notice and license text.
- Updated app bundle metadata to version `0.6.0`.

## v0.5.0

- Rebuilt the visible UI around a modern macOS card-based utility layout.
- Switched the root shell back to `NavigationSplitView` with the requested sidebar entries: Dashboard, System Junk, Large Files, Uninstaller, Privacy, and Settings.
- Added reusable UI components: `SidebarItem`, `FeatureCard`, `StatusCard`, `PrimaryButton`, and `ProgressCard`.
- Reworked Dashboard with a large scan status card, progress state, safe dry-run scanning, confirmation before cleaning, and four cleanup module cards.
- Restyled System Junk, Large Files, Uninstaller, Privacy, Status, logs, and shared cards with consistent rounded corners, shadows, icon badges, status tags, and adaptive light/dark colors.
- Added a direct `swiftc` fallback and ad-hoc signing step to `build.sh` for local environments where SwiftPM is blocked by Xcode license state.
- Updated app bundle metadata to version `0.5.0`.

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
