#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "optparse"

options = {
  framework: nil,
  roadgis: nil,
  id: nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby tools/install_plugin.rb --framework <path> --roadgis <path> --id <plugin_id>"
  opts.on("--framework PATH", "Path to RoadGIS-Plugin-Framework root") { |v| options[:framework] = v.to_s.strip }
  opts.on("--roadgis PATH", "Path to RoadGIS app root") { |v| options[:roadgis] = v.to_s.strip }
  opts.on("--id ID", "Plugin id") { |v| options[:id] = v.to_s.strip }
end.parse!

unless options.values.all? { |v| !v.to_s.empty? }
  abort("Missing args. Example:\n  ruby tools/install_plugin.rb --framework C:/.../RoadGIS-Plugin-Framework --roadgis C:/.../RoadGISPro_fresh --id go_speed_audit")
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

puts "Installed plugin '#{plugin_id}' into:"
puts "  #{dest_plugin}"
puts "  #{dest_manifest}"
