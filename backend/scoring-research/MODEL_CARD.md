# Credit Passport scoring model — rules-v1

Owner: Abdull-Kudus. Code: `backend/api/src/scoring/`.

## What it does

Turns 12 months of MTN MoMo transactions (plus identity and data
verification) into a **300–1000 Credit Passport score**, a band, and six
plain-language factors shown on C03_Breakdown.

Staki Fund does not lend. The score is one input; the regulated lender makes
the credit decision.

## Inputs (features)

| Feature | Meaning |
|---|---|
| `historyMonths` | Months since the first transaction (max 24) |
| `netFlowRatio` | (inflow − outflow) ÷ inflow over the window |
| `inflowVariation` | Coefficient of variation of monthly inflows |
| `billPaymentRatio` | Share of months with a bill or airtime payment |
| `balanceTrend` | Month-on-month change of month-end balance ÷ mean balance |
| `balanceBuffer` | Average month-end balance ÷ average monthly inflow |
| Verification | NIDA ID verified, bank connected, documents verified |

## Scorecard

Each factor becomes a 0–1 sub-score; the score is

```
score = 300 + 700 × Σ (weight × sub-score)
```

| Factor | Weight | Sub-score |
|---|---|---|
| Cash-flow strength | 0.25 | net flow −10% → 0, +30% → 1 |
| Income regularity | 0.20 | 1 − variation ÷ 0.6 |
| Payment consistency | 0.20 | bill/airtime months ÷ months |
| Balance trend | 0.15 | ½ trend (−10%/mo → 0, +10%/mo → 1) + ½ buffer (1 month of income → 1) |
| History length | 0.10 | months ÷ 18 |
| Identity & data | 0.10 | ID 0.5 + bank 0.3 + documents 0.2 |

Weights add up to 1, so every score stays between 300 and 1000, and each
factor's `points` add up to the score above 300 (this is what makes the
breakdown honest).

**Bands:** Poor 300–579 · Fair 580–669 · Good 670–739 · Very Good 740–799 ·
Exceptional 800–1000.

**Not enough data:** fewer than 3 months or 10 transactions returns
`assessmentStatus: needsInfo` with no score (edge cases E15 / E24), instead of
a misleadingly low number.

## Design decisions

1. **Rules first, ML later.** Every point can be explained to a borrower and a
   regulator. A trained model (v2) will be compared against this one and must
   beat it before it replaces it; v1 stays as the fallback.
2. **Income size is not scored.** A disciplined low earner is as creditworthy
   as a high earner with the same habits. How much someone may borrow is
   decided by affordability in the eligibility engine, not by the score.
3. **New accounts are not punished for months they did not exist.** Features
   only use the months since the account started.
4. **An empty wallet is not "stable".** A balance flat at zero scores low via
   the buffer term, even though its trend is flat.

## Calibration (synthetic data)

`python generate_synthetic.py` creates 600 borrowers (seed 42) across the five
borrower types, each with a hidden profile (strong / average / weak).
`npm test` in `backend/api` scores them and checks:

| Check | Result (rules-v1) |
|---|---|
| Every band is used | Poor 109 · Fair 50 · Good 62 · Very Good 110 · Exceptional 149 |
| Profiles ranked correctly | strong 914 > average 752 > weak 551 |
| Fairness by type (same profile, gap from mean ≤ 120) | MSME +20 · Startup +10 · Student −47 · Salaried +13 · Other 0 |

Calibration history:
- First run: weak borrowers averaged 732. Cause: a generator bug (deposits
  summed to ~2× income) and flat-zero balances earning half marks. Fixed both.
- Second run: students 66 points below average because income size was
  scored. Removed income size (decision 2).

## Known limitations

- Trained and checked on **synthetic** data only; real MoMo data will need
  re-calibration before launch.
- Students still sit ~47 points lower in synthetic data because fixed bill
  amounts take a larger share of a small income. Monitor with real data.
- No bank transaction data yet; bank only counts as "connected".
- Rules cannot capture interactions between factors; v2 (gradient boosting)
  will be tested for this.
