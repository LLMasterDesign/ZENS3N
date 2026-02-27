#!/usr/bin/env ruby
# Deprecated shim; use receipt_contract_reconcile.rb.

require 'json'

target = File.join(__dir__, 'receipt_contract_reconcile.rb')
unless File.file?(target)
  puts JSON.pretty_generate({ error: "Missing target script: #{target}" })
  exit 1
end

warn '[deprecated] sync_meta_from_pulse.rb -> receipt_contract_reconcile.rb'
exec('ruby', target, *ARGV)
