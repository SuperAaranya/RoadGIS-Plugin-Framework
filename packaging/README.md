# Packaging and Installer Workflows

This folder provides script scaffolding for distribution workflows.

Targets:

- Windows 11: `.exe` + `.msi`
- Debian Linux: coming soon
- macOS Sonoma / Sequoia / Tahoe: coming soon

These scripts focus on repeatable build pipelines and can be customized for a CI/CD system.

## Windows 11

Run:

```powershell
pwsh ./packaging/windows/build_windows.ps1 -ProjectRoot "C:\path\to\RoadGISPro_fresh"
```

Expected tooling:

- Python + pip
- PyInstaller
- WiX Toolset (for MSI step)

## Debian Linux

Coming soon.

## macOS (Sonoma / Sequoia / Tahoe)

Coming soon.

## Notes

- Scripts create a `dist/` tree in the project root.
- Update app identifiers/signing certificates before production release.
