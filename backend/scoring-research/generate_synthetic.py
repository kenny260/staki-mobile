"""Generate synthetic MTN MoMo histories for designing and testing the score.

No real personal data is used. Each borrower gets 1 to 24 months of
transactions whose behaviour (income level, regularity, spending, bill
payments) depends on a hidden "risk profile", so the scorecard can be
checked against a known ground truth.

Usage:
    python generate_synthetic.py            # 600 borrowers, seed 42
    python generate_synthetic.py 1000 7     # 1000 borrowers, seed 7

Output: synthetic_users.json (git-ignored, regenerate any time).
"""

import json
import random
import sys
from datetime import date

TYPES = ["msme", "startup", "student", "salaried", "other"]

# Typical monthly MoMo inflow in RWF per borrower type (median).
INCOME = {
    "msme": 320_000,
    "startup": 450_000,
    "student": 45_000,
    "salaried": 780_000,
    "other": 200_000,
}

# Hidden behaviour profiles: (share, spend ratio, income jitter, bill prob).
PROFILES = {
    "strong": (0.30, (0.55, 0.80), 0.10, 0.95),
    "average": (0.40, (0.80, 0.97), 0.30, 0.70),
    "weak": (0.30, (0.95, 1.15), 0.70, 0.30),
}

TODAY = date(2026, 11, 15)


def month_start(months_ago: int) -> date:
    y, m = TODAY.year, TODAY.month - months_ago
    while m <= 0:
        m += 12
        y -= 1
    return date(y, m, 1)


def pick_profile(rng: random.Random) -> str:
    r, acc = rng.random(), 0.0
    for name, (share, *_rest) in PROFILES.items():
        acc += share
        if r <= acc:
            return name
    return "average"


def make_user(i: int, rng: random.Random) -> dict:
    btype = rng.choice(TYPES)
    profile = pick_profile(rng)
    _, spend_range, jitter, bill_p = PROFILES[profile]
    base = INCOME[btype] * rng.lognormvariate(0, 0.35)
    months = rng.choice([1, 2, 4, 6, 9, 12, 12, 15, 18, 24])
    balance = rng.uniform(5_000, 80_000)
    txs = []

    for ago in range(months - 1, -1, -1):
        start = month_start(ago)
        income = max(0.0, base * (1 + rng.uniform(-jitter, jitter)))
        # Split income into 1 to 4 deposits that add up to about [income].
        parts = rng.randint(1, 4)
        for _ in range(parts):
            amt = round(income / parts * rng.uniform(0.8, 1.2), -2)
            balance += amt
            day = rng.randint(1, 27)
            txs.append(tx(start, day, amt, "in", "salary" if btype == "salaried" else "transfer", balance))
        spend = income * rng.uniform(*spend_range)
        outs = rng.randint(2, 6)
        for _ in range(outs):
            amt = round(spend / outs * rng.uniform(0.8, 1.2), -2)
            balance = max(0.0, balance - amt)
            txs.append(tx(start, rng.randint(1, 27), amt, "out", rng.choice(["merchant", "cashout", "transfer"]), balance))
        if rng.random() < bill_p:
            amt = round(rng.uniform(2_000, 15_000), -2)
            balance = max(0.0, balance - amt)
            txs.append(tx(start, rng.randint(1, 27), amt, "out", rng.choice(["bill", "airtime"]), balance))

    txs.sort(key=lambda t: t["date"])
    return {
        "id": f"syn-{i:04d}",
        "type": btype,
        "profile": profile,
        "verification": {
            "idVerified": rng.random() < 0.9,
            "bankConnected": rng.random() < (0.6 if profile == "strong" else 0.3),
            "documentsVerified": rng.random() < 0.6,
        },
        "transactions": txs,
    }


def tx(start: date, day: int, amount: float, direction: str, category: str, balance: float) -> dict:
    return {
        "date": date(start.year, start.month, day).isoformat(),
        "amount": amount,
        "direction": direction,
        "category": category,
        "balanceAfter": round(balance, 2),
    }


def main() -> None:
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 600
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 42
    rng = random.Random(seed)
    users = [make_user(i, rng) for i in range(n)]
    with open("synthetic_users.json", "w", encoding="utf-8") as f:
        json.dump(users, f)
    txs = sum(len(u["transactions"]) for u in users)
    print(f"Wrote {n} borrowers, {txs} transactions to synthetic_users.json")


if __name__ == "__main__":
    main()
