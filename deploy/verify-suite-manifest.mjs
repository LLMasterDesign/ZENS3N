#!/usr/bin/env node

import fs from 'node:fs';
import process from 'node:process';
import { createHash } from 'node:crypto';

const root = new URL('..', import.meta.url);
const manifestPath = new URL('../suite-manifest.json', import.meta.url);
const args = process.argv.slice(2);
const options = {};
for (let index = 0; index < args.length; index += 1) {
  const arg = args[index];
  if (!arg.startsWith('--')) throw new Error(`Unknown argument: ${arg}`);
  const key = arg.slice(2).replaceAll('-', '_');
  const value = args[index + 1];
  if (!value || value.startsWith('--')) throw new Error(`Missing value for ${arg}`);
  options[key] = value;
  index += 1;
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const failures = [];
const requireField = (condition, message) => { if (!condition) failures.push(message); };
const nodes = Array.isArray(manifest.nodes) ? manifest.nodes : [];
const names = new Set(nodes.map((node) => node.service));
const ports = new Set();
const batchMembers = new Set();

requireField(manifest.authoritative === true, 'manifest must declare authoritative=true');
requireField(manifest.schema === 'zensen-suite-manifest/v1', 'manifest schema is not zensen-suite-manifest/v1');
requireField(nodes.length > 0, 'manifest has no nodes');
requireField(names.size === nodes.length, 'manifest contains duplicate service names');
requireField(Object.keys(manifest.batches || {}).length > 0, 'manifest has no declared batches');

for (const node of nodes) {
  for (const field of ['service', 'kind', 'identity', 'owner', 'batch', 'role', 'state', 'private_network']) {
    requireField(node[field] !== undefined && node[field] !== '', `${node.service || '<unnamed>'} missing ${field}`);
  }
  if (node.state === 'active-staging') {
    requireField(node.service_id !== undefined && node.service_id !== '', `${node.service || '<unnamed>'} missing service_id`);
  }
  requireField(manifest.batches?.[node.batch]?.includes(node.service), `${node.service} is not listed in batch ${node.batch}`);
  requireField(node.private_network?.domain === manifest.network?.suite_private_domain, `${node.service} private domain mismatch`);
  if (node.port !== null) {
    requireField(Number.isInteger(node.port) && node.port > 0, `${node.service} has invalid port`);
    requireField(!ports.has(node.port), `duplicate port ${node.port}`);
    ports.add(node.port);
  }
}

for (const [batch, members] of Object.entries(manifest.batches || {})) {
  requireField(members.length >= 1, `${batch} is empty`);
  for (const member of members) {
    requireField(names.has(member), `${batch} references unknown node ${member}`);
    requireField(!batchMembers.has(member), `${member} is listed in more than one batch`);
    batchMembers.add(member);
  }
}
requireField(batchMembers.size === nodes.length, `batch membership covers ${batchMembers.size} of ${nodes.length} nodes`);

function baseUrl(value) {
  if (!value) return null;
  return value.endsWith('/') ? value.slice(0, -1) : value;
}

async function checkSurface(label, value) {
  const base = baseUrl(value);
  if (!base) return { label, state: 'not-requested' };
  const checks = [
    ['entry', '/', 200],
    ['health', '/healthz', 200],
    ['unknown-route', '/__atlas_manifest_probe__', 404],
  ];
  const results = [];
  for (const [name, path, expected] of checks) {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 8000);
    try {
      const response = await fetch(`${base}${path}`, {redirect: 'manual', signal: controller.signal});
      const body = await response.text();
      requireField(response.status === expected, `${label} ${name}: expected ${expected}, got ${response.status}`);
      if (name === 'health') requireField(body.trim() === 'ok', `${label} health body is not ok`);
      results.push({name, status: response.status});
    } catch (error) {
      failures.push(`${label} ${name}: ${error.message}`);
      results.push({name, error: error.message});
    } finally {
      clearTimeout(timer);
    }
  }
  return {label, url: base, state: results.every((result) => result.status) ? 'passed' : 'failed', checks: results};
}

const surfaces = [];
surfaces.push(await checkSurface('local', options.local || manifest.project.local_url));
surfaces.push(await checkSurface('tailscale', options.tailscale || manifest.project.tailscale_url));
surfaces.push(await checkSurface('railway', options.railway || manifest.project.suite_staging_url));
if (options.satellite) surfaces.push(await checkSurface('3ox.studio', options.satellite));

const raw = fs.readFileSync(manifestPath);
const receipt = {
  manifest: 'suite-manifest.json',
  sha256: createHash('sha256').update(raw).digest('hex'),
  node_count: nodes.length,
  state_counts: Object.fromEntries([...new Set(nodes.map((node) => node.state))].map((state) => [state, nodes.filter((node) => node.state === state).length])),
  gates: manifest.gates,
  surfaces,
  status: failures.length ? 'failed' : 'passed',
  failures,
};
console.log(JSON.stringify(receipt, null, 2));
if (failures.length) process.exit(1);
