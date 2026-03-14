# RoadGIS Plugin Framework (Go + Rust + Ruby Tools)

Create, test, and install custom plugins for RoadGIS-style plugin manager workflows.

This framework is built for teams who want to:

- clone a starter repo,
- scaffold plugins quickly,
- write plugin logic in Go or Rust,
- generate compatible plugin manifests,
- install plugins into a local RoadGIS workspace.

## What you get

- `plugins/`:
  - `go_hello_world`: working Go plugin example
  - `rust_hello_world`: working Rust plugin example
- `manifests/`:
  - ready-to-install manifests for both examples
- `templates/`:
  - starter templates for Go and Rust plugins
- `tools/` (Ruby):
  - `new_plugin.rb`: scaffold a new plugin
  - `install_plugin.rb`: install plugin + manifest into RoadGIS workspace
  - `validate_manifest.rb`: validate plugin manifest structure
  - `doctor.rb`: check required toolchains
- `schemas/`:
  - `manifest.schema.json`: reference schema for plugin manifests
- `fixtures/`:
  - sample input/output payloads for example plugins
- `packaging/`:
  - Windows 11 `.exe/.msi` build scaffolding
  - Debian + macOS: coming soon

## Plugin contract (RoadGIS-compatible)

Your plugin receives JSON on `stdin`, and must write JSON to `stdout`.

Expected manifest shape:

```json
{
  "id": "plugin_id",
  "name": "Plugin Name",
  "language": "go|rust",
  "description": "What it does",
  "command": ["go", "run", "{{POLYGLOT_DIR}}/plugins/my_plugin/plugin.go"],
  "hooks": ["export_json", "manual"],
  "timeout": 10
}
```

## Quick start

### 1) Clone into your workspace

```bash
git clone https://github.com/<your-user>/RoadGIS-Plugin-Framework.git
cd RoadGIS-Plugin-Framework
```

### 1.5) Non-developer install path

For end users, distribute prebuilt installers directly from this repo:

- Windows 11: `RoadGISProSetup.exe` or `RoadGISProSetup.msi` (active now)
- Debian: coming soon
- macOS Sonoma / Sequoia / Tahoe: coming soon

Put installer binaries under the documented locations in:

- `installer/artifacts/README.md`

### 2) Create a new plugin (Ruby tool)

Go plugin:

```bash
ruby tools/new_plugin.rb --lang go --id go_speed_audit --name "Go Speed Audit"
```

Rust plugin:

```bash
ruby tools/new_plugin.rb --lang rust --id rust_surface_check --name "Rust Surface Check"
```

This creates:

- source under `plugins/<id>/...`
- manifest under `manifests/<id>.json`

### 2.5) Validate environment and manifest

```bash
ruby tools/doctor.rb
ruby tools/validate_manifest.rb --manifest manifests/go_hello_world.json
```

### 2.6) Optional language modules (enable/disable)

The framework reads `framework_config.json` to determine which languages are enabled.

Example:

```bash
ruby tools/configure_framework.rb --enable go,rust
```

### 3) Implement your plugin logic

Read payload from `stdin`, emit JSON to `stdout`.

### 4) Install into your local RoadGIS workspace

```bash
ruby tools/install_plugin.rb ^
  --framework "[Content]\RoadGIS-Plugin-Framework" ^
  --roadgis "[Content]\RoadGISPro" ^
  --id go_speed_audit
```

PowerShell alternative (same args on one line):

```powershell
ruby tools/install_plugin.rb --framework "[Content]\RoadGIS-Plugin-Framework" --roadgis "[Content]\RoadGISPro" --id go_speed_audit
```

Installed targets:

- `<roadgis>/polyglot/plugins/<id>/...`
- `<roadgis>/polyglot/plugins/manifests/<id>.json`

### 5) Enable in GIS

In RoadGIS:

- `Plugins > Plugin Manager`
- `Reload Plugin Registry`
- enable your plugin
- run manually or via export hook

## Tutorial: from zero to plugin

1. Clone this repo.
2. Run `new_plugin.rb` for Go or Rust.
3. Edit generated source.
4. Test plugin by piping sample JSON into command from manifest.
5. Run `install_plugin.rb`.
6. Open RoadGIS plugin manager and enable it.
7. Run `Run Plugins on Current Layer` or export JSON.

## Requirements

- Go (for Go plugins)
- Rust + Cargo (for Rust plugins)
- Ruby 3+ (for scaffolding/install tools)

## Cross-OS installer build workflows

See:

- `packaging/README.md`

Quick examples:

Windows 11:

```powershell
pwsh .\packaging\windows\build_windows.ps1 -ProjectRoot "C:\path\to\RoadGISPro_fresh"
```

Debian + macOS:

Coming soon.

## Notes

- Commands use `{{POLYGLOT_DIR}}` placeholder so manifests remain portable.
- Keep plugin output a JSON object for best compatibility.
- Hook names currently used by RoadGIS: `manual`, `export_json`.
- Each plugin includes `compatibility.json` to record tested RoadGIS version range.

## Plugin pack builder

Create a single zip containing multiple plugins + manifests:

```bash
python tools/pack_plugins.py --out ./plugin-pack.zip
```

## Plugin library (GitHub Pages)

You can host a plugin catalog directly from this repo using GitHub Pages.

What ships in `docs/`:

- `index.html` and assets
- `plugins.json` catalog
- `packs/` downloadable plugin zips

Build the catalog and packs:

```bash
python tools/build_plugin_library.py
```

Enable Pages:

1. GitHub repo Settings
2. Pages
3. Source: Deploy from branch
4. Folder: `/docs`

Your library URL will look like:

```
https://<user>.github.io/RoadGIS-Plugin-Framework/plugins.json
```

In RoadGISPro, open:

- `Plugins > Plugin Library`
- Paste the URL above
- Install + Enable

## Community registry (central directory)

Want your own plugin repo listed in the official catalog?

1. Host your own `plugins.json` on GitHub Pages in your repo.
2. Open a PR here adding your URL to `docs/registry.json`.

Example entry:

```json
{
  "name": "Your Plugin Studio",
  "url": "https://<you>.github.io/YourPluginRepo/plugins.json",
  "trusted": false
}
```

We’ll review the PR, verify the URL loads, and merge it. Once merged, the website and RoadGISPro library will include your plugins automatically.

## Quick install + enable + run

```bash
ruby tools/quick_install_run.rb --framework C:/.../RoadGIS-Plugin-Framework --roadgis C:/.../RoadGISPro_fresh --id go_hello_world
```

## Fixtures

Sample payloads live in `fixtures/` to make testing quick and consistent.
