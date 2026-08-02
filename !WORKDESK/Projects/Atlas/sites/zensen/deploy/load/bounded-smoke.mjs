#!/usr/bin/env node

import { performance } from 'node:perf_hooks';

const target = process.env.TARGET;
const requests = Number(process.env.REQUESTS || 100);
const concurrency = Number(process.env.CONCURRENCY || 10);
const timeoutMs = Number(process.env.TIMEOUT_MS || 10000);

function die(message) {
  console.error(`bounded-smoke: ${message}`);
  process.exit(2);
}

if (!target) die('set TARGET to an owned local or Tailscale URL');
let targetUrl;
try {
  targetUrl = new URL(target);
} catch {
  die('TARGET must be a valid URL');
}

if (!['http:', 'https:'].includes(targetUrl.protocol)) die('TARGET must use HTTP or HTTPS');
const host = targetUrl.hostname.toLowerCase();
const ownedHost = host === 'localhost' || host === '127.0.0.1' || host === '::1' || host.endsWith('.ts.net');
if (!ownedHost) die('TARGET is safety-bounded to localhost or a Tailscale .ts.net host');
if (!Number.isInteger(requests) || requests < 1 || requests > 1000) die('REQUESTS must be an integer from 1 to 1000');
if (!Number.isInteger(concurrency) || concurrency < 1 || concurrency > 50) die('CONCURRENCY must be an integer from 1 to 50');
if (!Number.isInteger(timeoutMs) || timeoutMs < 100 || timeoutMs > 60000) die('TIMEOUT_MS must be an integer from 100 to 60000');

const samples = [];
let next = 0;

async function worker() {
  while (true) {
    const index = next++;
    if (index >= requests) return;
    const started = performance.now();
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    try {
      const response = await fetch(targetUrl, { signal: controller.signal });
      const body = await response.text();
      samples[index] = {
        status: response.status,
        ms: performance.now() - started,
        bytes: Buffer.byteLength(body),
        contains_zensen: body.includes('ZENSEN'),
      };
    } catch (error) {
      samples[index] = {
        status: 0,
        ms: performance.now() - started,
        error: error instanceof Error ? error.message : String(error),
      };
    } finally {
      clearTimeout(timer);
    }
  }
}

const started = performance.now();
await Promise.all(Array.from({ length: Math.min(concurrency, requests) }, worker));
const elapsed = performance.now() - started;
const durations = samples.map(sample => sample.ms).sort((a, b) => a - b);
const percentile = fraction => durations[Math.min(durations.length - 1, Math.floor((durations.length - 1) * fraction))];
const successes = samples.filter(sample => sample.status >= 200 && sample.status < 300).length;
const containsZensen = samples.filter(sample => sample.contains_zensen).length;
const statuses = Object.fromEntries([...new Set(samples.map(sample => sample.status))].sort((a, b) => a - b).map(status => [status, samples.filter(sample => sample.status === status).length]));
const mean = durations.reduce((sum, value) => sum + value, 0) / durations.length;

const result = {
  target,
  requests,
  concurrency,
  successes,
  failures: requests - successes,
  contains_zensen: containsZensen,
  statuses,
  mean_ms: Number(mean.toFixed(2)),
  p50_ms: Number(percentile(0.50).toFixed(2)),
  p95_ms: Number(percentile(0.95).toFixed(2)),
  p99_ms: Number(percentile(0.99).toFixed(2)),
  max_ms: Number(Math.max(...durations).toFixed(2)),
  elapsed_ms: Number(elapsed.toFixed(2)),
  all_2xx: successes === requests,
  all_contain_zensen: containsZensen === requests,
};

console.log(JSON.stringify(result, null, 2));
if (!result.all_2xx || !result.all_contain_zensen) process.exitCode = 1;
