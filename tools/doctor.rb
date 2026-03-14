#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

TOOLS = {
  "go" => "Go plugins",
  "cargo" => "Rust plugins",
  "ruby" => "Framework tooling",
  "python" => "Setup/build helper scripts",
  "node" => "JavaScript engines",
  "dotnet" => "C# engines",
  "java" => "Java engines",
  "pyinstaller" => "Executable packaging (Windows)"
}.freeze

LANG_TOOL = {
  "go" => "go",
  "cargo" => "rust"
}.freeze

def tool_available?(name)
  exts = Gem.win_platform? ? [".exe", ".cmd", ".bat", ""] : [""]
  ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |dir|
    exts.any? { |ext| File.executable?(File.join(dir, "#{name}#{ext}")) }
  end
end

root = File.expand_path("..", __dir__)
config_path = File.join(root, "framework_config.json")
enabled_langs = ["go", "rust"]
if File.exist?(config_path)
  begin
    cfg = JSON.parse(File.read(config_path, encoding: "UTF-8"))
    if cfg.is_a?(Hash) && cfg["enabled_languages"].is_a?(Array)
      enabled_langs = cfg["enabled_languages"].map { |v| v.to_s.downcase }
    end
  rescue JSON::ParserError
    # keep defaults
  end
end

puts "RoadGIS Plugin Framework Doctor"
puts "================================"
TOOLS.each do |tool, purpose|
  lang = LANG_TOOL[tool]
  if lang && !enabled_langs.include?(lang)
    puts format("%-12s %-8s %s", tool, "DISABLED", purpose)
    next
  end
  ok = tool_available?(tool)
  status = ok ? "OK" : "MISSING"
  puts format("%-12s %-8s %s", tool, status, purpose)
end
