# 🚀 3OX Workflow System - Implementation Guide

**Sirius Time:** ⧗-25.61  
**Status:** Implementation Roadmap  
**For:** 3OX.Ai Framework

---

## 📋 OVERVIEW

This guide shows how to implement the Conductor-style workflow orchestration system for 3OX, step by step.

---

## 🎯 PHASE 1: MINIMAL VIABLE WORKFLOW (Week 1-2)

### Step 1: Create Workflow Schema

**File:** `.3ox.index/CORE/WORKFLOWS/WORKFLOW.SCHEMA.md`

Define the YAML schema that all workflows must follow:

```yaml
workflow:
  id: string (required, unique)
  name: string (required)
  version: number (required)
  input: object
  output: array
  tasks: array (required)
    - id: string
      type: SIMPLE | DECISION | HUMAN | FORK | JOIN
      depends_on: array
      input: object
      output: object
  failure_workflow: object
  monitoring: object
```

### Step 2: Create Workflow State Tracker

**File:** `.3ox.index/CORE/workflow-state.js`

```javascript
class WorkflowState {
  constructor() {
    this.stateFile = '.3ox/workflow.state.yaml';
    this.activeWorkflows = new Map();
  }
  
  async createWorkflow(workflowDef, input) {
    const id = `wf-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const state = {
      id: id,
      definition_id: workflowDef.id,
      status: 'RUNNING',
      input: input,
      tasks: {},
      created_at: this.getSiriusTime(),
      updated_at: this.getSiriusTime()
    };
    
    // Initialize all tasks as PENDING
    for (const task of workflowDef.tasks) {
      state.tasks[task.id] = {
        status: 'PENDING',
        attempts: 0,
        output: null
      };
    }
    
    this.activeWorkflows.set(id, state);
    await this.persistState();
    
    return id;
  }
  
  async updateTaskStatus(workflowId, taskId, status, output = null) {
    const workflow = this.activeWorkflows.get(workflowId);
    
    workflow.tasks[taskId].status = status;
    workflow.tasks[taskId].output = output;
    workflow.updated_at = this.getSiriusTime();
    
    await this.persistState();
  }
  
  async completeWorkflow(workflowId) {
    const workflow = this.activeWorkflows.get(workflowId);
    workflow.status = 'COMPLETED';
    workflow.completed_at = this.getSiriusTime();
    
    await this.persistState();
    await this.archiveWorkflow(workflowId);
  }
  
  getSiriusTime() {
    // Calculate Sirius time ⧗-YY.DD
    const genesis = new Date('2025-08-07');
    const now = new Date();
    const diff = now - genesis;
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const year = Math.floor(days / 365);
    const day = days % 365;
    return `⧗-${year}.${day}`;
  }
  
  async persistState() {
    const yaml = require('js-yaml');
    const fs = require('fs').promises;
    
    const data = {};
    for (const [id, state] of this.activeWorkflows) {
      data[id] = state;
    }
    
    await fs.writeFile(
      this.stateFile,
      yaml.dump(data),
      'utf8'
    );
  }
}

module.exports = WorkflowState;
```

### Step 3: Create Simple Workflow Executor

**File:** `.3ox.index/CORE/workflow-executor.js`

```javascript
const WorkflowState = require('./workflow-state');
const fs = require('fs').promises;
const yaml = require('js-yaml');
const path = require('path');

class WorkflowExecutor {
  constructor() {
    this.state = new WorkflowState();
    this.taskHandlers = new Map();
    
    // Register built-in task handlers
    this.registerTaskHandler('SIMPLE', this.executeSimpleTask.bind(this));
    this.registerTaskHandler('DECISION', this.executeDecisionTask.bind(this));
  }
  
  registerTaskHandler(type, handler) {
    this.taskHandlers.set(type, handler);
  }
  
  async startWorkflow(workflowDefPath, input) {
    // Load workflow definition
    const defContent = await fs.readFile(workflowDefPath, 'utf8');
    const workflowDef = yaml.load(defContent).workflow;
    
    console.log(`Starting workflow: ${workflowDef.name}`);
    
    // Create workflow instance
    const workflowId = await this.state.createWorkflow(workflowDef, input);
    
    console.log(`Workflow ID: ${workflowId}`);
    
    // Start executing tasks
    await this.executeWorkflow(workflowId, workflowDef);
    
    return workflowId;
  }
  
  async executeWorkflow(workflowId, workflowDef) {
    const workflow = this.state.activeWorkflows.get(workflowId);
    
    while (workflow.status === 'RUNNING') {
      const nextTasks = this.findReadyTasks(workflowId, workflowDef);
      
      if (nextTasks.length === 0) {
        // No more tasks to execute
        await this.state.completeWorkflow(workflowId);
        console.log(`✓ Workflow ${workflowId} completed`);
        break;
      }
      
      // Execute all ready tasks (handles parallel execution)
      await Promise.all(
        nextTasks.map(task => this.executeTask(workflowId, task, workflowDef))
      );
    }
  }
  
  findReadyTasks(workflowId, workflowDef) {
    const workflow = this.state.activeWorkflows.get(workflowId);
    const ready = [];
    
    for (const task of workflowDef.tasks) {
      const taskState = workflow.tasks[task.id];
      
      // Skip if already completed or in progress
      if (taskState.status !== 'PENDING') continue;
      
      // Check dependencies
      if (task.depends_on && task.depends_on.length > 0) {
        const depsCompleted = task.depends_on.every(depId => {
          return workflow.tasks[depId].status === 'COMPLETED';
        });
        
        if (!depsCompleted) continue;
      }
      
      ready.push(task);
    }
    
    return ready;
  }
  
  async executeTask(workflowId, task, workflowDef) {
    console.log(`  → Executing task: ${task.name}`);
    
    await this.state.updateTaskStatus(workflowId, task.id, 'IN_PROGRESS');
    
    try {
      const handler = this.taskHandlers.get(task.type);
      
      if (!handler) {
        throw new Error(`No handler for task type: ${task.type}`);
      }
      
      const output = await handler(workflowId, task, workflowDef);
      
      await this.state.updateTaskStatus(workflowId, task.id, 'COMPLETED', output);
      
      console.log(`  ✓ Task completed: ${task.name}`);
      
    } catch (error) {
      console.error(`  ✗ Task failed: ${task.name}`, error.message);
      
      // Handle retry logic
      const workflow = this.state.activeWorkflows.get(workflowId);
      const taskState = workflow.tasks[task.id];
      
      taskState.attempts++;
      
      if (task.retry_policy && taskState.attempts < task.retry_policy.max_attempts) {
        console.log(`  ⟳ Retrying task (attempt ${taskState.attempts + 1})`);
        
        await this.state.updateTaskStatus(workflowId, task.id, 'PENDING');
        
        const delay = this.calculateBackoff(taskState.attempts, task.retry_policy);
        await this.sleep(delay);
        
        await this.executeTask(workflowId, task, workflowDef);
        
      } else {
        await this.state.updateTaskStatus(workflowId, task.id, 'FAILED');
        workflow.status = 'FAILED';
        throw error;
      }
    }
  }
  
  async executeSimpleTask(workflowId, task, workflowDef) {
    // Resolve input parameters using template syntax
    const input = this.resolveInputs(workflowId, task.input, workflowDef);
    
    // Check if this is a built-in command or external agent call
    if (task.assigned_to) {
      // Route to agent via 1N.3OX
      return await this.routeToAgent(workflowId, task, input);
    }
    
    // Otherwise execute as built-in function
    // (For Phase 1, we can use direct JavaScript functions)
    return await this.executeBuiltInTask(task, input);
  }
  
  async executeDecisionTask(workflowId, task, workflowDef) {
    const decisionValue = this.resolveValue(
      workflowId,
      task.decision_param,
      workflowDef
    );
    
    console.log(`  Decision value: ${decisionValue}`);
    
    const caseConfig = task.decision_cases[decisionValue];
    
    if (!caseConfig) {
      console.log(`  No case for ${decisionValue}, using default`);
      return { decision: decisionValue, case: 'default' };
    }
    
    // Mark the next tasks based on decision
    // (This is handled by the dependency system)
    
    return { decision: decisionValue, case: caseConfig };
  }
  
  resolveInputs(workflowId, inputSpec, workflowDef) {
    const workflow = this.state.activeWorkflows.get(workflowId);
    const resolved = {};
    
    for (const [key, value] of Object.entries(inputSpec)) {
      if (typeof value === 'string' && value.startsWith('${')) {
        resolved[key] = this.resolveValue(workflowId, value, workflowDef);
      } else {
        resolved[key] = value;
      }
    }
    
    return resolved;
  }
  
  resolveValue(workflowId, template, workflowDef) {
    const workflow = this.state.activeWorkflows.get(workflowId);
    
    // Handle ${workflow.input.XXX}
    if (template.startsWith('${workflow.input.')) {
      const key = template.replace('${workflow.input.', '').replace('}', '');
      return workflow.input[key];
    }
    
    // Handle ${TASK_ID.output.XXX}
    const taskOutputMatch = template.match(/\$\{([^.]+)\.output\.([^}]+)\}/);
    if (taskOutputMatch) {
      const [, taskId, outputKey] = taskOutputMatch;
      const taskOutput = workflow.tasks[taskId].output;
      return taskOutput[outputKey];
    }
    
    return template;
  }
  
  calculateBackoff(attempt, policy) {
    if (policy.backoff_strategy === 'exponential') {
      const delay = Math.pow(2, attempt) * 1000; // seconds to ms
      return Math.min(delay, policy.max_delay || 60000);
    }
    
    return policy.initial_delay || 1000;
  }
  
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  async routeToAgent(workflowId, task, input) {
    // Phase 1: Just execute locally
    // Phase 2: Write to 1N.3OX and wait for 0UT.3OX response
    
    console.log(`    (Would route to ${task.assigned_to} with input:`, input);
    
    // Simulate task execution
    await this.sleep(500);
    
    return { status: 'success', data: input };
  }
  
  async executeBuiltInTask(task, input) {
    // Built-in task implementations
    // For Phase 1, we can add simple file operations here
    
    return { status: 'success', data: input };
  }
}

module.exports = WorkflowExecutor;
```

### Step 4: Create CLI Command

**File:** `.3ox.index/CORE/workflow-cli.js`

```javascript
#!/usr/bin/env node

const WorkflowExecutor = require('./workflow-executor');
const path = require('path');

async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.log(`
Usage: workflow-cli.js <workflow-file> <input-json>

Example:
  workflow-cli.js inventory-validation.workflow.yaml '{"target_folder": "0UT.3OX"}'
    `);
    process.exit(1);
  }
  
  const workflowFile = args[0];
  const input = JSON.parse(args[1]);
  
  const executor = new WorkflowExecutor();
  
  try {
    const workflowId = await executor.startWorkflow(workflowFile, input);
    console.log(`\n✓ Workflow completed: ${workflowId}`);
    
  } catch (error) {
    console.error(`\n✗ Workflow failed:`, error.message);
    process.exit(1);
  }
}

main();
```

### Step 5: Test with Inventory Validation

**Create test script:** `test-workflow.sh`

```bash
#!/bin/bash

echo "Testing 3OX Workflow System"
echo "============================"

# Run inventory validation workflow
node .3ox.index/CORE/workflow-cli.js \
  log.book/research/workflows/inventory-validation.workflow.yaml \
  '{
    "target_folder": "0UT.3OX",
    "policy_file": ".3ox.index/POLICY/INVENTORY.POLICY.md",
    "strict_mode": false,
    "generate_manifest": true
  }'

echo ""
echo "Check .3ox/workflow.state.yaml for execution state"
echo "Check 0UT.3OX/VALIDATION.RECEIPT.yaml for results"
```

---

## 🎯 PHASE 2: INTEGRATION WITH 1N/0UT (Week 3-4)

### Step 1: Create 1N.3OX Task Adapter

**File:** `.3ox.index/CORE/task-adapter.js`

```javascript
const fs = require('fs').promises;
const path = require('path');
const yaml = require('js-yaml');

class TaskAdapter {
  constructor() {
    this.taskQueue = '.3ox/task-queue/';
    this.responseQueue = '.3ox/response-queue/';
  }
  
  async sendTaskToAgent(workflowId, task, input) {
    const taskMessage = {
      header: {
        sirius_time: this.getSiriusTime(),
        workflow_id: workflowId,
        task_id: task.id,
        task_name: task.name,
        agent_level: task.agent_level,
        assigned_to: task.assigned_to,
        timeout: task.timeout,
        requires_response: true
      },
      payload: input,
      routing: {
        urgency: 'normal',
        reply_to: this.responseQueue
      }
    };
    
    const filename = `task-${workflowId}-${task.id}.yaml`;
    const filepath = path.join(this.taskQueue, filename);
    
    await fs.writeFile(filepath, yaml.dump(taskMessage), 'utf8');
    
    console.log(`    → Task sent to queue: ${filename}`);
    
    // Wait for response
    return await this.waitForResponse(workflowId, task.id, task.timeout);
  }
  
  async waitForResponse(workflowId, taskId, timeout) {
    const responseFile = path.join(
      this.responseQueue,
      `response-${workflowId}-${taskId}.yaml`
    );
    
    const startTime = Date.now();
    const timeoutMs = this.parseTimeout(timeout);
    
    while (true) {
      try {
        const content = await fs.readFile(responseFile, 'utf8');
        const response = yaml.load(content);
        
        // Delete response file after reading
        await fs.unlink(responseFile);
        
        return response.payload;
        
      } catch (error) {
        // File doesn't exist yet
        if (Date.now() - startTime > timeoutMs) {
          throw new Error(`Task timeout after ${timeout}`);
        }
        
        // Wait 500ms and try again
        await new Promise(resolve => setTimeout(resolve, 500));
      }
    }
  }
  
  parseTimeout(timeout) {
    // Parse "30s", "2m", etc.
    const match = timeout.match(/(\d+)([smh])/);
    if (!match) return 60000; // default 60s
    
    const [, value, unit] = match;
    const multiplier = { s: 1000, m: 60000, h: 3600000 };
    
    return parseInt(value) * multiplier[unit];
  }
  
  getSiriusTime() {
    const genesis = new Date('2025-08-07');
    const now = new Date();
    const diff = now - genesis;
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const year = Math.floor(days / 365);
    const day = days % 365;
    return `⧗-${year}.${day}`;
  }
}

module.exports = TaskAdapter;
```

### Step 2: Create Agent Task Listener

**File:** `.3ox.index/CORE/agent-listener.js`

```javascript
const chokidar = require('chokidar');
const fs = require('fs').promises;
const yaml = require('js-yaml');
const path = require('path');

class AgentListener {
  constructor(agentName, taskHandler) {
    this.agentName = agentName;
    this.taskHandler = taskHandler;
    this.taskQueue = '.3ox/task-queue/';
    this.responseQueue = '.3ox/response-queue/';
  }
  
  start() {
    console.log(`Agent ${this.agentName} listening for tasks...`);
    
    const watcher = chokidar.watch(
      path.join(this.taskQueue, '*.yaml'),
      { persistent: true }
    );
    
    watcher.on('add', async (filepath) => {
      await this.handleTask(filepath);
    });
  }
  
  async handleTask(filepath) {
    try {
      const content = await fs.readFile(filepath, 'utf8');
      const taskMessage = yaml.load(content);
      
      // Check if this task is for me
      if (taskMessage.header.assigned_to !== this.agentName) {
        return; // Not for me
      }
      
      console.log(`\n✓ Received task: ${taskMessage.header.task_name}`);
      
      // Execute task
      const result = await this.taskHandler(taskMessage.payload);
      
      // Send response
      await this.sendResponse(taskMessage.header, result);
      
      // Delete task file
      await fs.unlink(filepath);
      
      console.log(`✓ Task completed and response sent`);
      
    } catch (error) {
      console.error(`✗ Task failed:`, error.message);
    }
  }
  
  async sendResponse(header, result) {
    const response = {
      header: {
        sirius_time: this.getSiriusTime(),
        workflow_id: header.workflow_id,
        task_id: header.task_id,
        agent: this.agentName,
        status: 'success'
      },
      payload: result
    };
    
    const filename = `response-${header.workflow_id}-${header.task_id}.yaml`;
    const filepath = path.join(this.responseQueue, filename);
    
    await fs.writeFile(filepath, yaml.dump(response), 'utf8');
  }
  
  getSiriusTime() {
    const genesis = new Date('2025-08-07');
    const now = new Date();
    const diff = now - genesis;
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const year = Math.floor(days / 365);
    const day = days % 365;
    return `⧗-${year}.${day}`;
  }
}

// Example usage
if (require.main === module) {
  const listener = new AgentListener('FILE_SCANNER_AGENT', async (input) => {
    // Scan files
    console.log('  Scanning folder:', input.folder);
    
    // ... actual scanning logic here ...
    
    return {
      file_list: ['file1.txt', 'file2.md'],
      total_files: 2,
      scan_timestamp: new Date().toISOString()
    };
  });
  
  listener.start();
}

module.exports = AgentListener;
```

---

## 🎯 PHASE 3: POWERSHELL INTEGRATION (Week 5)

### Convert Existing PowerShell Script to Workflow Tasks

**Your current script:** `0UT.3OX/VALIDATE.INVENTORY.SESSION.ps1`

**Can be decomposed into workflow tasks:**

```powershell
# Task: FILE_SCANNER_AGENT
function Invoke-FileScan {
    param($Input)
    
    $files = Get-ChildItem -Path $Input.folder -Recurse
    
    return @{
        file_list = $files | Select-Object Name, FullName, Length
        total_files = $files.Count
        scan_timestamp = Get-Date
    }
}

# Task: POLICY_LOADER_AGENT
function Invoke-PolicyLoad {
    param($Input)
    
    $policy = Get-Content $Input.policy | ConvertFrom-Yaml
    
    return @{
        policy_rules = $policy.rules
        required_files = $policy.required_files
    }
}

# Task: COMPLIANCE_VALIDATOR_AGENT
function Invoke-ComplianceValidation {
    param($Input)
    
    $missing = @()
    foreach ($required in $Input.required_files) {
        if ($required -notin $Input.file_list.Name) {
            $missing += $required
        }
    }
    
    $status = if ($missing.Count -eq 0) { "PASS" } else { "FAIL" }
    
    return @{
        compliance_status = $status
        missing_files = $missing
        compliance_score = [Math]::Round((1 - $missing.Count / $Input.required_files.Count) * 100)
    }
}

# Main workflow orchestrator
function Start-WorkflowExecution {
    param($WorkflowFile, $InputData)
    
    # Load workflow definition
    $workflow = Get-Content $WorkflowFile | ConvertFrom-Yaml
    
    # Execute tasks in order
    $results = @{}
    
    foreach ($task in $workflow.workflow.tasks) {
        Write-Host "Executing: $($task.name)"
        
        # Resolve inputs
        $taskInput = Resolve-WorkflowInputs -Task $task -Results $results -WorkflowInput $InputData
        
        # Execute task
        $output = & "Invoke-$($task.assigned_to)" -Input $taskInput
        
        $results[$task.id] = $output
        
        Write-Host "✓ Completed: $($task.name)`n"
    }
    
    return $results
}

# Usage
Start-WorkflowExecution `
    -WorkflowFile "inventory-validation.workflow.yaml" `
    -InputData @{
        target_folder = "0UT.3OX"
        policy_file = ".3ox.index/POLICY/INVENTORY.POLICY.md"
    }
```

---

## 📊 MIGRATION PATH

### Current State → Workflow State

```
BEFORE (Manual):
1. User runs PowerShell script
2. Script executes steps sequentially
3. Manual error handling
4. No state tracking
5. No resume on failure

AFTER (Workflow):
1. User starts workflow via CLI
2. Workflow engine orchestrates tasks
3. Automatic retry with backoff
4. Complete state tracking in .3ox/workflow.state.yaml
5. Can resume failed workflows
6. Visual progress monitoring
```

### Example Migration:

**Old way:**
```powershell
.\VALIDATE.INVENTORY.SESSION.ps1 -TargetFolder "0UT.3OX"
```

**New way:**
```bash
workflow start inventory-validation-v1 \
  --target_folder "0UT.3OX" \
  --policy_file ".3ox.index/POLICY/INVENTORY.POLICY.md"
```

**Or from CMD.BRIDGE:**
```
@workflow inventory-validation-v1 target_folder=0UT.3OX
```

---

## ✅ SUCCESS METRICS

### Phase 1 Success:
- ✓ Can load workflow definition from YAML
- ✓ Can execute simple sequential workflow
- ✓ Can track workflow state
- ✓ Can handle task failures with retry

### Phase 2 Success:
- ✓ Tasks route to agents via queue files
- ✓ Agents respond with results
- ✓ Workflow waits for async task completion
- ✓ Multiple agents can work in parallel

### Phase 3 Success:
- ✓ PowerShell scripts integrated as workflow tasks
- ✓ Existing inventory validation works via workflow
- ✓ Complete audit trail generated
- ✓ Faster than manual execution

---

## 🔄 NEXT STEPS

1. **Implement Phase 1** (2 weeks)
   - Create WorkflowState class
   - Create WorkflowExecutor class
   - Test with simple workflow

2. **Integrate with 3OX** (1-2 weeks)
   - Connect to 1N/0UT system
   - Create agent listeners
   - Test multi-agent coordination

3. **Migrate Existing Scripts** (1 week)
   - Convert PowerShell validation script
   - Create workflow templates
   - Document usage

4. **Production Hardening** (2 weeks)
   - Add monitoring dashboard
   - Add error recovery
   - Add performance optimization

**Total Timeline: 6-7 weeks to production-ready system**

---

**Status:** Implementation roadmap complete  
**Next:** Begin Phase 1 implementation

//▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂〘・.°𝚫〙

