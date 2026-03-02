{
  "id": "__PLUGIN_ID__",
  "name": "__PLUGIN_NAME__",
  "language": "rust",
  "description": "Custom Rust plugin",
  "command": [
    "cargo",
    "run",
    "--quiet",
    "--release",
    "--manifest-path",
    "{{POLYGLOT_DIR}}/plugins/__PLUGIN_ID__/Cargo.toml"
  ],
  "hooks": [
    "manual",
    "export_json"
  ],
  "timeout": 15
}
