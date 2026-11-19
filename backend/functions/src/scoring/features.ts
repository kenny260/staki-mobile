import { Features, Transaction } from './types';

/** Window the score looks at. */
export const WINDOW_MONTHS = 12;

const monthKey = (date: string) => date.slice(0, 7); // "2026-06"

function monthsBetween(from: Date, to: Date): number {
  return (
    (to.getUTCFullYear() - from.getUTCFullYear()) * 12 +
    (to.getUTCMonth() - from.getUTCMonth())
  );
}

/** The last [count] month keys ending at [now], oldest first. */
export function lastMonths(now: Date, count: number): string[] {
  const keys: string[] = [];
  for (let i = count - 1; i >= 0; i--) {
    const d = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() - i, 1));
    keys.push(d.toISOString().slice(0, 7));
  }
  return keys;
}

function mean(xs: number[]): number {
  return xs.length === 0 ? 0 : xs.reduce((a, b) => a + b, 0) / xs.length;
}

function stdDev(xs: number[]): number {
  const m = mean(xs);
  return Math.sqrt(mean(xs.map((x) => (x - m) ** 2)));
}

/** Least-squares slope of ys against 0, 1, 2 ... */
function slope(ys: number[]): number {
  const n = ys.length;
  if (n < 2) return 0;
  const xMean = (n - 1) / 2;
  const yMean = mean(ys);
  let num = 0;
  let den = 0;
  ys.forEach((y, x) => {
    num += (x - xMean) * (y - yMean);
    den += (x - xMean) ** 2;
  });
  return num / den;
}

/**
 * Turns raw mobile-money transactions into the behaviour signals the
 * scorecard uses. Only the last [WINDOW_MONTHS] months count, and only the
 * months since the account started (a new account is not punished for
 * months it did not exist).
 */
export function computeFeatures(txs: Transaction[], now: Date): Features {
  if (txs.length === 0) {
    return {
      historyMonths: 0,
      transactionCount: 0,
      avgMonthlyInflow: 0,
      inflowVariation: 0,
      netFlowRatio: 0,
      billPaymentRatio: 0,
      balanceTrend: 0,
      balanceBuffer: 0,
    };
  }

  const sorted = [...txs].sort((a, b) => a.date.localeCompare(b.date));
  const first = new Date(`${sorted[0].date}T00:00:00Z`);
  const historyMonths = Math.min(24, monthsBetween(first, now) + 1);

  const active = Math.min(WINDOW_MONTHS, historyMonths);
  const months = lastMonths(now, active);
  const inWindow = sorted.filter((t) => months.includes(monthKey(t.date)));

  const inflow = new Map<string, number>(months.map((m) => [m, 0]));
  const hasBill = new Map<string, boolean>(months.map((m) => [m, false]));
  const endBalance = new Map<string, number>();
  let totalIn = 0;
  let totalOut = 0;

  for (const t of inWindow) {
    const m = monthKey(t.date);
    if (t.direction === 'in') {
      inflow.set(m, (inflow.get(m) ?? 0) + t.amount);
      totalIn += t.amount;
    } else {
      totalOut += t.amount;
      if (t.category === 'bill' || t.category === 'airtime') hasBill.set(m, true);
    }
    endBalance.set(m, t.balanceAfter); // sorted, so the last one wins
  }

  const monthlyIn = months.map((m) => inflow.get(m) ?? 0);
  const avgIn = mean(monthlyIn);

  // Carry the balance forward through months with no activity.
  const balances: number[] = [];
  let last = sorted[0].balanceAfter;
  for (const m of months) {
    last = endBalance.get(m) ?? last;
    balances.push(last);
  }
  const balMean = mean(balances);

  return {
    historyMonths,
    transactionCount: inWindow.length,
    avgMonthlyInflow: avgIn,
    inflowVariation: avgIn === 0 ? 1 : stdDev(monthlyIn) / avgIn,
    netFlowRatio: totalIn === 0 ? -1 : Math.max(-1, Math.min(1, (totalIn - totalOut) / totalIn)),
    billPaymentRatio: months.filter((m) => hasBill.get(m)).length / months.length,
    balanceTrend: balMean === 0 ? 0 : slope(balances) / balMean,
    balanceBuffer: avgIn === 0 ? 0 : balMean / avgIn,
  };
}
