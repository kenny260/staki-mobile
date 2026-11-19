import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';

import { scoreBorrower } from '../src/scoring/scorecard';
import { Transaction, Verification } from '../src/scoring/types';

interface SyntheticUser {
  id: string;
  type: string;
  profile: 'strong' | 'average' | 'weak';
  verification: Verification;
  transactions: Transaction[];
}

const FILE = join(__dirname, '../../scoring-research/synthetic_users.json');
const NOW = new Date('2026-11-15T00:00:00Z');

/**
 * Runs the scorecard over the synthetic dataset. Skipped when the file
 * has not been generated (run python generate_synthetic.py first).
 */
describe.skipIf(!existsSync(FILE))('synthetic dataset', () => {
  const users: SyntheticUser[] = existsSync(FILE) ? JSON.parse(readFileSync(FILE, 'utf8')) : [];
  const scored = users.map((u) => ({ u, r: scoreBorrower(u.transactions, u.verification, NOW) }));
  const complete = scored.filter((s) => s.r.assessmentStatus === 'complete');
  const avg = (xs: number[]) => xs.reduce((a, b) => a + b, 0) / xs.length;

  it('uses every band', () => {
    const bands = new Set(complete.map((s) => s.r.band));
    console.table(
      ['poor', 'fair', 'good', 'veryGood', 'exceptional'].map((b) => ({
        band: b,
        borrowers: complete.filter((s) => s.r.band === b).length,
      })),
    );
    expect(bands.size).toBe(5);
  });

  it('ranks hidden profiles in the right order', () => {
    const by = (p: string) => avg(complete.filter((s) => s.u.profile === p).map((s) => s.r.value!));
    console.table({ strong: by('strong'), average: by('average'), weak: by('weak') });
    expect(by('strong')).toBeGreaterThan(by('average'));
    expect(by('average')).toBeGreaterThan(by('weak'));
  });

  it('treats borrower types fairly at the same behaviour', () => {
    // Within the "average" profile, no borrower type should sit more than
    // 120 points from the overall mean just because of its type.
    const average = complete.filter((s) => s.u.profile === 'average');
    const overall = avg(average.map((s) => s.r.value!));
    const rows = ['msme', 'startup', 'student', 'salaried', 'other'].map((t) => {
      const v = average.filter((s) => s.u.type === t).map((s) => s.r.value!);
      return { type: t, n: v.length, mean: Math.round(avg(v)), gap: Math.round(avg(v) - overall) };
    });
    console.table(rows);
    for (const row of rows) expect(Math.abs(row.gap)).toBeLessThanOrEqual(120);
  });
});
