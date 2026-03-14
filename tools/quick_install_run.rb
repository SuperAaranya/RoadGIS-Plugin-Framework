#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "optparse"
require "open3"

options = {
  framework: nil,
  roadgis: nil,
  id: nil,
  payload: nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby tools/quick_install_run.rb --framework <path> --roadgis <path> --id <plugin_id> [--payload payload.json]"
  opts.on("--framework PATH", "Path to RoadGIS-Plugin-Framework root") { |v| options[:framework] = v.to_s.strip }
  opts.on("--roadgis PATH", "Path to RoadGIS app root") { |v| options[:roadgis] = v.to_s.strip }
  opts.on("--id ID", "Plugin id") { |v| options[:id] = v.to_s.strip }
  opts.on("--payload PATH", "Optional payload JSON file") { |v| options[:payload] = v.to_s.strip }
end.parse!

unless options.values_at(:framework, :roadgis, :id).all? { |v| !v.to_s.empty? }
  abort("Missing args. Example:\n  ruby tools/quick_install_run.rb --framework C:/.../RoadGIS-Plugin-Framework --roadgis C:/.../RoadGISPro_fresh --id go_speed_audit")
end

framework = File.expand_path(options[:framework])
roadgis = File.expand_path(options[:roadgis])
plugin_id = options[:id]

src_plugin = File.join(framework, "plugins", plugin_id)
src_manifest = File.join(framework, "manifests", "#{plugin_id}.json")

abort("Plugin source missing: #{src_plugin}") unless Dir.exist?(src_plugin)
abort("Manifest missing: #{src_manifest}") unless File.exist?(src_manifest)

dest_plugins_dir = File.join(roadgis, "polyglot", "plugins")
dest_manifests_dir = File.join(dest_plugins_dir, "manifests")
FileUtils.mkdir_p(dest_plugins_dir)
FileUtils.mkdir_p(dest_manifests_dir)

dest_plugin = File.join(dest_plugins_dir, plugin_id)
dest_manifest = File.join(dest_manifests_dir, "#{plugin_id}.json")

FileUtils.rm_rf(dest_plugin) if Dir.exist?(dest_plugin)
FileUtils.cp_r(src_plugin, dest_plugin)
FileUtils.cp(src_manifest, dest_manifest)

manifest = JSON.parse(File.read(dest_manifest, encoding: "UTF-8"))
unless manifest.is_a?(Hash) && manifest["id"] == plugin_id
  abort("Installed manifest id mismatch for #{plugin_id}")
end

user_root = ENV["LOCALAPPDATA"] || ENV["APPDATA"] || File.expand_path("~")
user_dir = File.join(user_root, "RoadGISPro")
FileUtils.mkdir_p(user_dir)
registry_path = File.join(user_dir, "plugin_registry.json")

registry = []
if File.exist?(registry_path)
  begin
    loaded = JSON.parse(File.read(registry_path, encoding: "UTF-8"))
    registry = loaded if loaded.is_a?(Array)
  rescue JSON::ParserError
    registry = []
  end
end

manifest["enabled"] = true
registry.reject! { |p| p.is_a?(Hash) && p["id"] == plugin_id }
registry << manifest
File.write(registry_path, JSON.pretty_generate(registry), mode: "w", encoding: "UTF-8")

payload = if options[:payload] && File.exist?(options[:payload])
            JSON.parse(File.read(options[:payload], encoding: "UTF-8"))
          else
            { "roads" => [], "connectors" => [], "feature_count" => 0 }
          end

polyglot_dir = File.join(roadgis, "polyglot")
plugin_dir = dest_plugins_dir
cmd = Array(manifest["command"]).map do |tok|
  tok.to_s
     .gsub("{{BASE_DIR}}", roadgis)
     .gsub("{{POLYGLOT_DIR}}", polyglot_dir)
     .gsub("{{PLUGIN_DIR}}", plugin_dir)
end

puts "Installed + enabled '#{plugin_id}'. Running plugin..."
stdout, stderr, status = Open3.capture3(*cmd, stdin_data: JSON.generate(payload))
puts stdout unless stdout.to_s.strip.empty?
warn stderr unless stderr.to_s.strip.empty?
puts "Exit code: #{status.exitstatus}"
