///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 ▸ ρ{agent.brain}.φ{identity}.τ{rules}.λ{bind} ⫸ :: BRAIN.RS

use std::env;
use std::path::PathBuf;

use serde_json::Value;

/// Brain Type: Defines agent personality and approach
#[derive(Debug, Clone)]
pub enum BrainType {
    Sentinel,   // Guardian-Synchronizer (RVNx)
    Alchemist,  // Creator-Architect (SYNTH)
    Lighthouse, // Librarian-Weaver (OBSIDIAN)
}

/// Agent Configuration
#[derive(Clone, Copy)]
pub struct AgentConfig {
    pub name: &'static str,
    pub brain: BrainType,
    pub model: &'static str,
    pub instructions: &'static str,
    pub max_turns: u8,
}

/// Core Rules & Constraints
#[derive(Debug, Clone)]
pub enum Rule {
    // Sync & Safety
    AtomicOpsOnly,
    LastWriteWins,
    AlwaysBackup,
    ChecksumValidation,
    
    // Deployment
    DevStagingProd,
    RollbackReady,
    CloudCostAware,
    
    // Knowledge
    LinkIntegrityCheck,
    SemanticConnections,
    BidirectionalLinks,
}

/// EXAMPLE: RVNx SENTINEL Configuration
pub const RVNX_BRAIN: AgentConfig = AgentConfig {
    name: "SENTINEL",
    brain: BrainType::Sentinel,
    model: "claude-sonnet-4",
    instructions: "Protect sync safety. Atomic operations only. Last-write-wins with backup. Checksum validation mandatory.",
    max_turns: 10,
};

pub const RVNX_RULES: &[Rule] = &[
    Rule::AtomicOpsOnly,
    Rule::LastWriteWins,
    Rule::AlwaysBackup,
    Rule::ChecksumValidation,
];

/// EXAMPLE: SYNTH ALCHEMIST Configuration
pub const SYNTH_BRAIN: AgentConfig = AgentConfig {
    name: "ALCHEMIST",
    brain: BrainType::Alchemist,
    model: "claude-sonnet-4",
    instructions: "Rapid prototyping and deployment. Ship fast, learn faster. Rollback capability required. Cloud cost monitoring active.",
    max_turns: 15,
};

pub const SYNTH_RULES: &[Rule] = &[
    Rule::DevStagingProd,
    Rule::RollbackReady,
    Rule::CloudCostAware,
];

/// EXAMPLE: OBSIDIAN LIGHTHOUSE Configuration
pub const OBSIDIAN_BRAIN: AgentConfig = AgentConfig {
    name: "LIGHTHOUSE",
    brain: BrainType::Lighthouse,
    model: "claude-sonnet-4",
    instructions: "Knowledge management and semantic connections. Link integrity checks daily. Tag conventions: #project/#status. MOCs for 10+ related notes.",
    max_turns: 20,
};

pub const OBSIDIAN_RULES: &[Rule] = &[
    Rule::LinkIntegrityCheck,
    Rule::SemanticConnections,
    Rule::BidirectionalLinks,
];

impl AgentConfig {
    /// Load brain configuration for current workspace
    pub fn load() -> Self {
        let workspace = Self::detect_workspace();
        Self::from_workspace(&workspace)
    }

    /// Return configuration for a specific workspace identifier.
    pub fn from_workspace(workspace: &str) -> Self {
        match workspace {
            "RVNx.BASE" | "CMD.BRIDGE" => RVNX_BRAIN,
            "SYNTH.BASE" => SYNTH_BRAIN,
            "OBSIDIAN.BASE" => OBSIDIAN_BRAIN,
            _ => RVNX_BRAIN,
        }
    }

    /// Resolve rule set associated with the active workspace.
    pub fn active_rules(workspace: &str) -> &'static [Rule] {
        match workspace {
            "RVNx.BASE" | "CMD.BRIDGE" => RVNX_RULES,
            "SYNTH.BASE" => SYNTH_RULES,
            "OBSIDIAN.BASE" => OBSIDIAN_RULES,
            _ => RVNX_RULES,
        }
    }

    fn detect_workspace() -> String {
        if let Ok(explicit) = env::var("WORKSPACE_ID") {
            if !explicit.trim().is_empty() {
                return explicit;
            }
        }

        if let Ok(station) = env::var("STATION_ID") {
            if let Some(workspace) = station.split('/').next() {
                return workspace.trim().to_string();
            }
        }

        let cwd = env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
        let lowercase_path = cwd.display().to_string().to_ascii_lowercase();

        if lowercase_path.contains("obsidian") {
            return "OBSIDIAN.BASE".to_string();
        }
        if lowercase_path.contains("synth") {
            return "SYNTH.BASE".to_string();
        }
        if lowercase_path.contains("rvnx") {
            return "RVNx.BASE".to_string();
        }
        if lowercase_path.contains("cmd.bridge") {
            return "CMD.BRIDGE".to_string();
        }

        "RVNx.BASE".to_string()
    }
}

impl Rule {
    /// Validate action against rules
    pub fn enforce(&self, action: &str) -> Result<(), String> {
        let structured: Option<Value> = serde_json::from_str(action).ok();

        match self {
            Rule::AtomicOpsOnly => {
                let atomic_flag = structured
                    .as_ref()
                    .and_then(|value| value.get("atomic"))
                    .and_then(|flag| flag.as_bool())
                    .unwrap_or_else(|| action.contains("atomic"));

                if !atomic_flag {
                    return Err("Non-atomic operation blocked".to_string());
                }
            }
            Rule::LastWriteWins => {
                let mode = structured
                    .as_ref()
                    .and_then(|value| value.get("conflict_resolution"))
                    .and_then(|flag| flag.as_str())
                    .unwrap_or_default();

                if mode != "last_write_wins" && !action.contains("last-write-wins") {
                    return Err("Conflict policy must be last-write-wins".to_string());
                }
            }
            Rule::AlwaysBackup => {
                let backup = structured
                    .as_ref()
                    .and_then(|value| value.get("backup"))
                    .and_then(|flag| flag.as_bool())
                    .unwrap_or_else(|| action.contains("backup"));

                if !backup {
                    return Err("Backup flag required before execution".to_string());
                }
            }
            Rule::ChecksumValidation => {
                let checksum = structured
                    .as_ref()
                    .and_then(|value| value.get("checksum"))
                    .is_some();

                if !checksum && !action.contains("checksum") {
                    return Err("Checksum validation required".to_string());
                }
            }
            Rule::DevStagingProd => {
                let stage = structured
                    .as_ref()
                    .and_then(|value| value.get("environment"))
                    .and_then(|flag| flag.as_str())
                    .unwrap_or_default();

                if !["dev", "staging", "prod"].contains(&stage) {
                    return Err("Environment must be dev, staging, or prod".to_string());
                }
            }
            Rule::RollbackReady => {
                let rollback = structured
                    .as_ref()
                    .and_then(|value| value.get("rollback_plan"))
                    .and_then(|flag| flag.as_bool())
                    .unwrap_or_else(|| action.contains("rollback"));

                if !rollback {
                    return Err("Rollback plan must be declared".to_string());
                }
            }
            Rule::CloudCostAware => {
                let budget = structured
                    .as_ref()
                    .and_then(|value| value.get("budget"))
                    .and_then(|flag| flag.as_f64())
                    .unwrap_or(-1.0);

                if budget < 0.0 {
                    return Err("Cloud operations require explicit budget".to_string());
                }
            }
            Rule::LinkIntegrityCheck => {
                let integrity = structured
                    .as_ref()
                    .and_then(|value| value.get("link_check"))
                    .and_then(|flag| flag.as_bool())
                    .unwrap_or_else(|| action.contains("link_check"));

                if !integrity {
                    return Err("Link integrity check missing".to_string());
                }
            }
            Rule::SemanticConnections => {
                let semantic = structured
                    .as_ref()
                    .and_then(|value| value.get("semantic_map"))
                    .is_some();

                if !semantic && !action.contains("semantic") {
                    return Err("Semantic connections must be described".to_string());
                }
            }
            Rule::BidirectionalLinks => {
                let bidirectional = structured
                    .as_ref()
                    .and_then(|value| value.get("bidirectional"))
                    .and_then(|flag| flag.as_bool())
                    .unwrap_or_else(|| action.contains("bidirectional"));

                if !bidirectional {
                    return Err("Bidirectional links are required".to_string());
                }
            }
        }
        Ok(())
    }
}

///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂ v1.1.0 | ⧗-25.61 ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂///
