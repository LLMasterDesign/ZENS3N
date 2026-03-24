# /forge Command
▛//▞▞ ⟦⎊⟧ :: ⧗-26.160 // FORGE ▞▞

▛//▞ Purpose:: Initialize and activate Forge project with autonomous workflow agency

▛▞ Usage::
- /forge (initialize current Forge)
- /forge {ProjectName} (initialize specific Forge)
- /forge start (start autonomous workflows)
- /forge agency (enable autonomous decision-making)
- /forge status (check Forge status)
- /forge stop (stop autonomous workflows)

//▞ All commands operate on !WORKDESK/{project}.Forge structure with .3ox integration.

:: ∎

## Behavior

For /forge (no parameters):
1. Detect Current Forge:
   - Check if current directory is in !WORKDESK/{project}.Forge
   - Or detect from workspace context
   - Use project name from meta.note if exists

2. Initialize .3ox Structure:
   - Create .3ox/ directory if missing
   - Create sparkfile.md from Templates/forge.sparkfile.template
   - Create run.rb for autonomous workflow execution
   - Create tools.yml with Forge-specific capabilities
   - Create routes.json for artifact routing
   - Create limits.toml for resource constraints
   - Initialize 3ox.log for trace

3. Link Existing Structure:
   - Connect to meta.note for project metadata
   - Link System/ specifications
   - Connect Templates/ for workflow templates
   - Integrate journal/, notes/, tasks/, plans/

4. Enable Agency:
   - Set autonomous decision flags
   - Configure workflow triggers
   - Initialize decision trees from System/ specs

For /forge {ProjectName}:
- Explicitly target !WORKDESK/{ProjectName}.Forge
- Follow same initialization process
- Create Forge structure if missing

For /forge start:
1. Load Forge Agent:
   - Read .3ox/sparkfile.md
   - Load run.rb runtime
   - Initialize tools from tools.yml
   - Set routes from routes.json
   - Apply limits from limits.toml

2. Activate Autonomous Workflows:
   - Start workflow monitoring
   - Enable event-driven triggers
   - Begin artifact collection
   - Start progress tracking

3. Begin Execution:
   - Process pending tasks from tasks/
   - Execute plans from plans/
   - Update journal entries
   - Route outputs per routes.json

For /forge agency:
1. Enable Decision-Making:
   - Activate autonomous choice capability
   - Load decision rules from System/
   - Enable gate evaluation autonomy
   - Set confidence thresholds

2. Configure Autonomy Levels:
   - Low: Require approval for major decisions
   - Medium: Autonomous execution with notifications
   - High: Full autonomy with logging only

3. Initialize Decision Engine:
   - Load evidence evaluation rules
   - Set gate promotion criteria
   - Configure artifact collection triggers
   - Enable checkpoint automation

For /forge status:
- Show Forge project name and status
- Display .3ox structure health
- List active workflows
- Show agency level and capabilities
- Display recent 3ox.log entries
- Show progress on tasks/plans

For /forge stop:
- Gracefully halt autonomous workflows
- Save current state
- Update journal with stop event
- Preserve 3ox.log trace
- Clear active workflow flags

## What Gets Created

### .3ox Structure
- Location: !WORKDESK/{project}.Forge/.3ox/
- Files:
  - sparkfile.md - Forge agent specification
  - run.rb - Autonomous workflow runtime
  - tools.yml - Forge capabilities (spec writing, template processing, gate evaluation)
  - routes.json - Artifact routing (System/, Templates/, journal/, etc.)
  - limits.toml - Resource constraints and safety limits
  - 3ox.log - Execution trace and receipts

### Agency Configuration
- Location: .3ox/vec3/agency.yml
- Contains:
  - Autonomy level (low/medium/high)
  - Decision rules from System/ specs
  - Gate evaluation autonomy
  - Artifact collection triggers
  - Checkpoint automation settings

### Workflow State
- Location: .3ox/vec3/var/state.json
- Tracks:
  - Active workflows
  - Current tasks in progress
  - Gate evaluation status
  - Artifact collection status
  - Last execution timestamp

## Integration

### With Forge Structure
- Reads meta.note for project context
- Uses System/ for specifications and rules
- Processes Templates/ for workflow generation
- Updates journal/, notes/, tasks/, plans/
- Routes artifacts per Forge conventions

### With 3ox System
- Uses vec3/ for state management
- Integrates with pulse system for events
- Follows 3ox agent patterns
- Logs to 3ox.log for traceability
- Respects limits.toml constraints

### With Thread System
- Can create spools from Forge work
- Evaluates gates autonomously if agency enabled
- Collects artifacts for thread packages
- Can fold mature work into threads

### With Cursor Chat
- Command detected in chat interface
- Returns Forge status and capabilities
- Shows active workflows
- Displays agency level

## Autonomous Workflow Examples

### Specification Writing
- Monitor System/ for incomplete specs
- Generate spec files from templates
- Update based on System/ requirements
- Route to appropriate System/ location

### Gate Evaluation
- Collect evidence from Forge work
- Evaluate gates per System/gates.spec.md
- Create receipts and update state
- Promote through gates autonomously

### Artifact Collection
- Monitor Forge directory for new artifacts
- Collect to appropriate locations
- Hash and catalog in manifest
- Update progress tracking

### Template Processing
- Watch Templates/ for updates
- Process templates with current context
- Generate files per template rules
- Route outputs to correct locations

## Agency Decision Points

### Low Autonomy
- Requires approval for:
  - Gate promotions
  - Major spec changes
  - New workflow creation
  - Artifact deletion

### Medium Autonomy
- Autonomous execution with notifications:
  - Gate evaluations (notify on pass/fail)
  - Spec updates (notify on changes)
  - Artifact collection (notify on new items)
  - Workflow completion (notify on finish)

### High Autonomy
- Full autonomy with logging:
  - All gate operations logged
  - All spec changes logged
  - All artifact operations logged
  - All workflow events logged
  - User reviews logs for oversight

## Next Steps After Initialization

1. Review Agency Level:
   - Check .3ox/vec3/agency.yml
   - Adjust autonomy as needed
   - Set decision thresholds

2. Start Workflows:
   - Run /forge start
   - Monitor 3ox.log
   - Check status with /forge status

3. Enable Agency:
   - Run /forge agency
   - Set autonomy level
   - Configure decision rules

4. Monitor Progress:
   - Check journal/ for updates
   - Review tasks/ for completion
   - Monitor System/ for spec changes
   - Track artifacts in routes

## Example

User types: /forge Thread.FORGE

System:
1. Detects !WORKDESK/Thread.FORGE/
2. Checks for .3ox/ structure
3. Creates .3ox/ with sparkfile.md, run.rb, tools.yml, routes.json, limits.toml
4. Links to existing meta.note, System/, Templates/
5. Initializes vec3/agency.yml with medium autonomy
6. Creates vec3/var/state.json for workflow tracking
7. Returns: Forge initialized. Run /forge start to begin workflows.

User continues:
- /forge start → Autonomous workflows begin
- /forge agency high → Full autonomy enabled
- /forge status → Shows active workflows and progress
- Workflows execute autonomously per System/ specs

## Notes

- Forge structure must exist before initialization
- .3ox structure can be added to existing Forges
- Agency requires System/ specifications for decision rules
- Autonomous workflows respect limits.toml constraints
- All operations logged to 3ox.log for traceability
- Workflows can integrate with Thread system for spool creation
- Agency decisions based on evidence and System/ rules
- State tracked in vec3/var/state.json
- Agency config in vec3/agency.yml

:: ∎
