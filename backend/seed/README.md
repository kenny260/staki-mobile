# Seed data

Scripts that load demo and staging data into Firestore (Uche).
Never put real personal data here.

- `data.js` - the demo records. Values match the app's mock repositories.
- `seed.js` - writes them to Firestore and creates the demo logins.

The data model and ERD are in [`../docs/data-model.md`](../docs/data-model.md).

## Run it

```bash
cd backend/seed
npm install
npm run seed:dry        # preview, writes nothing
npm run seed            # real project staki-bc71f
npm run seed:emulator   # local emulators instead
```

`npm run seed` needs a service account key:
Firebase console > Project settings > Service accounts >
**Generate new private key**, saved as `backend/seed/serviceAccount.json`.
The file is gitignored. Never commit or share it.

Running it again is safe: the same IDs are overwritten.

## Demo accounts

| Role | Email | Password |
| --- | --- | --- |
| Borrower | borrower@staki.demo | StakiDemo123! |
| Lender | lender@staki.demo | StakiDemo123! |

These are demo-only accounts with fake data.

## What gets loaded

- Borrower: profile (Kigali Fresh Market), 3 documents (verified, needs
  attention, under review), MoMo consent and wallet, credit score 742,
  one active Bank of Kigali loan (RWF 500,000, 6 months, 3 repayments),
  2 notifications.
- Lender: verified individual lender with RWF 5,000,000 wallet,
  3 fundings (one late), 3 ledger entries, 5 notifications.
- Marketplace: opportunities OPP-1042, OPP-0891, OPP-1095, OPP-0777.
