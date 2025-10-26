# 🔄 3OX Workflow System - Example Workflows

**Purpose:** Example workflow definitions and implementation guides  
**Status:** Research Phase / Prototype  
**Sirius Time:** ⧗-25.61

---

## 📋 CONTENTS

This folder contains example workflows and implementation guides for the 3OX workflow orchestration system:

1. **inventory-validation.workflow.yaml** - Complete workflow definition example
2. **IMPLEMENTATION.GUIDE.md** - Step-by-step implementation instructions
3. **BEFORE-AFTER-COMPARISON.md** - Comparison with current manual approach

---

## 🎯 WHAT IS A WORKFLOW?

A **workflow** is a declarative definition of a multi-step process that can:

- Execute tasks in sequence or parallel
- Handle errors with automatic retry
- Track state at every step
- Route to different agents based on results
- Wait for human approval when needed
- Generate complete audit trails

**Think of it as:** A recipe that the 3OX system can execute automatically, with built-in error handling and monitoring.

---

## 📄 EXAMPLE WORKFLOW: Inventory Validation

### Current Approach (PowerShell Script):

```powershell
# Manual PowerShell script
.\VALIDATE.INVENTORY.SESSION.ps1 -TargetFolder "0UT.3OX"

# Problems:
# - Runs sequentially (even independent steps)
# - No automatic retry on failure
# - No state tracking
# - Must restart from beginning if interrupted
# - Console output lost when closed
```

### Workflow Approach:

```bash
# Start workflow
workflow start inventory-validation-v1 \
  --target_folder "0UT.3OX" \
  --policy_file ".3ox.index/POLICY/INVENTORY.POLICY.md"

# Benefits:
# - Parallel execution where possible
# - Automatic retry with exponential backoff
# - Complete state tracking in .3ox/workflow.state.yaml
# - Can resume if interrupted
# - Complete audit trail preserved
```

---

## 🏗️ WORKFLOW STRUCTURE

A 3OX workflow consists of:

### 1. Workflow Metadata
```yaml
workflow:
  id: "inventory-validation-v1"
  name: "Inventory Validation Workflow"
  version: 1
  description: "Validates file inventory against policy"
```

### 2. Input/Output Specification
```yaml
  input:
    required:
      - target_folder
      - policy_file
    optional:
      - strict_mode: false
  
  output:
    - validation_receipt
    - compliance_status
```

### 3. Task Definitions
```yaml
  tasks:
    - id: "scan_files"
      name: "Scan Target Folder"
      type: "SIMPLE"
      timeout: "2m"
      retry_policy:
        max_attempts: 3
        backoff_strategy: "exponential"
      input:
        folder: "${workflow.input.target_folder}"
      output:
        file_list: [...]
```

### 4. Task Dependencies
```yaml
    - id: "validate_compliance"
      depends_on: ["scan_files", "load_policy"]
      # Will wait for both tasks to complete
```

### 5. Decision Points
```yaml
    - id: "compliance_decision_gate"
      type: "DECISION"
      decision_param: "${validate_compliance.output.compliance_status}"
      decision_cases:
        PASS:
          next_tasks: ["generate_success_receipt"]
        FAIL:
          next_tasks: ["generate_failure_receipt", "alert_cmd_bridge"]
```

### 6. Error Handling
```yaml
  failure_workflow:
    id: "inventory-validation-failure-handler"
    steps:
      - log_to_incident
      - notify_commander
      - preserve_state
```

---

## 🚀 HOW TO USE THESE EXAMPLES

### For Learning:

1. **Read:** `inventory-validation.workflow.yaml`
   - See complete workflow definition
   - Understand task structure
   - Learn YAML syntax

2. **Compare:** `BEFORE-AFTER-COMPARISON.md`
   - See current vs workflow approach
   - Understand benefits
   - Review performance metrics

3. **Implement:** `IMPLEMENTATION.GUIDE.md`
   - Step-by-step instructions
   - Code examples
   - Testing procedures

### For Implementation:

1. **Start with Phase 1** (Basic workflow engine)
   - Implement state tracker
   - Implement simple executor
   - Test with this example workflow

2. **Adapt to your use case**
   - Copy `inventory-validation.workflow.yaml`
   - Modify tasks for your needs
   - Test thoroughly

3. **Expand to advanced features**
   - Add parallel execution
   - Add decision gates
   - Add human-in-the-loop

---

## 📖 WORKFLOW TASK TYPES

### SIMPLE Task
Basic task execution, assigned to an agent or built-in function.

```yaml
- id: "scan_files"
  type: "SIMPLE"
  assigned_to: "FILE_SCANNER_AGENT"
  input: { folder: "0UT.3OX" }
  output: { file_list: [...] }
```

### DECISION Task
Conditional branching based on previous task results.

```yaml
- id: "decision_gate"
  type: "DECISION"
  decision_param: "${previous_task.output.status}"
  decision_cases:
    PASS:
      next_tasks: ["success_handler"]
    FAIL:
      next_tasks: ["failure_handler"]
```

### HUMAN Task
Wait for human approval or input.

```yaml
- id: "alert_cmd_bridge"
  type: "HUMAN"
  wait_for_approval: true
  approval_timeout: "24h"
  approval_options:
    - "APPROVE"
    - "REJECT"
    - "MODIFY"
```

### FORK Task (Future)
Execute multiple tasks in parallel.

```yaml
- id: "parallel_scan"
  type: "FORK"
  tasks:
    - "scan_folder_1"
    - "scan_folder_2"
    - "scan_folder_3"
```

### JOIN Task (Future)
Wait for all forked tasks to complete.

```yaml
- id: "aggregate_results"
  type: "JOIN"
  depends_on: ["parallel_scan"]
```

---

## 🔄 WORKFLOW EXECUTION STATES

### Workflow States:
- `RUNNING` - Currently executing
- `COMPLETED` - Successfully finished
- `FAILED` - Execution failed
- `PAUSED` - Waiting for human input
- `CANCELLED` - Manually stopped

### Task States:
- `PENDING` - Not started yet
- `IN_PROGRESS` - Currently running
- `COMPLETED` - Successfully finished
- `FAILED` - Execution failed
- `RETRYING` - Failed, attempting retry

---

## 📊 STATE TRACKING EXAMPLE

When you run a workflow, state is tracked in `.3ox/workflow.state.yaml`:

```yaml
workflow_12345:
  id: "workflow_12345"
  definition_id: "inventory-validation-v1"
  status: "RUNNING"
  created_at: "⧗-25.61.1420"
  updated_at: "⧗-25.61.1422"
  
  input:
    target_folder: "0UT.3OX"
    policy_file: ".3ox.index/POLICY/INVENTORY.POLICY.md"
  
  tasks:
    scan_files:
      status: "COMPLETED"
      started_at: "⧗-25.61.1420"
      completed_at: "⧗-25.61.1421"
      attempts: 1
      output: {...}
    
    validate_compliance:
      status: "IN_PROGRESS"
      started_at: "⧗-25.61.1421"
      attempts: 1
```

This allows:
- **Resume:** If interrupted, continue from last completed task
- **Monitoring:** See real-time progress
- **Audit:** Complete history of execution
- **Debugging:** Know exactly what failed and when

---

## 🎯 CREATING YOUR OWN WORKFLOW

### Step 1: Define the Goal

What multi-step process do you want to automate?

Examples:
- File validation and receipts
- Station deployment
- Multi-agent research coordination
- Data migration
- Compliance audits

### Step 2: Break Into Tasks

What are the individual steps?

Example:
```
Goal: Deploy new station
Tasks:
  1. Create folder structure
  2. Initialize .3ox.index/
  3. Deploy policies
  4. Configure 1N/0UT
  5. Register with CMD.BRIDGE
  6. Run health check
```

### Step 3: Identify Dependencies

Which tasks depend on others? Which can run in parallel?

```
create_folders → initialize_3ox → deploy_policies
                                ↓
                     configure_1n_0ut → register → health_check
```

### Step 4: Define Error Handling

What should happen if a task fails?

```
Retry 3 times → Still failing? → Alert Commander
```

### Step 5: Write the YAML

Use `inventory-validation.workflow.yaml` as a template:

```yaml
workflow:
  id: "my-workflow-v1"
  name: "My Workflow"
  tasks:
    - id: "step1"
      type: "SIMPLE"
      # ... task definition ...
```

### Step 6: Test

```bash
workflow start my-workflow-v1 --input "value"
```

Monitor state in `.3ox/workflow.state.yaml` and logs.

---

## 🔧 INTEGRATION WITH 3OX SYSTEMS

### With 1N/0UT Protocol:

Workflows can route tasks to agents via 1N.3OX:

```yaml
- id: "scan_files"
  assigned_to: "FILE_SCANNER_AGENT"
  agent_level: "L3"
```

This creates a 1N.3OX message:
```yaml
# .3ox/task-queue/task-{workflow_id}-{task_id}.yaml
header:
  workflow_id: "workflow_12345"
  task_id: "scan_files"
  assigned_to: "FILE_SCANNER_AGENT"
payload:
  folder: "0UT.3OX"
```

Agent responds via 0UT.3OX:
```yaml
# .3ox/response-queue/response-{workflow_id}-{task_id}.yaml
header:
  workflow_id: "workflow_12345"
  task_id: "scan_files"
  status: "success"
payload:
  file_list: [...]
```

### With WORKSET Policy:

Every workflow instance is a workset:

```yaml
workset:
  id: "ws-workflow_12345"
  goal: "Validate inventory for 0UT.3OX"
  workflow_instance: "workflow_12345"
  status: "in_progress"
```

### With Agent Hierarchy:

Workflows respect agent levels:
- `L0` (Commander) - Can approve HUMAN tasks
- `L1` (CMD.BRIDGE) - Can start/stop/modify workflows
- `L2` (Station OPS) - Can start workflows in their domain
- `L3` (Workers) - Execute tasks assigned by workflows

---

## 📚 ADDITIONAL RESOURCES

### Related Documents:
- `../18.orkes-conductor-agentic-workflows.md` - Full research report
- `../18.EXECUTIVE.SUMMARY.md` - Quick overview and recommendations
- `IMPLEMENTATION.GUIDE.md` - Detailed implementation steps
- `BEFORE-AFTER-COMPARISON.md` - Performance and feature comparison

### Source Material:
- [Orkes Blog - Building Agentic Workflows](https://orkes.io/blog/building-agentic-interview-app-with-conductor/)
- [Netflix Conductor](https://github.com/Netflix/conductor)
- [Temporal.io](https://docs.temporal.io/)

### 3OX Core Documentation:
- `.3ox.index/CORE/GENESIS.SYSTEM.ARCHITECTURE.md` - 3OX system overview
- `.3ox.index/POLICY/WORKSET.POLICY.md` - Workset tracking requirements
- `.3ox.index/CORE/MASTER.ROUTING.BRAIN.md` - Agent routing logic

---

## ✅ CHECKLIST: Using This Workflow Example

Before implementing workflows in your 3OX system:

- [ ] Read `inventory-validation.workflow.yaml` completely
- [ ] Understand task types (SIMPLE, DECISION, HUMAN)
- [ ] Review state tracking mechanism
- [ ] Read `IMPLEMENTATION.GUIDE.md` Phase 1
- [ ] Understand 1N/0UT integration
- [ ] Review error handling patterns
- [ ] Compare with current approach (BEFORE-AFTER-COMPARISON.md)
- [ ] Identify your first use case
- [ ] Start with Phase 1 implementation

---

## 🚀 NEXT STEPS

1. **Learn:** Read all files in this folder
2. **Understand:** Review comparison and benefits
3. **Plan:** Choose your first workflow use case
4. **Implement:** Follow Phase 1 of implementation guide
5. **Test:** Run example workflow with real data
6. **Expand:** Add more workflows as templates
7. **Scale:** Integrate with multi-agent system

---

**Status:** Example workflows and documentation complete  
**Ready for:** Phase 1 implementation  
**Questions?** See `../18.orkes-conductor-agentic-workflows.md` for full details

//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙

