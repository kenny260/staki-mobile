import { computeFeatures } from './features';
import {
  Factor,
  FactorLevel,
  Features,
  ScoreBand,
  ScoreResult,
  Transaction,
  Verification,
} from './types';

export const MODEL_VERSION = 'rules-v1';
export const MIN_SCORE = 300;
export const MAX_SCORE = 1000;

/**
 * How much each factor counts. They add up to 1, so a borrower who maxes
 * every factor gets 1000 and one who scores zero everywhere gets 300.
 * Tuned offline in backend/scoring-research (see weights.md there).
 */
export const WEIGHTS = {
  cashFlow: 0.25,
  regularity: 0.2,
  payments: 0.2,
  balance: 0.15,
  history: 0.1,
  verification: 0.1,
} as const;

export type FactorId = keyof typeof WEIGHTS;

/** Below this much history we cannot score fairly, so we ask for more data. */
export const MIN_HISTORY_MONTHS = 3;
export const MIN_TRANSACTIONS = 10;

const clamp01 = (x: number) => Math.max(0, Math.min(1, x));

/** Scales x from [lo, hi] to [0, 1]. */
const scale = (x: number, lo: number, hi: number) => clamp01((x - lo) / (hi - lo));

/** Each factor as a 0 to 1 sub-score. */
export function subScores(f: Features, v: Verification): Record<FactorId, number> {
  // Income SIZE is deliberately not scored: a disciplined low earner (e.g. a
  // student) is as creditworthy as a high earner with the same habits. How
  // much someone can borrow is decided later by affordability (eligibility).
  return {
    // Keeping more than you spend: net flow -10% = 0, +30% or more = 1.
    cashFlow: scale(f.netFlowRatio, -0.1, 0.3),
    // Coefficient of variation 0 = same income every month, 0.6+ = erratic.
    regularity: clamp01(1 - f.inflowVariation / 0.6),
    // Paying bills or airtime every month.
    payments: clamp01(f.billPaymentRatio),
    // Half trend (shrinking 10%/month = 0, growing 10%/month = 1), half
    // buffer (balance worth a full month of income = 1). A wallet that
    // sits empty scores low even though its "trend" is flat.
    balance: 0.5 * scale(f.balanceTrend, -0.1, 0.1) + 0.5 * clamp01(f.balanceBuffer),
    // 18 months of history earns the full sub-score.
    history: clamp01(f.historyMonths / 18),
    verification:
      (v.idVerified ? 0.5 : 0) + (v.bankConnected ? 0.3 : 0) + (v.documentsVerified ? 0.2 : 0),
  };
}

/** Band thresholds agreed in the team plan. */
export function bandFor(score: number): ScoreBand {
  if (score >= 800) return 'exceptional';
  if (score >= 740) return 'veryGood';
  if (score >= 670) return 'good';
  if (score >= 580) return 'fair';
  return 'poor';
}

export function levelFor(sub: number): FactorLevel {
  if (sub >= 0.8) return 'HIGH';
  if (sub >= 0.6) return 'GOOD';
  if (sub >= 0.4) return 'FAIR';
  return 'LOW';
}

const COPY: Record<FactorId, { title: string; good: string; weak: string; improve: string }> = {
  cashFlow: {
    title: 'Cash-flow strength',
    good: 'You keep part of what comes in each month.',
    weak: 'Spending is close to, or above, what comes in.',
    improve: 'Keep a little of each month’s income in your wallet.',
  },
  regularity: {
    title: 'Income regularity',
    good: 'Your income arrives at a steady level every month.',
    weak: 'Your income changes a lot from month to month.',
    improve: 'Receive payments through MoMo regularly, not in one large lump.',
  },
  payments: {
    title: 'Payment consistency',
    good: 'You pay bills or airtime from MoMo almost every month.',
    weak: 'Few regular bill or airtime payments were found.',
    improve: 'Pay utilities and airtime from your MoMo wallet each month.',
  },
  balance: {
    title: 'Balance trend',
    good: 'Your wallet balance has been growing.',
    weak: 'Your wallet balance has been shrinking.',
    improve: 'Avoid emptying your wallet every month.',
  },
  history: {
    title: 'History length',
    good: 'You have a long record of MoMo activity.',
    weak: 'Your MoMo history is still short.',
    improve: 'Keep using your account; longer history raises this factor.',
  },
  verification: {
    title: 'Identity & data',
    good: 'Your ID is verified and extra data is connected.',
    weak: 'Some identity or bank data is still missing.',
    improve: 'Connect a bank account and upload your documents.',
  },
};

/** Builds the explained factor list, strongest contribution first. */
export function explain(subs: Record<FactorId, number>): Factor[] {
  return (Object.keys(WEIGHTS) as FactorId[])
    .map((id) => {
      const sub = subs[id];
      const c = COPY[id];
      const level = levelFor(sub);
      const strong = level === 'HIGH' || level === 'GOOD';
      return {
        id,
        title: c.title,
        levelLabel: level,
        progress: Math.round(sub * 100) / 100,
        points: Math.round(WEIGHTS[id] * sub * (MAX_SCORE - MIN_SCORE)),
        summary: strong ? c.good : c.weak,
        helped: strong ? c.good : 'Some activity was found, which counts in your favour.',
        improve: c.improve,
      };
    })
    .sort((a, b) => b.points - a.points);
}

/** Full pipeline: transactions in, Credit Passport out. */
export function scoreBorrower(
  txs: Transaction[],
  verification: Verification,
  now: Date = new Date(),
): ScoreResult {
  const f = computeFeatures(txs, now);
  if (f.historyMonths < MIN_HISTORY_MONTHS || f.transactionCount < MIN_TRANSACTIONS) {
    return {
      assessmentStatus: 'needsInfo',
      value: null,
      band: null,
      factors: [],
      modelVersion: MODEL_VERSION,
    };
  }
  const subs = subScores(f, verification);
  const weighted = (Object.keys(WEIGHTS) as FactorId[]).reduce(
    (sum, id) => sum + WEIGHTS[id] * subs[id],
    0,
  );
  const value = Math.round(MIN_SCORE + weighted * (MAX_SCORE - MIN_SCORE));
  return {
    assessmentStatus: 'complete',
    value,
    band: bandFor(value),
    factors: explain(subs),
    modelVersion: MODEL_VERSION,
  };
}
