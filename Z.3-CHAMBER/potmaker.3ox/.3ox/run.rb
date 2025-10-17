///▙▖▙▖▞▞▙ RUN.RB - POT RUNTIME ▙▖▙▖▞▞▙///

require "json"

module Pot
  class Rim
    def initialize(sectors: 360) @sectors = sectors; @tick = 0 end
    def pulse() @tick += 1 end
  end

  class Router
    def initialize(hubs: 64) @hubs = hubs end
    def plan(priority) priority > 200 ? [1,3,5,8] : [2,4,6,9] end
  end

  class Cores
    def tokenize(bytes) bytes.each_with_index.map { |b,i| [i, b.to_i] } end
    def evaluate(tokens, gain) tokens.map { |i,v| [i, v * gain] } end
    def reduce(tokens) tokens.map { |_,v| v }.inject(0){|a,x| a + x } end
  end

  class Storage
    def select_tier(priority) priority > 200 ? "Hot" : (priority > 100 ? "Warm" : "Cold") end
    def ingest(frame_sum, tier) { id: "#{tier}-#{Time.now.to_i}-#{frame_sum}" } end
  end

  class Seal
    def initialize() @n = 0 end
    def sign(ref) @n += 1; "rcpt-#{@n}-#{ref}" end
  end

  class Power
    def rails() { v_bus: 12.0, v_logic: 3.3 } end
  end

  class Kernel
    def infer(obs) { key: "autoscale.gain", expr: "gain=#{[1,(obs[:ecc_rate]*1000).to_i].max}" } end
  end

  class IO
    def detect(bytes) bytes end
  end

  class Runtime
    def initialize
      @rim = Rim.new
      @router = Router.new
      @cores = Cores.new
      @storage = Storage.new
      @seal = Seal.new
      @power = Power.new
      @kernel = Kernel.new
      @gain = 1
    end

    def session(input_bytes)
      tick = @rim.pulse
      rails = @power.rails
      ecc_rate = 0.003
      obs = { rail_voltage: rails[:v_bus], rim_tick: tick, load_avg: 0.42, ecc_rate: ecc_rate }
      rule = @kernel.infer(obs)
      @gain = rule[:expr].split("=").last.to_i if rule[:key] == "autoscale.gain"

      tokens = @cores.tokenize(input_bytes)
      evald = @cores.evaluate(tokens, @gain)
      sum = @cores.reduce(evald)
      prio = (sum.abs % 255)
      path = @router.plan(prio)
      tier = @storage.select_tier(prio)
      amphora = @storage.ingest(sum, tier)
      receipt = @seal.sign(amphora[:id])

      { tick: tick, path: path, tier: tier, receipt: receipt, gain: @gain }
    end
  end
end

# Example CLI hook
if __FILE__ == $0
  rt = Pot::Runtime.new
  bytes = ARGV.first ? ARGV.first.bytes : [1,2,3,4,5]
  puts JSON.pretty_generate(rt.session(bytes))
end

