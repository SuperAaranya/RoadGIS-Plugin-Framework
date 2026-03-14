#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"

options = { enable: nil, disable: nil }

OptionParser.new do |opts|
  opts.banner = "Usage: ruby tools/configure_framework.rb --enable go,rust | --disable rust"
  opts.on("--enable LIST", "Comma-separated languages to enable") { |v| options[:enable] = v }
  opts.on("--disable LIST", "Comma-separated languages to disable") { |v| options[:disable] = v }
end.parse!

root = File.expand_path("..", __dir__)
config_path = File.join(root, "framework_config.json")

config = { "enabled_languages" => ["go", "rust"] }
if File.exist?(config_path)
  begin
    loaded = JSON.parse(File.read(config_path, encoding: "UTF-8"))
    if loaded.is_a?(Hash) && loaded["enabled_languages"].is_a?(Array)
      config = loaded
    end
  rescue JSON::ParserError
    # Keep defaults
  end
end

enabled = config["enabled_languages"].map { |v| v.to_s.downcase }.uniq
if options[:enable]
  options[:enable].split(",").each { |v| enabled << v.strip.downcase }
end
if options[:disable]
  options[:disable].split(",").each { |v| enabled.delete(v.strip.downcase) }
end

config["enabled_languages"] = enabled.uniq
File.write(config_path, JSON.pretty_generate(config), mode: "w", encoding: "UTF-8")

puts "Framework configuration updated:"
puts "  enabled_languages: #{config['enabled_languages'].join(', ')}"
