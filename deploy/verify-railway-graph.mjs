#!/usr/bin/env node

import fs from 'node:fs';
import process from 'node:process';
import { execFileSync } from 'node:child_process';

const manifestPath = new URL('../suite-manifest.json', import.meta.url);
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const failures = [];
const runRailway = (args) => JSON.parse(execFileSync('railway', args, {encoding: 'utf8'}));
const requireField = (condition, message) => { if (!condition) failures.push(message); };

const services = runRailway(['service', 'list', '--json']);
const serviceMap = new Map(services.map((service) => [service.name, service]));
const status = runRailway(['status', '--json']);
const instances = status.environments.edges[0].node.serviceInstances.edges.map((edge) => edge.node);
const instanceMap = new Map(instances.map((instance) => [instance.serviceName, instance]));

requireField(services.length === manifest.nodes.length, `Railway service count ${services.length} does not match manifest ${manifest.nodes.length}`);
const expectedNames = new Set(manifest.nodes.map((node) => node.service));
for (const service of services) requireField(expectedNames.has(service.name), `unexpected Railway service ${service.name}`);

const checked = [];
for (const node of manifest.nodes) {
  const service = serviceMap.get(node.service);
  requireField(Boolean(service), `${node.service} is missing from Railway service list`);
  if (!service) continue;
  requireField(service.id === node.service_id, `${node.service} service id drift: ${service.id}`);
  const variables = runRailway(['variable', 'list', '--service', node.service, '--json']);
  const required = {
    ZENSEN_NODE: node.identity,
    ZENSEN_OWNER: node.owner,
    ZENSEN_BATCH: node.batch,
    ZENSEN_ROLE: node.role,
    ZENSEN_STATE: node.state,
    ZENSEN_PRIVATE_NETWORK: manifest.network.suite_private_domain,
    ZENSEN_SUITE_PRIVATE_DOMAIN: manifest.network.suite_private_domain,
  };
  if (node.port !== null) required.ZENSEN_PORT = String(node.port);
  for (const [key, expected] of Object.entries(required)) {
    requireField(variables[key] === expected, `${node.service} ${key}: expected ${expected}, got ${variables[key] ?? '<missing>'}`);
  }
  const instance = instanceMap.get(node.service);
  if (node.source?.repository) {
    requireField(instance?.source?.repo === node.source.repository, `${node.service} source repo is not ${node.source.repository}`);
    requireField(instance?.latestDeployment?.status === 'SUCCESS', `${node.service} latest deployment is not SUCCESS`);
  }
  checked.push({service: node.service, state: node.state, port: node.port, latest_deployment: instance?.latestDeployment?.status ?? null});
}

const receipt = {
  manifest: 'suite-manifest.json',
  node_count: manifest.nodes.length,
  railway_service_count: services.length,
  checked,
  status: failures.length ? 'failed' : 'passed',
  failures,
};
console.log(JSON.stringify(receipt, null, 2));
if (failures.length) process.exit(1);
