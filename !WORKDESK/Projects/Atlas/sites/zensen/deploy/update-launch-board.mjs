#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const scriptDir = path.dirname(new URL(import.meta.url).pathname);
const repoRoot = path.resolve(scriptDir, '..', '..', '..', '..', '..', '..');
const defaultBoard = path.join(repoRoot, '!WORKDESK', 'Websites', '_Atlas', 'launch-board.json');
const gatedTasks = new Set(['scale-2', 'live-2']);

function usage(message) {
  if (message) console.error(`Error: ${message}\n`);
  console.error(`Usage:
  node deploy/update-launch-board.mjs --task <id> --state <complete|pending> [options]

Options:
  --evidence <path>       Repo-relative receipt required when completing a task
  --approval-ref <value>  Required for approval-gated tasks
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

if (!options.task) usage('Missing --task');
if (!options.state || !['complete', 'pending'].includes(options.state)) {
  usage('--state must be complete or pending');
}
if (options.state === 'complete' && !options.evidence) {
  usage('--evidence is required when completing a task');
}
if (gatedTasks.has(options.task) && options.state === 'complete' && !options.approval_ref) {
  usage(`--approval-ref is required to complete gated task ${options.task}`);
}

const boardPath = path.resolve(repoRoot, options.board || defaultBoard);
if (!fs.existsSync(boardPath)) usage(`Board not found: ${boardPath}`);

let board;
try {
  board = JSON.parse(fs.readFileSync(boardPath, 'utf8'));
} catch (error) {
  usage(`Board is not valid JSON: ${error.message}`);
}

const task = board.tasks?.find((candidate) => candidate.id === options.task);
if (!task) usage(`Task not found: ${options.task}`);

if (options.state === 'complete') {
  const evidenceCandidates = [
    path.resolve(repoRoot, options.evidence),
    path.resolve(process.cwd(), options.evidence),
  ];
  const evidencePath = evidenceCandidates.find((candidate) => fs.existsSync(candidate));
  if (!evidencePath || !fs.statSync(evidencePath).isFile()) {
    usage(`Evidence file not found: ${options.evidence}`);
  }
  if (fs.statSync(evidencePath).size === 0) usage(`Evidence file is empty: ${options.evidence}`);
  task.evidence = path.relative(repoRoot, evidencePath).split(path.sep).join('/');
  delete task.partial_evidence;
  if (options.approval_ref) task.approval_ref = options.approval_ref;
} else {
  delete task.approval_ref;
  if (options.evidence) {
    const evidenceCandidates = [
      path.resolve(repoRoot, options.evidence),
      path.resolve(process.cwd(), options.evidence),
    ];
    const evidencePath = evidenceCandidates.find((candidate) => fs.existsSync(candidate));
    if (!evidencePath || !fs.statSync(evidencePath).isFile()) {
      usage(`Evidence file not found: ${options.evidence}`);
    }
    if (fs.statSync(evidencePath).size === 0) usage(`Evidence file is empty: ${options.evidence}`);
    task.partial_evidence = path.relative(repoRoot, evidencePath).split(path.sep).join('/');
  }
}

task.state = options.state;
task.last_verified = new Date().toISOString().slice(0, 10);
if (options.note) task.evidence_note = options.note;
board.updated = task.last_verified;

const output = `${JSON.stringify(board, null, 2)}\n`;
if (options.dryRun) {
  process.stdout.write(output);
} else {
  fs.writeFileSync(boardPath, output, 'utf8');
  console.log(`Updated ${options.task} -> ${options.state}`);
  console.log(`Board: ${path.relative(repoRoot, boardPath)}`);
}
