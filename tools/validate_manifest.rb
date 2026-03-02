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

unless manifest["command"].is_a?(Array) && !manifest["command"].empty?
  abort("Invalid manifest. 'command' must be a non-empty array.")
end

unless manifest["hooks"].is_a?(Array) && !manifest["hooks"].empty?
  abort("Invalid manifest. 'hooks' must be a non-empty array.")
end

puts "Manifest valid: #{path}"
