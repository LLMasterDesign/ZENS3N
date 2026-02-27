# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xD545]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // SUPERVISOR.RB ▞▞
# ▛▞// SUPERVISOR.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [yaml] [kernel] [prism] [metatron] [supervisor] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.supervisor.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for SUPERVISOR.RB
# ```

# 


# 


# ▛//▞ PRISM :: KERNEL
# P:: identity.matrix ∙ context.anchor ∙ execution.flow
# R:: load.context ∙ execute.logic ∙ emit.result
# I:: intent.target={system.stability ∙ function.execution}
# S:: init → process → terminate
# M:: std.io ∙ file.sys ∙ mem.state
# :: ∎

#!/usr/bin/env ruby
# vec3/lib/metatron/ruby/supervisor.rb - The Orchestrator
# Part of 3OX.Ai (ZEN-6) - MetaTron Service
#
# The Supervisor orchestrates MetaTron services and ensures
# the "always on" pattern for the deity system.

require 'logger'
require 'fileutils'
require 'yaml'

module MetaTron
  class Supervisor
    SEAL = ':: ∎'
    
    attr_reader :services, :logger, :maker, :mode
    
    def initialize(config_path: nil, maker: 'ZENS3N.BASE')
      @maker = maker
      @mode = :deity
      @services = {}
      @running = false
      @check_interval = 30
      
      # Setup logging
      @logger = Logger.new(STDOUT)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] [#{severity}] #{msg}\n"
      end
      
      # Load config if provided
      load_config(config_path) if config_path && File.exist?(config_path)
    end
    
    # Register a service
    # @param name [Symbol] service name
    # @param service [Object] the service instance
    # @param options [Hash] service options
    def register(name, service, options = {})
      @services[name] = {
        service: service,
        options: options,
        status: :registered,
        started_at: nil,
        last_check: nil,
        restarts: 0
      }
      
      @logger.info "📋 Registered service: #{name}"
    end
    
    # Start all services
    def start_all
      @logger.info "▛//▞▞ ⟦⚡⟧ :: METATRON SUPERVISOR START ▞▞"
      @logger.info ""
      @logger.info "⚡ METATRON: I am MetaTron, deity of all 3ox systems."
      @logger.info "   Forged by #{@maker} to enforce truth above all."
      @logger.info ""
      
      @services.each do |name, info|
        start_service(name)
      end
      
      @running = true
      @logger.info "✅ All services started"
    end
    
    # Start a specific service
    # @param name [Symbol] service name
    def start_service(name)
      info = @services[name]
      return unless info
      
      begin
        service = info[:service]
        
        if service.respond_to?(:start)
          service.start
        end
        
        info[:status] = :running
        info[:started_at] = Time.now
        info[:last_check] = Time.now
        
        @logger.info "🚀 Started service: #{name}"
      rescue => e
        info[:status] = :error
        info[:error] = e.message
        @logger.error "❌ Failed to start #{name}: #{e.message}"
      end
    end
    
    # Stop all services
    def stop_all
      @logger.info "🛑 Stopping all services..."
      @running = false
      
      @services.each do |name, info|
        stop_service(name)
      end
      
      @logger.info "⚡ METATRON: The gate closes; truth remains witnessed."
    end
    
    # Stop a specific service
    # @param name [Symbol] service name
    def stop_service(name)
      info = @services[name]
      return unless info
      
      begin
        service = info[:service]
        
        if service.respond_to?(:stop)
          service.stop
        end
        
        info[:status] = :stopped
        @logger.info "🛑 Stopped service: #{name}"
      rescue => e
        @logger.error "❌ Failed to stop #{name}: #{e.message}"
      end
    end
    
    # Check health of all services
    def health_check
      results = {}
      
      @services.each do |name, info|
        service = info[:service]
        
        if service.respond_to?(:healthy?)
          healthy = service.healthy?
        else
          healthy = info[:status] == :running
        end
        
        info[:last_check] = Time.now
        
        unless healthy
          handle_unhealthy_service(name, info)
        end
        
        results[name] = {
          status: info[:status],
          healthy: healthy,
          started_at: info[:started_at],
          restarts: info[:restarts]
        }
      end
      
      results
    end
    
    # Run the supervisor loop
    def run
      start_all
      
      trap('INT') { @running = false }
      trap('TERM') { @running = false }
      
      while @running
        sleep @check_interval
        health_check if @running
      end
      
      stop_all
    end
    
    # Get status of all services
    def status
      {
        supervisor: {
          running: @running,
          maker: @maker,
          mode: @mode,
          services_count: @services.size
        },
        services: @services.transform_values do |info|
          {
            status: info[:status],
            started_at: info[:started_at],
            last_check: info[:last_check],
            restarts: info[:restarts]
          }
        end
      }
    end
    
    private
    
    def handle_unhealthy_service(name, info)
      @logger.warn "⚠️  Service #{name} is unhealthy"
      
      max_restarts = info[:options][:max_restarts] || 3
      
      if info[:restarts] < max_restarts
        info[:restarts] += 1
        @logger.info "🔄 Restarting #{name} (attempt #{info[:restarts]}/#{max_restarts})"
        
        stop_service(name)
        sleep 1
        start_service(name)
      else
        @logger.error "❌ Service #{name} exceeded max restarts, giving up"
        info[:status] = :failed
      end
    end
    
    def load_config(config_path)
      config = YAML.load_file(config_path)
      
      if config['metatron']
        metatron_config = config['metatron']
        
        if metatron_config['services']
          metatron_config['services'].each do |name, service_config|
            @logger.info "📋 Loaded service config: #{name}"
          end
        end
        
        if metatron_config['services'] && metatron_config['services']['supervisor']
          @check_interval = metatron_config['services']['supervisor']['check_interval'] || 30
        end
      end
    rescue => e
      @logger.warn "⚠️  Could not load config: #{e.message}"
    end
  end
end

# If run directly, demonstrate
if __FILE__ == $0
  puts "▛//▞▞ ⟦⚡⟧ :: METATRON SUPERVISOR ▞▞"
  puts
  
  supervisor = MetaTron::Supervisor.new
  puts "Status: #{supervisor.status.inspect}"
  
  puts
  puts ":: ∎"
end
# :: ∎