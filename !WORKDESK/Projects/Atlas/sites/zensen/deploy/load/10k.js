import http from 'k6/http';
import { check, sleep } from 'k6';

const target = __ENV.TARGET;
if (!target) throw new Error('Set TARGET to an owned ZENSEN URL before running the test.');
if (__ENV.ARMED !== 'yes') throw new Error('Capacity test is safety-armed. Set ARMED=yes during the approved test window.');
if (__ENV.APPROVED_TARGET !== 'yes') throw new Error('Set APPROVED_TARGET=yes only after the target and test window are approved.');
if (!__ENV.APPROVAL_REF) throw new Error('Set APPROVAL_REF to the launch decision, ticket, or incident record for this run.');
try {
  const targetUrl = new URL(target);
  if (!['http:', 'https:'].includes(targetUrl.protocol)) throw new Error('unsupported protocol');
} catch (error) {
  throw new Error(`TARGET must be a valid HTTP(S) URL: ${error.message}`);
}

export const options = {
  stages: [
    { duration: '5m', target: 1000 },
    { duration: '5m', target: 5000 },
    { duration: '5m', target: 10000 },
    { duration: '30m', target: 10000 },
    { duration: '5m', target: 0 },
  ],
  thresholds: {
    http_req_failed: ['rate<0.001'],
    http_req_duration: ['p(95)<750', 'p(99)<1500'],
    checks: ['rate>0.999'],
  },
};

export default function () {
  const response = http.get(target, { tags: { surface: 'zensen-homepage' } });
  check(response, {
    'HTTP 200': (res) => res.status === 200,
    'contains ZENSEN': (res) => res.body.includes('ZENSEN'),
  });
  sleep(1);
}
