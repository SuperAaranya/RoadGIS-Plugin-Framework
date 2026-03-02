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

## Notes

- Commands use `{{POLYGLOT_DIR}}` placeholder so manifests remain portable.
- Keep plugin output a JSON object for best compatibility.
- Hook names currently used by RoadGIS: `manual`, `export_json`.
