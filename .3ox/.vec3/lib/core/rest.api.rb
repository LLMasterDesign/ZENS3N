# ///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA808]::
# ▛//▞▞ ⟦⎊⟧ :: ⧗-26.034 // REST.API.RB ▞▞
# ▛▞// REST.API.RB :: ρ{Input}.φ{Process}.τ{Output} ▹
# //▞⋮⋮ ⟦🧬⟧ :: [pheno] [telegram] [json] [token] [kernel] [prism] [z3n] [⊢ ⇨ ⟿ ▷]
# ⫸ 〔vec3.rest.api.context〕
# 
# ```elixir
# /// Status: [ACTIVE] | Version: 1.0.0 | Authority: ZENS3N | Created: ⧗-26.034
# /// Auto-generated Pheno-Identity for REST.API.RB
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
SEAL = ':: ∎'
#/command2 = description2
#/command1 = description1
#(Add toolset commands here)
#▛//▞ TOOLSET ::
#
#```
##///          (Add third line of purpose here)
##///          (Add second line of purpose here)
##/// Purpose: !/usr/bin/env ruby
##/// Last Updated: 2026.01.05 | Trace.ID: rest.api.v1.0
##/// Status: [ACTIVE] | Cat: SYSTEM | Auth: SYSTEM | Created: 2026.01.05
#```elixir
end
  }
    CTX: '⫸ 〔runtime.script.context〕'
    PiCO: '//▞⋮⋮ [🔧] ≔ [rest_api] [system] [ruby] ⊢ ⇨ ⟿ ▷ :: ∎',
    PHENO: '▛▞// !/usr/bin/env ruby :: ρ{Input}.φ{Process}.τ{Output} ▹',
    IMPRINT: '▛//▞▞ ⟦⎊⟧ ::  // REST.API ▞▞',
    SCHEMA: '///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ ::[0xA4]::',
  SPEC = {
module Z3N
#
# REST.API.RB :: REST API Server for CMD.BRIDGE
# WEBrick-based HTTP server providing control plane interface (Sinatra-free)
#

require 'sinatra'
require 'json'
require 'securerandom'
require 'time'

require_relative '../ops/lib/helpers.rb'
# Optional: legacy redis helper (may not exist in minimal runtime)
begin
  require_relative '../ops/cache/redis.rb'
rescue LoadError
  # no-op
end
require_relative '../bin/sirius.clock.rb'

class CMDRestAPI < Sinatra::Base
  include Helpers

  def self.load_capsule_info
    {
      version: '3.0.0',
      name: 'CMD.BRIDGE',
      description: 'Microkernel OS for AI agents',
      sirius_time: '⧗-26.146',
      capabilities: ['ask', 'serve', 'rest', 'telegram', 'shell']
    }
  end

  configure do
    set :bind, '127.0.0.1'
    set :port, 7777
    set :server, :webrick
    set :show_exceptions, false
    set :dump_errors, true

    # Enable CORS for console.html
    set :allow_origin, :any
    set :allow_methods, [:get, :post, :options]
    set :allow_headers, ['*']
    set :expose_headers, ['Content-Type']

    # Load configuration
    set :api_version, 'v1'
    set :capsule_info, load_capsule_info
  end

  before do
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Methods' => 'GET, POST, OPTIONS'
    headers 'Access-Control-Allow-Headers' => '*'
    headers 'Access-Control-Max-Age' => '86400'

    # Handle preflight OPTIONS requests
    if request.request_method == 'OPTIONS'
      halt 200
    end

    # Bearer token authentication for protected endpoints
    if protected_endpoint?(request.path_info)
      auth_header = request.env['HTTP_AUTHORIZATION'] || ''
      unless auth_header.start_with?('Bearer ')
        halt 401, json({ error: 'Missing or invalid authorization header' })
      end

      token = auth_header.sub('Bearer ', '')
      unless valid_bearer_token?(token)
        halt 403, json({ error: 'Invalid bearer token' })
      end
    end
  end

  # ============================================================================
  # CONFIGURATION & UTILITIES
  # ============================================================================

  def load_capsule_info
    {
      name: 'CMD.BRIDGE',
      version: '3.0.0',
      api_version: 'v1',
      sirius_epoch: '2025-08-08',
      capabilities: ['file_ingest', 'ai_assistant', 'receipts', 'redis_state'],
      endpoints: ['/health', '/version', '/jobs', '/jobs/:id', '/jobs/:id/receipt']
    }
  end

  def protected_endpoint?(path)
    # Protect job submission and status endpoints
    path.start_with?('/v1/jobs') && !path.end_with?('/health') && !path.end_with?('/version')
  end

  def valid_bearer_token?(token)
    # Load bearer token from 3ox.key file
    key_file = File.join(get_dot3ox_root, '3ox.key')
    return false unless File.exist?(key_file)

    expected_token = File.read(key_file).strip
    token == expected_token
  rescue
    false
  end

  def generate_job_id
    timestamp = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
    random = SecureRandom.hex(4)
    "#{timestamp}-#{random}"
  end

  def validate_job_data(data)
    errors = []

    # Required fields
    errors << 'Missing op field' unless data['op']
    errors << 'Missing inputs field' unless data['inputs']
    errors << 'inputs must be an array' unless data['inputs'].is_a?(Array)

    # Validate inputs
    if data['inputs'].is_a?(Array)
      data['inputs'].each do |input|
        if input.is_a?(Hash) && input['path']
          unless File.exist?(input['path'])
            errors << "Input file does not exist: #{input['path']}"
          end
        end
      end
    end

    # Optional validations
    if data['params'] && !data['params'].is_a?(Hash)
      errors << 'params must be an object'
    end

    if data['route'] && !data['route'].is_a?(String)
      errors << 'route must be a string'
    end

    errors
  end

  def submit_job_to_queue(job_data)
    # Write to Redis queue if available
    if RedisCache.redis_available?
      job_record = {
        job_id: job_data[:job_id],
        op: job_data[:op],
        inputs: job_data[:inputs],
        params: job_data[:params] || {},
        route: job_data[:route] || 'default',
        submitted_at: job_data[:submitted_at],
        status: 'queued'
      }

      RedisCache.queue_push('jobs', job_record)
      log_operation('job_submit', 'COMPLETE', "Job: #{job_data[:job_id]}, Op: #{job_data[:op]}")
      return true
    end

    # Fallback: write to file-based queue
    queue_dir = File.join(get_vec3_root, 'var', 'queue')
    ensure_dirs(queue_dir)

    job_file = File.join(queue_dir, "#{job_data[:job_id]}.job.json")
    File.write(job_file, JSON.pretty_generate(job_data))

    log_operation('job_submit', 'COMPLETE', "Job: #{job_data[:job_id]}, Op: #{job_data[:op]} (file)")
    true
  rescue => e
    log_operation('job_submit', 'ERROR', "Failed: #{e.message}")
    false
  end

  # ============================================================================
  # ROUTES
  # ============================================================================

  # Health check endpoint (public)
  get '/health' do
    health_data = {
      status: 'healthy',
      timestamp: Time.now.utc.iso8601,
      sirius_time: sirius_time(),
      redis: RedisCache.redis_available? ? RedisCache.redis_health_check : { status: 'unavailable' },
      queue_depth: RedisCache.redis_available? ? RedisCache.queue_length('jobs') : 0,
      version: settings.capsule_info[:version]
    }

    content_type :json
    JSON.generate(health_data)
  end

  # Version info endpoint (public)
  get '/version' do
    content_type :json
    JSON.generate(settings.capsule_info)
  end

  # Job discovery endpoint (protected)
  get '/v1/jobs' do
    # Return list of recent jobs (simplified)
    jobs = []
    if RedisCache.redis_available?
      # Get last 10 jobs from queue
      queued_jobs = RedisCache.queue_peek('jobs', 10)
      jobs = queued_jobs.map do |job|
        {
          job_id: job['job_id'],
          status: job['status'] || 'queued',
          op: job['op'],
          submitted_at: job['submitted_at']
        }
      end
    end

    json({
      jobs: jobs,
      count: jobs.length,
      redis_available: RedisCache.redis_available?
    })
  end

  # Job submission endpoint (protected)
  post '/v1/jobs' do
    begin
      request_body = request.body.read
      job_data = JSON.parse(request_body)

      # Validate input
      validation_errors = validate_job_data(job_data)
      unless validation_errors.empty?
        status 400
        json({ error: 'Validation failed', details: validation_errors })
      end

      # Generate job ID and metadata
      job_id = generate_job_id
      submitted_at = Time.now.utc.iso8601

      job_record = {
        job_id: job_id,
        op: job_data['op'],
        inputs: job_data['inputs'],
        params: job_data['params'] || {},
        route: job_data['route'] || 'default',
        submitted_at: submitted_at,
        status: 'queued'
      }

      # Submit to queue
      if submit_job_to_queue(job_record)
        status 201
        json({
          job_id: job_id,
          status: 'queued',
          submitted_at: submitted_at,
          message: 'Job submitted successfully'
        })
      else
        status 500
        json({ error: 'Failed to submit job' })
      end

    rescue JSON::ParserError => e
      status 400
      json({ error: 'Invalid JSON', details: e.message })
    rescue => e
      log_operation('api_error', 'ERROR', "Job submission failed: #{e.message}")
      status 500
      json({ error: 'Internal server error' })
    end
  end

  # Job status endpoint (protected)
  get '/v1/jobs/:job_id' do
    job_id = params[:job_id]

    # Look for job in Redis
    job_status = nil
    if RedisCache.redis_available?
      # Check receipts first (completed jobs)
      receipt = RedisCache.get_receipt(job_id)
      if receipt
        job_status = {
          job_id: job_id,
          status: receipt['status'] || 'completed',
          started_at: receipt['timestamp'],
          completed_at: receipt['completed_at'],
          result: receipt['result']
        }
      else
        # Check queue for pending jobs
        queued_jobs = RedisCache.queue_peek('jobs', 50)
        queued_job = queued_jobs.find { |j| j['job_id'] == job_id }
        if queued_job
          job_status = {
            job_id: job_id,
            status: 'queued',
            submitted_at: queued_job['submitted_at'],
            queue_position: queued_jobs.index(queued_job) + 1
          }
        end
      end
    end

    # Fallback: check file-based queue and receipts
    if job_status.nil?
      queue_file = File.join(get_vec3_root, 'var', 'queue', "#{job_id}.job.json")
      receipt_file = Dir.glob(File.join(get_vec3_root, 'var', 'receipts', '**', "#{job_id}.receipt.json")).first

      if receipt_file && File.exist?(receipt_file)
        receipt_data = JSON.parse(File.read(receipt_file))
        job_status = {
          job_id: job_id,
          status: receipt_data['status'] || 'completed',
          started_at: receipt_data['timestamp'],
          completed_at: receipt_data['completed_at'],
          result: receipt_data['result']
        }
      elsif File.exist?(queue_file)
        queue_data = JSON.parse(File.read(queue_file))
        job_status = {
          job_id: job_id,
          status: 'queued',
          submitted_at: queue_data['submitted_at']
        }
      end
    end

    if job_status
      content_type :json
      JSON.generate(job_status)
    else
      status 404
      json({ error: 'Job not found', job_id: job_id })
    end
  end

  # Job receipt endpoint (protected)
  get '/v1/jobs/:job_id/receipt' do
    job_id = params[:job_id]

    # Look for receipt in Redis first
    receipt = nil
    if RedisCache.redis_available?
      receipt = RedisCache.get_receipt(job_id)
    end

    # Fallback to file-based receipts
    if receipt.nil?
      receipt_files = Dir.glob(File.join(get_vec3_root, 'var', 'receipts', '**', "#{job_id}.receipt.json"))
      if receipt_files.any?
        receipt_file = receipt_files.first
        receipt = JSON.parse(File.read(receipt_file))
      end
    end

    if receipt
      content_type :json
      JSON.generate(receipt)
    else
      status 404
      json({ error: 'Receipt not found', job_id: job_id })
    end
  end

  # ============================================================================
  # ERROR HANDLING
  # ============================================================================

  error 400 do
    json({ error: 'Bad Request', message: env['sinatra.error'].message })
  end

  error 401 do
    json({ error: 'Unauthorized', message: 'Authentication required' })
  end

  error 403 do
    json({ error: 'Forbidden', message: 'Invalid credentials' })
  end

  error 404 do
    json({ error: 'Not Found', message: 'Endpoint not found' })
  end

  error 500 do
    json({ error: 'Internal Server Error', message: 'Something went wrong' })
  end

  error do
    json({ error: 'Server Error', message: env['sinatra.error'].message })
  end
end

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __FILE__ == $0
  puts "▛▞// Starting CMD.BRIDGE REST API Server on port 7777"
  puts "▛▞// Sirius time: #{CMDRestAPI.new.sirius_time()}"
  puts "▛▞// Health check: http://127.0.0.1:7777/health"
  puts "▛▞// Console UI: Open console.html in browser"

  # Log startup
  Helpers.log_operation('api_start', 'COMPLETE', 'REST API server starting on :7777')

  # Start server
  CMDRestAPI.run!
end

# :: ∎