#!/usr/bin/env ruby
# frozen_string_literal: true

TOOLS = {
  "go" => "Go plugins",
  "cargo" => "Rust plugins",
  "ruby" => "Framework tooling",
  "python" => "Setup/build helper scripts",
  "node" => "JavaScript engines",
  "dotnet" => "C# engines",
  "java" => "Java engines",
  "pyinstaller" => "Executable packaging",
  "dpkg-deb" => "Debian package build",
  "pkgbuild" => "macOS package build"
}.freeze

def tool_available?(name)
  exts = Gem.win_platform? ? [".exe", ".cmd", ".bat", ""] : [""]
  ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |dir|
    exts.any? { |ext| File.executable?(File.join(dir, "#{name}#{ext}")) }
  end
end

puts "RoadGIS Plugin Framework Doctor"
puts "================================"
TOOLS.each do |tool, purpose|
  ok = tool_available?(tool)
  status = ok ? "OK" : "MISSING"
  puts format("%-12s %-8s %s", tool, status, purpose)
end
