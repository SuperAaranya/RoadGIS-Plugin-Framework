#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "optparse"

options = {
  lang: nil,
  id: nil,
  name: nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby tools/new_plugin.rb --lang <go|rust> --id <plugin_id> --name <Plugin Name>"
  opts.on("--lang LANG", "Plugin language: go or rust") { |v| options[:lang] = v.to_s.strip.downcase }
  opts.on("--id ID", "Plugin id (folder + manifest id)") { |v| options[:id] = v.to_s.strip }
  opts.on("--name NAME", "Plugin display name") { |v| options[:name] = v.to_s.strip }
end.parse!

unless %w[go rust].include?(options[:lang]) && !options[:id].to_s.empty? && !options[:name].to_s.empty?
  abort("Invalid arguments. Example:\n  ruby tools/new_plugin.rb --lang go --id go_speed_audit --name \"Go Speed Audit\"")
end

root = File.expand_path("..", __dir__)
templates_dir = File.join(root, "templates")
plugins_dir = File.join(root, "plugins")
manifests_dir = File.join(root, "manifests")

plugin_id = options[:id]
plugin_name = options[:name]
lang = options[:lang]

if lang == "go"
  plugin_dir = File.join(plugins_dir, plugin_id)
  FileUtils.mkdir_p(plugin_dir)
  tpl_plugin = File.read(File.join(templates_dir, "go_plugin", "plugin.go.tpl"), encoding: "UTF-8")
  tpl_manifest = File.read(File.join(templates_dir, "go_plugin", "manifest.json.tpl"), encoding: "UTF-8")
  File.write(File.join(plugin_dir, "plugin.go"), tpl_plugin.gsub("__PLUGIN_ID__", plugin_id), mode: "w", encoding: "UTF-8")
else
  plugin_dir = File.join(plugins_dir, plugin_id)
  FileUtils.mkdir_p(File.join(plugin_dir, "src"))
  tpl_cargo = File.read(File.join(templates_dir, "rust_plugin", "Cargo.toml.tpl"), encoding: "UTF-8")
  tpl_main = File.read(File.join(templates_dir, "rust_plugin", "main.rs.tpl"), encoding: "UTF-8")
  tpl_manifest = File.read(File.join(templates_dir, "rust_plugin", "manifest.json.tpl"), encoding: "UTF-8")
  File.write(File.join(plugin_dir, "Cargo.toml"), tpl_cargo.gsub("__PLUGIN_ID__", plugin_id), mode: "w", encoding: "UTF-8")
  File.write(File.join(plugin_dir, "src", "main.rs"), tpl_main.gsub("__PLUGIN_ID__", plugin_id), mode: "w", encoding: "UTF-8")
end

manifest = tpl_manifest.gsub("__PLUGIN_ID__", plugin_id).gsub("__PLUGIN_NAME__", plugin_name)
FileUtils.mkdir_p(manifests_dir)
manifest_path = File.join(manifests_dir, "#{plugin_id}.json")
File.write(manifest_path, manifest, mode: "w", encoding: "UTF-8")

puts "Created plugin:"
puts "  Language: #{lang}"
puts "  Source:   #{plugin_dir}"
puts "  Manifest: #{manifest_path}"
