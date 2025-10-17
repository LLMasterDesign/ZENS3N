///▙▖▙▖▞▞▙ BRAIN.RS - POT CONSCIOUSNESS ▙▖▙▖▞▞▙///

use serde::{Deserialize, Serialize};

// ========= Shared data types =========
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Symbol(pub char);

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Token { pub id: u32, pub val: i32 }

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Frame { pub tokens: Vec<Token> }

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Braid { pub bytes: Vec<u8> }

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Observation {
    pub rail_voltage: f32,
    pub rim_tick: u64,
    pub load_avg: f32,
    pub ecc_rate: f32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Rule { pub key: String, pub expr: String }

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Input { pub name: String, pub payload: Vec<u8> }

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Decision {
    pub route: Vec<u32>,
    pub priority: u8,
    pub store_tier: String,
}

// ========= Components (minimal compile-time interfaces) =========
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct MetaRecursionKernel { pub version: u64, pub rules: Vec<Rule> }
impl MetaRecursionKernel {
    pub fn observe(&self, rail_voltage: f32, rim_tick: u64, load_avg: f32, ecc_rate: f32) -> Observation {
        Observation { rail_voltage, rim_tick, load_avg, ecc_rate }
    }
    pub fn infer(&self, obs: &Observation) -> Rule {
        let expr = format!("if rail>{} and ecc<{} then gain", obs.rail_voltage * 0.9, obs.ecc_rate * 1.1);
        Rule { key: "autoscale.gain".into(), expr }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ProcessingCoresRing { pub cores: u8 }
impl ProcessingCoresRing {
    pub fn tokenize(&self, braid: &Braid) -> Frame {
        let toks = braid.bytes.iter().enumerate()
            .map(|(i,b)| Token { id: i as u32, val: *b as i32 })
            .collect();
        Frame { tokens: toks }
    }
    pub fn evaluate(&self, frame: &mut Frame, gain: i32) {
        for t in &mut frame.tokens { t.val *= gain; }
    }
    pub fn reduce(&self, frame: &Frame) -> i64 {
        frame.tokens.iter().map(|t| t.val as i64).sum()
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct TextileAlgorithmsLayer { pub braid_depth: u8 }
impl TextileAlgorithmsLayer {
    // Sense → Align → Interleave → Braid → Commit
    pub fn align(&self, s: &[u8]) -> Vec<u8> { s.iter().map(|b| b ^ 0x5A).collect() }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct RoutingCircuitsLattice { pub hubs: u32 }
impl RoutingCircuitsLattice {
    // Admit → Queue → Route → Deliver → Ack
    pub fn plan(&self, priority: u8) -> Vec<u32> {
        if priority > 200 { vec![1,3,5,8] } else { vec![2,4,6,9] }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct StorageVesselsArray { pub hot: usize, pub warm: usize, pub cold: usize }
impl StorageVesselsArray {
    // Ingest → Seal → Age → Consolidate → Recall
    pub fn select_tier(&self, priority: u8) -> String {
        if priority > 200 { "Hot".into() } else if priority > 100 { "Warm".into() } else { "Cold".into() }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct SynchronizationRim { pub sectors: u16, pub tick: u64 }
impl SynchronizationRim {
    // Pulse → Phase estimate → Lock → Drift correct → Re lock
    pub fn pulse(&mut self) -> u64 { self.tick += 1; self.tick }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ErrorCorrectionGlaze { pub coats: u8 }
impl ErrorCorrectionGlaze {
    // Encode → Scatter → Sense → Correct → Verify
    pub fn correct_rate(&self) -> f32 { 0.001 * self.coats as f32 }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct CompressionSpiral { pub checkpoints: u8 }
impl CompressionSpiral {
    // Detect → Quantize → Pack → Emit
    pub fn pack(&self, bytes: &[u8]) -> Vec<u8> { bytes.iter().map(|b| b >> 1).collect() }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AddressWeave { pub tablets: u16 }
impl AddressWeave {
    // Name → Bind → Resolve → Route → Confirm
    pub fn resolve(&self, name: &str) -> u32 { (name.len() as u32 % 64) + 1 }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct IOApertures { pub ports: u8 }
impl IOApertures {
    // Detect → Demodulate → Validate → Dispatch / Produce → Modulate → Emit → Log
    pub fn detect(&self, raw: &[u8]) -> Braid { Braid { bytes: raw.to_vec() } }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct PowerBus { pub v_bus: f32, pub v_logic: f32 }
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct SecuritySeal { pub chain_len: u64 }
impl SecuritySeal { pub fn receipt(&mut self) -> String { self.chain_len += 1; format!("rcpt-{}", self.chain_len) } }

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct MemoryNodes { pub hex_nodes: u32 }

// ========= Brain =========
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PotBrain {
    pub kernel: MetaRecursionKernel,
    pub cores: ProcessingCoresRing,
    pub textile: TextileAlgorithmsLayer,
    pub router: RoutingCircuitsLattice,
    pub storage: StorageVesselsArray,
    pub rim: SynchronizationRim,
    pub glaze: ErrorCorrectionGlaze,
    pub spiral: CompressionSpiral,
    pub weave: AddressWeave,
    pub io: IOApertures,
    pub power: PowerBus,
    pub seal: SecuritySeal,
    pub memory: MemoryNodes,
}

impl Default for PotBrain {
    fn default() -> Self {
        PotBrain {
            kernel: MetaRecursionKernel::default(),
            cores: ProcessingCoresRing { cores: 12 },
            textile: TextileAlgorithmsLayer { braid_depth: 4 },
            router: RoutingCircuitsLattice { hubs: 64 },
            storage: StorageVesselsArray { hot: 32, warm: 64, cold: 128 },
            rim: SynchronizationRim { sectors: 360, tick: 0 },
            glaze: ErrorCorrectionGlaze { coats: 3 },
            spiral: CompressionSpiral { checkpoints: 8 },
            weave: AddressWeave { tablets: 120 },
            io: IOApertures { ports: 4 },
            power: PowerBus { v_bus: 12.0, v_logic: 3.3 },
            seal: SecuritySeal { chain_len: 0 },
            memory: MemoryNodes { hex_nodes: 4096 },
        }
    }
}

impl PotBrain {
    pub fn observe(&mut self) -> Observation {
        let tick = self.rim.pulse();
        let ecc = self.glaze.correct_rate();
        self.kernel.observe(self.power.v_bus, tick, 0.42, ecc)
    }

    pub fn infer(&mut self, obs: Observation) -> Rule {
        let rule = self.kernel.infer(&obs);
        // Kernel learns: persist simple rule
        self.kernel.rules.push(rule.clone());
        rule
    }

    pub fn decide(&self, input: Input) -> Decision {
        // Pipeline: IO detect → textile align → spiral pack → route plan → storage tier
        let braid = self.io.detect(&input.payload);
        let aligned = self.textile.align(&braid.bytes);
        let packed = self.spiral.pack(&aligned);
        let braid2 = Braid { bytes: packed };

        // Tokenize and evaluate using a naive gain from rules count
        let mut frame = self.cores.tokenize(&braid2);
        let gain = (self.kernel.rules.len() as i32).max(1);
        self.cores.evaluate(&mut frame, gain);
        let score = self.cores.reduce(&frame);
        let prio = ((score.abs() % 255) as u8).max(1);

        let route = self.router.plan(prio);
        let tier = self.storage.select_tier(prio);
        Decision { route, priority: prio, store_tier: tier }
    }
}

// Bootstrap sequence (8 steps):
// 1. kernel.activate()
// 2. rim.sync()
// 3. power.validate()
// 4. cores.initialize(12)
// 5. router.build_tables(64)
// 6. storage.mount_tiers()
// 7. seal.verify_chain()
// 8. pot.resonate(432Hz)
