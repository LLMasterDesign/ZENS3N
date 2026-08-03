#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const scriptDir = path.dirname(new URL(import.meta.url).pathname);
const repoRoot = path.resolve(scriptDir, '..', '..', '..', '..', '..', '..');
const defaultBoard = path.join(repoRoot, '!WORKDESK', 'Websites', '_Atlas', 'launch-board.json');
const gatedTasks = new Set(['scale-2', 'live-2']);
const providerTrackStates = {
  'railway-staging': new Set(['not-activated', 'ready-for-approval', 'active', 'retired']),
  'stripe-test-offer': new Set(['offer-not-defined', 'ready-for-test', 'test-active', 'live-active', 'deferred']),
};
const approvalStates = new Set(['active', 'test-active', 'live-active']);

function usage(message) {
  if (message) console.error(`Error: ${message}\n`);
  console.error(`Usage:
  node deploy/update-launch-board.mjs --task <id> --state <complete|pending> [options]
  node deploy/update-launch-board.mjs --provider-track <id> --provider-state <state> [options]

Options:
  --evidence <path>       Repo-relative receipt required when completing a task
  --approval-ref <value>  Required for approval-gated tasks
  --url <https-url>       Public URL recorded for an activated provider track
  --note <text>           Add a short receipt note to the task
  --board <path>          Override the board path (for testing)
  --dry-run               Validate and print the resulting board without writing
  --help                  Show this help
`);
  process.exit(message ? 2 : 0);
}

const args = process.argv.slice(2);
const options = {};
for (let i = 0; i < args.length; i += 1) {
  const arg = args[i];
  if (arg === '--help') usage();
  if (arg === '--dry-run') { options.dryRun = true; continue; }
  if (!arg.startsWith('--')) usage(`Unknown argument: ${arg}`);
  const key = arg.slice(2).replaceAll('-', '_');
  const value = args[i + 1];
  if (!value || value.startsWith('--')) usage(`Missing value for ${arg}`);
  options[key] = value;
  i += 1;
}

if ((options.task && options.provider_track) || (!options.task && !options.provider_track)) {
  usage('Provide exactly one of --task or --provider-track');
}
if (options.task) {
  if (!options.state || !['complete', 'pending'].includes(options.state)) {
    usage('--state must be complete or pending');
  }
  if (options.state === 'complete' && !options.evidence) {
    usage('--evidence is required when completing a task');
  }
  if (gatedTasks.has(options.task) && options.state === 'complete' && !options.approval_ref) {
    usage(`--approval-ref is required to complete gated task ${options.task}`);
  }
} else {
  if (!providerTrackStates[options.provider_track]) {
    usage(`Unknown provider track: ${options.provider_track}`);
  }
  if (!options.provider_state || !providerTrackStates[options.provider_track].has(options.provider_state)) {
    usage(`Invalid --provider-state for ${options.provider_track}`);
  }
  if (!options.evidence) usage('--evidence is required when updating a provider track');
  if (approvalStates.has(options.provider_state) && !options.approval_ref) {
    usage(`--approval-ref is required for provider state ${options.provider_state}`);
  }
  if (approvalStates.has(options.provider_state) && !options.url) {
    usage(`--url is required for provider state ${options.provider_state}`);
  }
  if (approvalStates.has(options.provider_state) && options.url) {
    try {
      const parsedUrl = new URL(options.url);
      if (parsedUrl.protocol !== 'https:' || parsedUrl.username || parsedUrl.password) {
        usage('--url must be an HTTPS URL without embedded credentials');
      }
    } catch {
      usage('--url must be a valid HTTPS URL');
    }
  }
}

const boardPath = path.resolve(repoRoot, options.board || defaultBoard);
if (!fs.existsSync(boardPath)) usage(`Board not found: ${boardPath}`);

let board;
try {
  board = JSON.parse(fs.readFileSync(boardPath, 'utf8'));
} catch (error) {
  usage(`Board is not valid JSON: ${error.message}`);
}

function resolveEvidence(evidence) {
  const evidenceCandidates = [
    path.resolve(repoRoot, evidence),
    path.resolve(process.cwd(), evidence),
  ];
  const evidencePath = evidenceCandidates.find((candidate) => fs.existsSync(candidate));
  if (!evidencePath || !fs.statSync(evidencePath).isFile()) {
    usage(`Evidence file not found: ${evidence}`);
  }
  if (fs.statSync(evidencePath).size === 0) usage(`Evidence file is empty: ${evidence}`);
  return path.relative(repoRoot, evidencePath).split(path.sep).join('/');
}

function refreshSummary(currentBoard) {
  const tasks = currentBoard.tasks || [];
  const providerTracks = Object.values(currentBoard.provider_tracks || {});
  currentBoard.counts = {
    tasks_total: tasks.length,
    tasks_complete: tasks.filter((candidate) => candidate.state === 'complete').length,
    tasks_pending: tasks.filter((candidate) => candidate.state === 'pending').length,
    tasks_with_partial_evidence: tasks.filter((candidate) => Boolean(candidate.partial_evidence)).length,
    provider_tracks_total: providerTracks.length,
    provider_tracks_active: providerTracks.filter((candidate) => ['active', 'test-active', 'live-active'].includes(candidate.state)).length,
    provider_tracks_pending_approval: providerTracks.filter((candidate) => candidate.state === 'ready-for-approval').length,
  };
}

if (options.provider_track) {
  const track = board.provider_tracks?.[options.provider_track];
  if (!track) usage(`Provider track not found: ${options.provider_track}`);
  track.state = options.provider_state;
  track.last_verified = new Date().toISOString().slice(0, 10);
  track.evidence = resolveEvidence(options.evidence);
  if (options.url) track.url = options.url;
  if (approvalStates.has(options.provider_state)) track.approval_ref = options.approval_ref;
  else delete track.approval_ref;
  if (options.note) track.evidence_note = options.note;
  board.updated = track.last_verified;
  refreshSummary(board);

  const output = `${JSON.stringify(board, null, 2)}\n`;
  if (options.dryRun) {
    process.stdout.write(output);
  } else {
    fs.writeFileSync(boardPath, output, 'utf8');
    console.log(`Updated provider track ${options.provider_track} -> ${options.provider_state}`);
    console.log(`Board: ${path.relative(repoRoot, boardPath)}`);
  }
  process.exit(0);
}

const task = board.tasks?.find((candidate) => candidate.id === options.task);
if (!task) usage(`Task not found: ${options.task}`);

if (options.state === 'complete') {
  task.evidence = resolveEvidence(options.evidence);
  delete task.partial_evidence;
  if (options.approval_ref) task.approval_ref = options.approval_ref;
} else {
  delete task.approval_ref;
  if (options.evidence) {
    task.partial_evidence = resolveEvidence(options.evidence);
  }
}

task.state = options.state;
task.last_verified = new Date().toISOString().slice(0, 10);
if (options.note) task.evidence_note = options.note;
board.updated = task.last_verified;
refreshSummary(board);

const output = `${JSON.stringify(board, null, 2)}\n`;
if (options.dryRun) {
  process.stdout.write(output);
} else {
  fs.writeFileSync(boardPath, output, 'utf8');
  console.log(`Updated ${options.task} -> ${options.state}`);
  console.log(`Board: ${path.relative(repoRoot, boardPath)}`);
}
