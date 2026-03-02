{
  "id": "__PLUGIN_ID__",
  "name": "__PLUGIN_NAME__",
  "language": "go",
  "description": "Custom Go plugin",
  "command": [
    "go",
    "run",
    "{{POLYGLOT_DIR}}/plugins/__PLUGIN_ID__/plugin.go"
  ],
  "hooks": [
    "manual",
    "export_json"
  ],
  "timeout": 10
}
