import http from "k6/http";
import { check, sleep } from "k6";
import {
  randomIntBetween,
  randomString,
  randomItem,
  uuidv4,
  findBetween,
} 
// @ts-ignore
from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';
import {generateRandomUserAgent} from './utils/agent.ts';

const duration = __ENV.DURATION ?? '30s';
let target = __ENV.TARGET ?? 2;
if(typeof target === 'string') {
  target = parseInt(target);
}

// Test configuration
export const options = {
  discardResponseBodies: true,
  scenarios: {
    constant: {
      executor: 'constant-arrival-rate',
      duration,
      preAllocatedVUs: Math.max(2, target/2),
      rate: target,
      maxVUs: target,
      timeUnit: '1s'
    }
  }
};

const URL = __ENV.URL;

const randomizeUrl = __ENV.RANDOMIZE === 'true';

// Simulated user behavior
export default function () {
  let u = URL;
  if(randomizeUrl) {
    const path = Array.from({length: randomIntBetween(1,4)}, (_, i) => randomString(randomIntBetween(2,10))).join('/');
    u = `${u}/${path}`;
  }
  http.get(u, {
    headers: {
      'User-Agent': generateRandomUserAgent()
    }
  });
}