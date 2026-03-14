#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"

options = { manifest: nil }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby tools/validate_manifest.rb --manifest <path-to-manifest.json>"
  opts.on("--manifest PATH", "Manifest file path") { |v| options[:manifest] = v.to_s.strip }
end.parse!

abort("Missing --manifest") if options[:manifest].to_s.empty?
path = File.expand_path(options[:manifest])
abort("Manifest not found: #{path}") unless File.exist?(path)

manifest = JSON.parse(File.read(path, encoding: "UTF-8"))
required = %w[id name language command hooks timeout]
missing = required.reject { |k| manifest.key?(k) }

if missing.any?
  abort("Invalid manifest. Missing keys: #{missing.join(', ')}")
end

def ensure!(cond, msg)
  abort(msg) unless cond
end

ensure!(manifest["id"].is_a?(String) && !manifest["id"].strip.empty?, "Invalid manifest. 'id' must be a non-empty string.")
ensure!(manifest["name"].is_a?(String) && !manifest["name"].strip.empty?, "Invalid manifest. 'name' must be a non-empty string.")
ensure!(manifest["language"].is_a?(String) && !manifest["language"].strip.empty?, "Invalid manifest. 'language' must be a non-empty string.")
ensure!(manifest["command"].is_a?(Array) && !manifest["command"].empty?, "Invalid manifest. 'command' must be a non-empty array.")
ensure!(manifest["command"].all? { |v| v.is_a?(String) && !v.strip.empty? }, "Invalid manifest. 'command' entries must be non-empty strings.")
ensure!(manifest["hooks"].is_a?(Array) && !manifest["hooks"].empty?, "Invalid manifest. 'hooks' must be a non-empty array.")
ensure!(manifest["hooks"].all? { |v| v.is_a?(String) && !v.strip.empty? }, "Invalid manifest. 'hooks' entries must be non-empty strings.")

timeout = manifest["timeout"]
ensure!(timeout.is_a?(Integer), "Invalid manifest. 'timeout' must be an integer.")
ensure!(timeout >= 1 && timeout <= 60, "Invalid manifest. 'timeout' must be between 1 and 60.")

if manifest.key?("compatibility")
  compat = manifest["compatibility"]
  ensure!(compat.is_a?(Hash), "Invalid manifest. 'compatibility' must be an object.")
  ensure!(compat["min_app_version"].is_a?(String) && !compat["min_app_version"].strip.empty?,
          "Invalid manifest. 'compatibility.min_app_version' must be a string.")
  ensure!(compat["max_app_version"].is_a?(String) && !compat["max_app_version"].strip.empty?,
          "Invalid manifest. 'compatibility.max_app_version' must be a string.")
end

puts "Manifest valid: #{path}"
