#!/usr/bin/env ruby
# Setup new .3ox folder from templates

require 'fileutils'

def setup_3ox(target_dir, agent_name, brain_type)
  dot3ox = File.join(target_dir, ".3ox")
  FileUtils.mkdir_p(dot3ox)
  
  # Copy templates
  templates = File.join(File.dirname(__FILE__), "TEMPLATES")
  FileUtils.cp("#{templates}/brain.rs", "#{dot3ox}/brain.rs")
  FileUtils.cp("#{templates}/tools.yml", "#{dot3ox}/tools.yml")
  FileUtils.cp("#{templates}/limits.json", "#{dot3ox}/limits.json")
  FileUtils.cp("#{templates}/routes.json", "#{dot3ox}/routes.json")
  FileUtils.cp("#{templates}/run.rb", "#{dot3ox}/run.rb")
  
  # Customize brain.rs
  brain_content = File.read("#{dot3ox}/brain.rs")
  brain_content.gsub!("AGENT_NAME", agent_name)
  brain_content.gsub!("BrainType::Sentinel", "BrainType::#{brain_type}")
  File.write("#{dot3ox}/brain.rs", brain_content)
  
  puts "✓ .3ox system created at #{dot3ox}"
  puts "✓ Agent: #{agent_name}"
  puts "✓ Type: #{brain_type}"
  puts "✓ Templates deployed"
end

if ARGV.length < 3
  puts "Usage: ruby setup-3ox.rb <target_dir> <agent_name> <brain_type>"
  puts "Example: ruby setup-3ox.rb MyProject GUARDIAN Sentinel"
  exit 1
end

setup_3ox(ARGV[0], ARGV[1], ARGV[2])

