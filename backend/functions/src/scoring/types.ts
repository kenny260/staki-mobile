/** One mobile-money transaction, as stored under momoAccounts/{uid}/transactions. */
export interface Transaction {
  /** ISO date, e.g. "2026-06-24". */
  date: string;
  /** Amount in RWF, always positive. */
  amount: number;
  direction: 'in' | 'out';
  category: 'transfer' | 'salary' | 'merchant' | 'bill' | 'airtime' | 'cashout';
  /** Wallet balance right after this transaction, in RWF. */
  balanceAfter: number;
}

/** Non-transaction signals that also feed the score. */
export interface Verification {
  idVerified: boolean;
  bankConnected: boolean;
  documentsVerified: boolean;
}

/** Behaviour measured from the transactions (see features.ts). */
export interface Features {
  /** Months from the first transaction to now, capped at 24. */
  historyMonths: number;
  transactionCount: number;
  avgMonthlyInflow: number;
  /** Coefficient of variation of monthly inflows (0 = perfectly regular). */
  inflowVariation: number;
  /** (inflow - outflow) / inflow over the window, -1 to 1. */
  netFlowRatio: number;
  /** Share of months with at least one bill or airtime payment, 0 to 1. */
  billPaymentRatio: number;
  /** Month-on-month change of month-end balance, relative to the mean. */
  balanceTrend: number;
  /** Average month-end balance divided by average monthly inflow. */
  balanceBuffer: number;
}

export type ScoreBand = 'poor' | 'fair' | 'good' | 'veryGood' | 'exceptional';
export type FactorLevel = 'HIGH' | 'GOOD' | 'FAIR' | 'LOW';

/** One explained factor, in the shape the app's C03 breakdown reads. */
export interface Factor {
  id: string;
  title: string;
  levelLabel: FactorLevel;
  /** Sub-score, 0 to 1. Drawn as the progress bar. */
  progress: number;
  /** Points this factor adds above the 300 floor. */
  points: number;
  summary: string;
  helped: string;
  improve: string;
}

/** The document written to scores/{uid}. */
export interface ScoreResult {
  assessmentStatus: 'complete' | 'needsInfo';
  value: number | null;
  band: ScoreBand | null;
  factors: Factor[];
  modelVersion: string;
}
