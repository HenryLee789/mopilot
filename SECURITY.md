# Security

MoPilot is a local GUI wrapper for the Mole CLI. It does not include Mole CLI internals and does not run cleanup operations automatically.

## Reporting

Please open a GitHub issue for MoPilot-specific UI, packaging, or wrapper behavior.

For Mole CLI behavior, review the Mole project directly:

<https://github.com/tw93/Mole>

## Safety Defaults

- Clean and Optimize require dry-run preview before real execution.
- Uninstall real execution runs in the app only after GUI selection, dry-run preview, and explicit confirmation.
- MoPilot does not store passwords or silently provide administrator credentials.
- Command logs are written to `~/Library/Logs/MoPilot/`.
