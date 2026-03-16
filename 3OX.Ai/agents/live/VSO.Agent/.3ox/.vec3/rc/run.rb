#!/usr/bin/env ruby
# RUN.RB :: VSO.AGENT L2 Runtime (.vec3/rc/)
# Supports: test, teleprompt (TPR config generation)

require 'json'
require 'yaml'
require 'fileutils'

DOT3OX = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

def dot3ox_path(*parts)
  File.join(DOT3OX, *parts)
end

def load_tools
  f = dot3ox_path('(4)Toolkit', 'tools.yml')
  File.exist?(f) ? YAML.load_file(f) : {}
end

def load_routes
  f = dot3ox_path('(5)Links', 'routes.json')
  return {} unless File.exist?(f)
  data = JSON.parse(File.read(f))
  data['routes'] || data
end

def load_limits
  f = dot3ox_path('(3)Rules', 'limits.toml')
  return {} unless File.exist?(f)
  parse_toml(File.read(f))
end

def parse_toml(str)
  h = {}
  section = []
  str.each_line do |line|
    next if line.strip.empty? || line.start_with?('#')
    if line =~ /^\[([^\]]+)\]/
      section = $1.split('.')
      target = h
      section[0..-2].each { |k| target = (target[k] ||= {}) }
      target[section.last] ||= {}
    elsif line =~ /^(\w+(?:\.\w+)*)\s*=\s*(.+)$/
      keys = section + $1.split('.')
      val = $2.strip.gsub(/^"|"$/, '')
      val = val.to_i if val =~ /^\d+$/
      val = (val == 'true') if %w[true false].include?(val.to_s)
      target = h
      keys[0..-2].each { |k| target = (target[k] ||= {}) }
      target[keys.last] = val
    end
  end
  h
end

def load_brain
  f = dot3ox_path('(2)Brains', 'brains.rs')
  return { 'name' => 'VSO.AGENT', 'type' => 'Advisor', 'rules' => [] } unless File.exist?(f)
  c = File.read(f)
  { 'name' => c[/name: "([^"]+)"/, 1] || 'VSO.AGENT', 'type' => c[/BrainType::(\w+)/, 1] || 'Advisor', 'rules' => [] }
end

def run_teleprompt(vps_path)
  agent_name = 'VSO.AGENT'
  topic_name = 'VSO'
  config = {
    agent: agent_name,
    topic: topic_name,
    path: vps_path,
    tpr_entry: { by_topic: { topic_name => agent_name } }
  }
  puts JSON.pretty_generate(config)
end

def run_test
  tools = load_tools
  limits = load_limits
  brain = load_brain
  puts "3OX TESTRUN :: VSO.AGENT"
  puts "Brain: #{brain['name']} (#{brain['type']})"
  puts "Tools: #{tools.fetch('tools', []).length} loaded"
  puts "Limits: OK"
end

if __FILE__ == $0
  cmd = ARGV[0] || 'test'
  case cmd
  when 'teleprompt'
    vps_path = ARGV[1] || '/root/!CMD.VPS/VSOAgent'
    run_teleprompt(vps_path)
  when 'test'
    run_test
  else
    run_test
  end
end
