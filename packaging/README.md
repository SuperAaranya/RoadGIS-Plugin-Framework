# Packaging and Installer Workflows

This folder provides script scaffolding for distribution workflows.

Targets:

- Windows 11: `.exe` + `.msi`
- Debian Linux: `.deb`
- macOS Sonoma / Sequoia / Tahoe: `.app` + `.pkg`

These scripts focus on repeatable build pipelines and can be customized for your CI/CD.

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

Run:

```bash
bash ./packaging/linux/build_debian.sh /path/to/RoadGISPro_fresh
```

Expected tooling:

- python3
- pip
- pyinstaller
- dpkg-deb (or fpm if you adapt script)

## macOS (Sonoma / Sequoia / Tahoe)

Run:

```bash
bash ./packaging/macos/build_macos.sh /path/to/RoadGISPro_fresh
```

Expected tooling:

- python3
- pyinstaller
- pkgbuild
- productbuild
- codesign / notarization tools for signed distribution

## Notes

- Scripts create a `dist/` tree in your project root.
- Update app identifiers/signing certificates before production release.
