import http from 'k6/http';
import { check, sleep } from 'k6';

const target = __ENV.TARGET;
if (!target) throw new Error('Set TARGET to an owned ZENSEN URL before running the test.');
if (__ENV.ARMED !== 'yes') throw new Error('Capacity test is safety-armed. Set ARMED=yes during the approved test window.');

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
