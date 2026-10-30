# Staki Fund (Credit Passport)

Staki Fund is the product; the Credit Passport is the 300 to 1000 score it issues.
Flutter mobile app on Firebase, built screen-for-screen from the approved Figma.

- Figma prototype: https://www.figma.com/design/xggLWgTvOM5EErLe6kJGDt
- Design specs and tokens: https://www.figma.com/design/JksKsdPrH82niGSvQT3U0K

## Repository layout

```
frontend/   Flutter app (Clean Architecture: core / data / domain / presentation)
backend/    Firebase: Firestore and Storage rules, indexes, Cloud Functions, seed data
.github/    CI, PR template, CODEOWNERS
```

- Frontend work happens in `frontend/lib/presentation` and `frontend/lib/core`.
- Backend work happens in `backend/` and in `frontend/lib/data` and
  `frontend/lib/domain` (the code the app uses to talk to Firebase).

See `frontend/README.md` and `backend/README.md` for how to run each part.

## Branching and PRs

- `main` and `staging` are protected. Nobody pushes to them directly.
- Branch off `staging`, open a PR into `staging`, request a review from
  Abdull-Kudus or Binthia, with Uche (@EucTech) as backup. One approval is
  needed, and nobody merges their own PR. CI must be green.
- `main` only receives `staging` at release.
- Branch names: `<type>/<ticket>-<short-description>` (feature, fix, chore,
  docs, test, refactor). Example: `feature/STK-12-login-email-password`.
- Commits: conventional commits, small and often. Example:
  `feat(auth): add email/password login form`.

## Team

Frontend: Binthia (lead, repo, design system), Chris.
Backend: Uche (Firestore, rules), Tolu (auth, notifications),
Abdull-Kudus (credit scoring engine, report lead).
