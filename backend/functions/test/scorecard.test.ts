import { describe, expect, it } from 'vitest';

import { computeFeatures } from '../src/scoring/features';
import {
  bandFor,
  MAX_SCORE,
  MIN_SCORE,
  scoreBorrower,
  WEIGHTS,
} from '../src/scoring/scorecard';
import { Transaction, Verification } from '../src/scoring/types';

const NOW = new Date('2026-11-15T00:00:00Z');
const FULL: Verification = { idVerified: true, bankConnected: true, documentsVerified: true };
const NONE: Verification = { idVerified: false, bankConnected: false, documentsVerified: false };

/** Builds [months] of activity ending in November 2026. */
function history(
  months: number,
  opts: { income: number; spendShare: number; payBills: boolean; jitter?: number },
): Transaction[] {
  const txs: Transaction[] = [];
  let balance = 50_000;
  for (let i = months - 1; i >= 0; i--) {
    const d = new Date(Date.UTC(2026, 10 - i, 5));
    const ym = d.toISOString().slice(0, 7);
    const income = opts.income * (1 + (opts.jitter ?? 0) * (i % 2 === 0 ? 1 : -1));
    balance += income;
    txs.push({ date: `${ym}-05`, amount: income, direction: 'in', category: 'salary', balanceAfter: balance });
    const spend = income * opts.spendShare;
    balance -= spend;
    txs.push({ date: `${ym}-12`, amount: spend, direction: 'out', category: 'merchant', balanceAfter: balance });
    if (opts.payBills) {
      balance -= 5_000;
      txs.push({ date: `${ym}-20`, amount: 5_000, direction: 'out', category: 'bill', balanceAfter: balance });
    }
  }
  return txs;
}

describe('weights', () => {
  it('add up to 1 so scores stay between 300 and 1000', () => {
    const total = Object.values(WEIGHTS).reduce((a, b) => a + b, 0);
    expect(total).toBeCloseTo(1, 10);
  });
});

describe('bandFor', () => {
  it.each([
    [300, 'poor'],
    [579, 'poor'],
    [580, 'fair'],
    [670, 'good'],
    [742, 'veryGood'],
    [800, 'exceptional'],
    [1000, 'exceptional'],
  ])('%i is %s', (score, band) => expect(bandFor(score)).toBe(band));
});

describe('computeFeatures', () => {
  it('measures steady income as regular', () => {
    const f = computeFeatures(history(12, { income: 300_000, spendShare: 0.7, payBills: true }), NOW);
    expect(f.historyMonths).toBe(12);
    expect(f.inflowVariation).toBeCloseTo(0, 5);
    expect(f.billPaymentRatio).toBe(1);
    expect(f.netFlowRatio).toBeGreaterThan(0);
  });

  it('handles an empty account', () => {
    expect(computeFeatures([], NOW).transactionCount).toBe(0);
  });
});

describe('scoreBorrower', () => {
  it('asks for more data when history is too short', () => {
    const r = scoreBorrower(history(2, { income: 300_000, spendShare: 0.7, payBills: true }), FULL, NOW);
    expect(r.assessmentStatus).toBe('needsInfo');
    expect(r.value).toBeNull();
  });

  it('scores a steady saver highly', () => {
    const r = scoreBorrower(history(18, { income: 400_000, spendShare: 0.6, payBills: true }), FULL, NOW);
    expect(r.assessmentStatus).toBe('complete');
    expect(r.value!).toBeGreaterThanOrEqual(740);
  });

  it('scores an erratic overspender lower than a steady saver', () => {
    const good = scoreBorrower(history(12, { income: 300_000, spendShare: 0.7, payBills: true }), FULL, NOW);
    const weak = scoreBorrower(
      history(12, { income: 60_000, spendShare: 1.05, payBills: false, jitter: 0.9 }),
      NONE,
      NOW,
    );
    expect(weak.value!).toBeLessThan(good.value!);
    expect(weak.value!).toBeGreaterThanOrEqual(MIN_SCORE);
    expect(good.value!).toBeLessThanOrEqual(MAX_SCORE);
  });

  it('returns factors in the shape the app reads, strongest first', () => {
    const r = scoreBorrower(history(12, { income: 300_000, spendShare: 0.7, payBills: true }), FULL, NOW);
    expect(r.factors).toHaveLength(6);
    for (const f of r.factors) {
      expect(f.title).toBeTruthy();
      expect(['HIGH', 'GOOD', 'FAIR', 'LOW']).toContain(f.levelLabel);
      expect(f.progress).toBeGreaterThanOrEqual(0);
      expect(f.progress).toBeLessThanOrEqual(1);
    }
    const points = r.factors.map((f) => f.points);
    expect(points).toEqual([...points].sort((a, b) => b - a));
  });

  it('factor points add up to the score above 300', () => {
    const r = scoreBorrower(history(12, { income: 300_000, spendShare: 0.7, payBills: true }), FULL, NOW);
    const sum = r.factors.reduce((a, f) => a + f.points, 0);
    expect(Math.abs(MIN_SCORE + sum - r.value!)).toBeLessThanOrEqual(3);
  });
});
