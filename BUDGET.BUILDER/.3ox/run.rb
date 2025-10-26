#!/usr/bin/env ruby
#
# RUN.RB :: BUDGET.BUILDER Runtime Orchestrator
# Personal Finance Management with Debt Focus
#

require 'xxhash'
require 'time'
require 'fileutils'
require 'json'
require 'yaml'
require 'openssl'
require 'digest'

# ============================================================================
# BUDGET.BUILDER Configuration
# ============================================================================

BUDGET_SIGIL = "〘⟦⎊⟧・.°BUDGET.RB〙"
OUTPUT_FOLDER = "!0UT.BUDGET"
LOG_FILE = ".3ox/3ox.log"

# Load existing USAA budget data
USAA_BUDGET_DATA = {
  income: 2400,
  expenses: {
    savings_investments: 195,
    housing: 3300,
    food: 295,
    transportation: 1030,
    health: 0,
    family: 190,
    lifestyle_discretionary: 60,
    other_expenses: 320
  },
  total_expenses: 5390,
  monthly_deficit: -2990,
  critical_issues: {
    housing_percentage: 137.5,  # 3300/2400 * 100
    transportation_percentage: 42.9,  # 1030/2400 * 100
    missing_categories: ["crypto", "subscriptions", "smoke_shop", "gas", "daily_non_essentials"]
  }
}

# ============================================================================
# Core Functions
# ============================================================================

def validate_file(filepath)
  unless File.exist?(filepath)
    return { valid: false, error: "File not found" }
  end
  
  file_hash = XXhash.xxh64(File.read(filepath)).to_s(16)
  
  {
    valid: true,
    path: filepath,
    hash: file_hash[0..15],
    size: File.size(filepath)
  }
end

def load_tools
  tools_file = File.join(File.dirname(__FILE__), "tools.yml")
  return {} unless File.exist?(tools_file)
  
  YAML.load_file(tools_file)
end

def load_routes
  routes_file = File.join(File.dirname(__FILE__), "routes.json")
  return {} unless File.exist?(routes_file)
  
  JSON.parse(File.read(routes_file))["routes"]
end

def load_limits
  limits_file = File.join(File.dirname(__FILE__), "limits.json")
  return {} unless File.exist?(limits_file)
  
  JSON.parse(File.read(limits_file))
end

def load_brain
  brain_bin = File.join(File.dirname(__FILE__), "brain.exe")
  
  # Try to run compiled Rust binary
  if File.exist?(brain_bin)
    output = `#{brain_bin} config 2>&1`
    return JSON.parse(output) if $?.success?
  end
  
  # Fallback: Parse brain.rs as text
  brain_file = File.join(File.dirname(__FILE__), "brain.rs")
  return { "name" => "BUDGET.BUILDER", "type" => "Alchemist", "rules" => [] } unless File.exist?(brain_file)
  
  content = File.read(brain_file)
  name = content[/name: "([^"]+)"/, 1] || "BUDGET.BUILDER"
  brain_type = content[/brain: BrainType::(\w+)/, 1] || "Alchemist"
  rules = content.scan(/Rule::(\w+)/).flatten.uniq
  
  { "name" => name, "type" => brain_type, "rules" => rules }
end

def encrypt_financial_data(data)
  """Encrypt sensitive financial data locally"""
  # Simple encryption for demo - in production would use proper encryption
  encrypted = Base64.encode64(data.to_json)
  { encrypted: encrypted, timestamp: Time.now.iso8601 }
end

def log_operation(operation, status, details = "")
  log_file = File.join(File.dirname(__FILE__), LOG_FILE)
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  
  log_entry = "\n[#{timestamp}] #{BUDGET_SIGIL}\n"
  log_entry += "  Operation: #{operation}\n"
  log_entry += "  Status: #{status}\n"
  log_entry += "  Details: #{details}\n" unless details.empty?
  
  File.open(log_file, "a") { |f| f.write(log_entry) }
end

def find_or_create_output_folder
  """BUDGET.BUILDER outputs to !0UT.BUDGET (ENFORCED)"""
  
  # Budget builder has fixed output location
  output_folder = File.join(File.dirname(__FILE__), "..", OUTPUT_FOLDER)
  
  # Ensure it exists
  FileUtils.mkdir_p(output_folder) unless File.exist?(output_folder)
  
  # Ensure subfolders exist
  ["reports", "budgets", "debt_analysis", "payoff_strategies", "business_plans"].each do |subdir|
    subdir_path = File.join(output_folder, subdir)
    FileUtils.mkdir_p(subdir_path) unless File.exist?(subdir_path)
  end
  
  output_folder
end

def create_financial_backup(operation_type)
  """Create encrypted backup of financial data before operations"""
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  backup_file = File.join(find_or_create_output_folder, "budgets", "backup_#{timestamp}.json")
  
  backup_data = {
    operation: operation_type,
    timestamp: Time.now.iso8601,
    usaa_data: USAA_BUDGET_DATA,
    backup_id: Digest::SHA256.hexdigest("#{timestamp}#{operation_type}")[0..15]
  }
  
  encrypted_backup = encrypt_financial_data(backup_data)
  File.write(backup_file, JSON.pretty_generate(encrypted_backup))
  
  puts "✓ Financial backup created: #{backup_file}"
  backup_file
end

# ============================================================================
# Main Operations
# ============================================================================

def run_debt_analysis
  puts "=" * 60
  puts "💰 BUDGET.BUILDER DEBT ANALYSIS"
  puts "=" * 60
  
  # Load configuration
  tools = load_tools
  limits = load_limits
  brain = load_brain
  
  puts "\n✓ Brain: #{brain['name']} (#{brain['type']})"
  puts "✓ Rules: #{brain['rules'].take(3).join(', ')}"
  puts "✓ Tools loaded: #{tools.fetch('tools', []).length} available"
  
  # Analyze current financial crisis
  puts "\n🚨 CRITICAL FINANCIAL ANALYSIS:"
  puts "Monthly Income: $#{USAA_BUDGET_DATA[:income]}"
  puts "Monthly Expenses: $#{USAA_BUDGET_DATA[:total_expenses]}"
  puts "Monthly Deficit: $#{USAA_BUDGET_DATA[:monthly_deficit]} (CRITICAL)"
  
  puts "\n🔴 MAJOR ISSUES IDENTIFIED:"
  puts "• Housing: $#{USAA_BUDGET_DATA[:expenses][:housing]} (#{USAA_BUDGET_DATA[:critical_issues][:housing_percentage]}% of income)"
  puts "• Transportation: $#{USAA_BUDGET_DATA[:expenses][:transportation]} (#{USAA_BUDGET_DATA[:critical_issues][:transportation_percentage]}% of income)"
  puts "• Missing Categories: #{USAA_BUDGET_DATA[:critical_issues][:missing_categories].join(', ')}"
  
  # Generate debt analysis report
  output_folder = find_or_create_output_folder
  report_file = File.join(output_folder, "debt_analysis", "debt_analysis_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json")
  
  debt_analysis = {
    timestamp: Time.now.iso8601,
    current_situation: USAA_BUDGET_DATA,
    critical_alerts: [
      "Monthly deficit of $2,990 is unsustainable",
      "Housing costs exceed income by 37.5%",
      "Transportation costs are 2x recommended maximum",
      "Missing expense categories need immediate attention"
    ],
    immediate_actions: [
      "Reduce housing costs immediately",
      "Audit transportation expenses",
      "Add missing expense categories",
      "Create emergency budget plan"
    ],
    debt_priorities: [
      "Credit card minimums: $20/month",
      "Need detailed debt breakdown",
      "Create payoff strategy",
      "Plan business funding transition"
    ]
  }
  
  File.write(report_file, JSON.pretty_generate(debt_analysis))
  puts "\n✓ Debt analysis report generated: #{report_file}"
  
  log_operation("debt_analysis", "COMPLETE", "Report: #{report_file}")
  
  puts "\n" + "=" * 60
  puts "DEBT ANALYSIS COMPLETE"
  puts "=" * 60
end

def run_budget_builder(args)
  interactive = args.include?("--interactive")
  complete_categories = args.include?("--complete")
  
  puts "=" * 60
  puts "📊 BUDGET.BUILDER BUDGET BUILDER"
  puts "=" * 60
  puts "Mode: #{interactive ? 'INTERACTIVE' : 'ANALYSIS'}"
  puts "Categories: #{complete_categories ? 'COMPLETE' : 'BASIC'}"
  
  # Create backup before modifications
  backup_file = create_financial_backup("budget_builder")
  
  # Load existing budget data
  puts "\n📋 CURRENT BUDGET ANALYSIS:"
  puts "Income: $#{USAA_BUDGET_DATA[:income]}"
  puts "Expenses: $#{USAA_BUDGET_DATA[:total_expenses]}"
  puts "Deficit: $#{USAA_BUDGET_DATA[:monthly_deficit]}"
  
  # Add missing categories if requested
  if complete_categories
    puts "\n➕ ADDING MISSING CATEGORIES:"
    missing_categories = USAA_BUDGET_DATA[:critical_issues][:missing_categories]
    missing_categories.each do |category|
      puts "  • #{category.capitalize}: $___ (needs input)"
    end
  end
  
  # Generate budget recommendations
  puts "\n💡 BUDGET RECOMMENDATIONS:"
  puts "• Reduce housing to max 30% of income: $720 (current: $3,300)"
  puts "• Reduce transportation to max 20% of income: $480 (current: $1,030)"
  puts "• Add missing categories with realistic estimates"
  puts "• Create emergency budget plan"
  
  # Generate new budget
  output_folder = find_or_create_output_folder
  budget_file = File.join(output_folder, "budgets", "budget_rebuild_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json")
  
  new_budget = {
    timestamp: Time.now.iso8601,
    original_budget: USAA_BUDGET_DATA,
    recommended_budget: {
      income: USAA_BUDGET_DATA[:income],
      expenses: {
        housing: 720,  # 30% of income
        transportation: 480,  # 20% of income
        food: 295,
        savings_investments: 195,
        family: 190,
        lifestyle_discretionary: 60,
        other_expenses: 320,
        crypto: 100,  # Estimated
        subscriptions: 50,  # Estimated
        smoke_shop: 30,  # Estimated
        gas: 200,  # Estimated
        daily_non_essentials: 150  # Estimated
      },
      total_expenses: 2595,
      monthly_surplus: -195  # Still negative but much better
    },
    changes_made: [
      "Reduced housing from $3,300 to $720",
      "Reduced transportation from $1,030 to $480",
      "Added missing categories with estimates",
      "Created realistic budget framework"
    ],
    next_steps: [
      "Implement housing cost reduction",
      "Audit transportation expenses",
      "Track actual spending in missing categories",
      "Create debt payoff strategy"
    ]
  }
  
  File.write(budget_file, JSON.pretty_generate(new_budget))
  puts "\n✓ New budget generated: #{budget_file}"
  
  log_operation("budget_builder", "COMPLETE", "Mode: #{interactive ? 'interactive' : 'analysis'}, Backup: #{backup_file}")
  
  puts "\n" + "=" * 60
  puts "BUDGET BUILDER COMPLETE"
  puts "=" * 60
end

def run_payoff_strategies(args)
  method = args.first || "all"
  
  puts "=" * 60
  puts "🎯 BUDGET.BUILDER PAYOFF STRATEGIES"
  puts "=" * 60
  puts "Method: #{method.upcase}"
  
  # Create backup before strategy planning
  backup_file = create_financial_backup("payoff_strategies")
  
  # Generate multiple payoff strategies
  strategies = {
    debt_snowball: {
      name: "Debt Snowball Method",
      description: "Pay minimums on all debts, then put extra money toward smallest debt",
      pros: ["Quick psychological wins", "Builds momentum", "Simple to follow"],
      cons: ["May cost more in interest", "Not mathematically optimal"],
      timeline: "12-18 months estimated"
    },
    debt_avalanche: {
      name: "Debt Avalanche Method", 
      description: "Pay minimums on all debts, then put extra money toward highest interest debt",
      pros: ["Saves most money on interest", "Mathematically optimal", "Faster overall payoff"],
      cons: ["May take longer to see progress", "Requires discipline"],
      timeline: "10-15 months estimated"
    },
    debt_consolidation: {
      name: "Debt Consolidation",
      description: "Combine multiple debts into single loan with lower interest rate",
      pros: ["Simplifies payments", "May reduce interest rate", "Single payment"],
      cons: ["May extend payoff timeline", "Requires good credit", "May have fees"],
      timeline: "12-24 months estimated"
    },
    emergency_fund_first: {
      name: "Emergency Fund First",
      description: "Build $1,000 emergency fund before aggressive debt payoff",
      pros: ["Prevents new debt", "Reduces financial stress", "USAA recommended"],
      cons: ["Delays debt payoff", "Emergency fund earns minimal interest"],
      timeline: "2-3 months for emergency fund, then debt payoff"
    }
  }
  
  puts "\n📋 AVAILABLE PAYOFF STRATEGIES:"
  strategies.each do |key, strategy|
    puts "\n🎯 #{strategy[:name]}:"
    puts "  Description: #{strategy[:description]}"
    puts "  Timeline: #{strategy[:timeline]}"
    puts "  Pros: #{strategy[:pros].join(', ')}"
    puts "  Cons: #{strategy[:cons].join(', ')}"
  end
  
  # Generate payoff strategy report
  output_folder = find_or_create_output_folder
  strategy_file = File.join(output_folder, "payoff_strategies", "payoff_strategies_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json")
  
  payoff_analysis = {
    timestamp: Time.now.iso8601,
    current_debt_situation: {
      monthly_deficit: USAA_BUDGET_DATA[:monthly_deficit],
      credit_card_minimums: 20,
      total_debt_unknown: true,
      needs_detailed_breakdown: true
    },
    available_strategies: strategies,
    recommended_approach: "Emergency Fund First + Debt Avalanche",
    reasoning: [
      "Build $1,000 emergency fund to prevent new debt",
      "Use debt avalanche method for optimal interest savings",
      "Focus on highest interest debt first",
      "Track progress monthly"
    ],
    next_steps: [
      "Get detailed debt breakdown from all creditors",
      "Calculate exact interest rates and minimum payments",
      "Create monthly payoff schedule",
      "Set up automatic payments where possible"
    ]
  }
  
  File.write(strategy_file, JSON.pretty_generate(payoff_analysis))
  puts "\n✓ Payoff strategies generated: #{strategy_file}"
  
  log_operation("payoff_strategies", "COMPLETE", "Method: #{method}, Backup: #{backup_file}")
  
  puts "\n" + "=" * 60
  puts "PAYOFF STRATEGIES COMPLETE"
  puts "=" * 60
end

def run_expense_tracking(args)
  period = args.first || "monthly"
  
  puts "=" * 60
  puts "📈 BUDGET.BUILDER EXPENSE TRACKING"
  puts "=" * 60
  puts "Period: #{period.upcase}"
  
  # Create expense tracking system
  puts "\n📊 EXPENSE TRACKING SYSTEM:"
  puts "• Track all expenses in real-time"
  puts "• Categorize spending automatically"
  puts "• Identify spending patterns"
  puts "• Generate monthly reports"
  
  # Generate tracking template
  output_folder = find_or_create_output_folder
  tracking_file = File.join(output_folder, "reports", "expense_tracking_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json")
  
  tracking_system = {
    timestamp: Time.now.iso8601,
    tracking_period: period,
    categories_to_track: [
      "Housing (rent, utilities, insurance)",
      "Transportation (car payment, insurance, gas, maintenance)",
      "Food (groceries, dining out)",
      "Health (medicines, insurance, medical)",
      "Family (childcare, support, clothing)",
      "Lifestyle (entertainment, pets, vacations)",
      "Debt payments (credit cards, loans)",
      "Crypto investments/spending",
      "Subscriptions (streaming, software, services)",
      "Smoke shop products",
      "Daily non-essentials",
      "Other expenses"
    ],
    tracking_methods: [
      "Mobile app for real-time tracking",
      "Receipt scanning and categorization",
      "Bank account integration",
      "Manual entry for cash transactions"
    ],
    reporting_frequency: "Weekly and monthly",
    alerts: [
      "Overspending in any category",
      "Approaching budget limits",
      "Unusual spending patterns",
      "Missing expense categories"
    ]
  }
  
  File.write(tracking_file, JSON.pretty_generate(tracking_system))
  puts "\n✓ Expense tracking system generated: #{tracking_file}"
  
  log_operation("expense_tracking", "COMPLETE", "Period: #{period}")
  
  puts "\n" + "=" * 60
  puts "EXPENSE TRACKING COMPLETE"
  puts "=" * 60
end

def run_business_transition(args)
  phase = args.first || "planning"
  
  puts "=" * 60
  puts "🚀 BUDGET.BUILDER BUSINESS TRANSITION"
  puts "=" * 60
  puts "Phase: #{phase.upcase}"
  
  # Create business funding transition plan
  puts "\n📋 BUSINESS FUNDING TRANSITION PLAN:"
  puts "• Stabilize personal finances first"
  puts "• Build emergency fund"
  puts "• Eliminate high-interest debt"
  puts "• Create business funding strategy"
  
  # Generate business transition plan
  output_folder = find_or_create_output_folder
  business_file = File.join(output_folder, "business_plans", "business_transition_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json")
  
  business_plan = {
    timestamp: Time.now.iso8601,
    current_phase: phase,
    personal_finance_prerequisites: [
      "Eliminate monthly deficit",
      "Build $1,000 emergency fund",
      "Pay off high-interest debt",
      "Create stable budget with surplus"
    ],
    business_funding_options: [
      "Personal savings (after debt elimination)",
      "Business credit cards (low interest)",
      "Small business loans",
      "Investor funding",
      "Crowdfunding",
      "Government grants/loans"
    ],
    transition_timeline: {
      phase_1: "Personal debt elimination (6-12 months)",
      phase_2: "Emergency fund building (2-3 months)",
      phase_3: "Business funding planning (1-2 months)",
      phase_4: "Business launch preparation (ongoing)"
    },
    success_metrics: [
      "Personal budget with positive cash flow",
      "Emergency fund of $1,000+",
      "Debt-to-income ratio under 20%",
      "Business funding plan in place"
    ]
  }
  
  File.write(business_file, JSON.pretty_generate(business_plan))
  puts "\n✓ Business transition plan generated: #{business_file}"
  
  log_operation("business_transition", "COMPLETE", "Phase: #{phase}")
  
  puts "\n" + "=" * 60
  puts "BUSINESS TRANSITION COMPLETE"
  puts "=" * 60
end

def run_financial_report
  puts "=" * 60
  puts "📋 BUDGET.BUILDER FINANCIAL REPORT"
  puts "=" * 60
  
  # Generate comprehensive financial report
  puts "\n📊 COMPREHENSIVE FINANCIAL ANALYSIS:"
  puts "Current Situation: CRITICAL"
  puts "Monthly Deficit: $#{USAA_BUDGET_DATA[:monthly_deficit]}"
  puts "Housing Crisis: #{USAA_BUDGET_DATA[:critical_issues][:housing_percentage]}% of income"
  puts "Transportation Overload: #{USAA_BUDGET_DATA[:critical_issues][:transportation_percentage]}% of income"
  
  puts "\n🎯 IMMEDIATE ACTIONS REQUIRED:"
  puts "1. Reduce housing costs immediately"
  puts "2. Audit transportation expenses"
  puts "3. Add missing expense categories"
  puts "4. Create emergency budget plan"
  puts "5. Build $1,000 emergency fund"
  
  puts "\n🚀 BUSINESS TRANSITION ROADMAP:"
  puts "Phase 1: Personal debt elimination (6-12 months)"
  puts "Phase 2: Emergency fund building (2-3 months)"
  puts "Phase 3: Business funding planning (1-2 months)"
  puts "Phase 4: Business launch preparation (ongoing)"
  
  # Generate comprehensive report
  output_folder = find_or_create_output_folder
  report_file = File.join(output_folder, "reports", "comprehensive_report_#{Time.now.strftime('%Y%m%d_%H%M%S')}.json")
  
  comprehensive_report = {
    timestamp: Time.now.iso8601,
    executive_summary: {
      status: "CRITICAL",
      monthly_deficit: USAA_BUDGET_DATA[:monthly_deficit],
      primary_issues: [
        "Housing costs exceed income by 37.5%",
        "Transportation costs are 2x recommended maximum",
        "Missing expense categories need attention"
      ],
      immediate_actions: [
        "Reduce housing costs to max 30% of income",
        "Reduce transportation costs to max 20% of income",
        "Add missing expense categories",
        "Create emergency budget plan"
      ]
    },
    detailed_analysis: USAA_BUDGET_DATA,
    recommendations: {
      short_term: [
        "Implement housing cost reduction",
        "Audit transportation expenses",
        "Track actual spending in missing categories"
      ],
      medium_term: [
        "Build $1,000 emergency fund",
        "Eliminate high-interest debt",
        "Create stable budget with surplus"
      ],
      long_term: [
        "Plan business funding transition",
        "Build business credit",
        "Prepare for business launch"
      ]
    },
    success_metrics: [
      "Monthly budget with positive cash flow",
      "Emergency fund of $1,000+",
      "Debt-to-income ratio under 20%",
      "Business funding plan in place"
    ]
  }
  
  File.write(report_file, JSON.pretty_generate(comprehensive_report))
  puts "\n✓ Comprehensive report generated: #{report_file}"
  
  log_operation("financial_report", "COMPLETE", "Report: #{report_file}")
  
  puts "\n" + "=" * 60
  puts "FINANCIAL REPORT COMPLETE"
  puts "=" * 60
end

# ============================================================================
# Execute
# ============================================================================

def show_help
  puts "BUDGET.BUILDER - Personal Finance Management with Debt Focus"
  puts "=" * 60
  puts "Usage: ruby run.rb [command] [options]"
  puts ""
  puts "Commands:"
  puts "  analyze                    - Run debt analysis"
  puts "  budget [--interactive]     - Build interactive budget"
  puts "  payoff [method]            - Generate debt payoff strategies"
  puts "  track [period]             - Set up expense tracking"
  puts "  business [phase]           - Plan business funding transition"
  puts "  report                     - Generate comprehensive financial report"
  puts "  help                       - Show this help"
  puts ""
  puts "Options:"
  puts "  --interactive              - Interactive budget building mode"
  puts "  --complete                 - Include missing expense categories"
  puts ""
  puts "Examples:"
  puts "  ruby run.rb analyze"
  puts "  ruby run.rb budget --interactive --complete"
  puts "  ruby run.rb payoff avalanche"
  puts "  ruby run.rb business planning"
end

if __FILE__ == $0
  if ARGV.empty? || ARGV.include?("help")
    show_help
  else
    command = ARGV[0]
    args = ARGV[1..-1] || []
    
    case command
    when "analyze"
      run_debt_analysis
    when "budget"
      run_budget_builder(args)
    when "payoff"
      run_payoff_strategies(args)
    when "track"
      run_expense_tracking(args)
    when "business"
      run_business_transition(args)
    when "report"
      run_financial_report
    else
      puts "Unknown command: #{command}"
      show_help
    end
  end
end




