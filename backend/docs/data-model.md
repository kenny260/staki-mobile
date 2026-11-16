# Staki Fund - Firestore data model

Owner: Uche. Database: Cloud Firestore `(default)` in `africa-south1`,
project `staki-bc71f`. Files (IDs, statements, selfies) are stored on
**Cloudinary**; Firestore only keeps their HTTPS link.

Fields come from the models the screens already use
(`frontend/lib/presentation/features/*/providers/*_models.dart`), so swapping
a mock repository for a Firestore one should not change any UI.

## Conventions

- Money is an **integer in RWF** (no decimals), e.g. `500000`.
- Dates are Firestore **timestamps** (`createdAt`, `updatedAt`, ...).
- Enums are stored as the Dart enum **name** string, e.g. `underReview`,
  `veryGood`, `momo`. Use `MyEnum.values.byName(...)` to read them.
- A document that belongs to one user is keyed by that user's Firebase Auth
  `uid`, or stores it in `userId` / `borrowerId` / `lenderId`.
- "Server" below means the Admin SDK (Cloud Functions or the seed script).
  Server writes skip security rules.

## ERD

```mermaid
erDiagram
    USERS ||--o| PROFILES : "has (borrower)"
    USERS ||--o{ DOCUMENTS : uploads
    USERS ||--o{ NOTIFICATIONS : receives
    USERS ||--o{ CONSENTS : grants
    USERS ||--o| MOMO_ACCOUNTS : connects
    USERS ||--o| SCORES : "is scored"
    USERS ||--o{ LOANS : "applies for"
    LOANS ||--o{ REPAYMENTS : "is repaid by"
    LOANS ||--o| OPPORTUNITIES : "is listed as"
    USERS ||--o| LENDERS : "is (lender)"
    LENDERS ||--o{ FUNDINGS : allocates
    OPPORTUNITIES ||--o{ FUNDINGS : "is funded by"
    LENDERS ||--o{ LEDGER : "wallet history"

    USERS {
        string uid PK
        string role "borrower | lender"
        string displayName
        string email
        string phone "9 digits, e.g. 788123456"
        string photoUrl "Cloudinary"
        string borrowerType "business | startup | student | salaried | other"
        bool onboardingComplete
        timestamp createdAt
        timestamp updatedAt
    }
    PROFILES {
        string uid PK "same as users uid"
        string borrowerType
        map answers "ProfileFields key -> value"
        timestamp updatedAt
    }
    DOCUMENTS {
        string documentType PK "national_id, momo_statement, ..."
        string fileName
        string url "Cloudinary"
        string publicId
        string resourceType
        int bytes
        string status "underReview | verified | needsAttention"
        string note
        timestamp uploadedAt
    }
    NOTIFICATIONS {
        string id PK
        string title
        string body
        string kind "success | info | warning | neutral | kyc"
        bool read
        timestamp createdAt
    }
    CONSENTS {
        string id PK
        string userId FK
        string type "momo"
        bool granted
        timestamp grantedAt
        timestamp revokedAt
    }
    MOMO_ACCOUNTS {
        string uid PK
        string maskedNumber "e.g. 078 *** **67"
        string status "connected | failed"
        bool eligible "server only"
        timestamp connectedAt
    }
    SCORES {
        string uid PK
        int value "300 - 1000"
        string band "poor | fair | good | veryGood | exceptional"
        string assessmentStatus "processing | needsInfo | complete | failed"
        array factors "title, levelLabel, progress, summary, helped, improve"
        timestamp updatedAt
    }
    LOANS {
        string id PK
        string borrowerId FK
        string partner "e.g. Bank of Kigali"
        int amount "requested"
        int approvedAmount
        int termMonths "3 | 6 | 9 | 12"
        string purpose "workingCapital | inventory | ..."
        string stage "submitted ... fullyRepaid | declined"
        string interestLabel
        int monthlyPayment
        int totalRepayable
        int paidAmount
        timestamp nextDueDate
        timestamp submittedAt
        timestamp updatedAt
    }
    REPAYMENTS {
        string id PK
        string loanId FK
        string borrowerId FK
        int amount
        string method "momo | bank"
        string reference
        string status "pending | confirmed | failed"
        timestamp paidAt
    }
    OPPORTUNITIES {
        string id PK "e.g. OPP-1042"
        string loanId FK
        string sector
        string title
        int requested
        int funded
        int termMonths
        double annualReturn "percent p.a."
        int score
        string verification
        string cashFlow
        string affordability
        string repaymentHistory
        string repaymentStructure
        array verifiedPoints
        string status "open | funded | closed"
        timestamp createdAt
    }
    LENDERS {
        string uid PK
        string phone
        string investorType "individual | diaspora | institutional"
        string kycStatus "pending | verified | rejected"
        string idDocumentUrl "Cloudinary"
        string selfieUrl "Cloudinary"
        bool riskAcknowledged
        bool structureAccepted
        int walletBalance "server only"
        timestamp submittedAt
    }
    FUNDINGS {
        string id PK
        string lenderId FK
        string opportunityId FK
        string loanId FK
        string sector
        int amount
        int fee
        int outstanding
        string status "pending | performing | late | repaid"
        int daysLate
        string schedule "e.g. Monthly (12m)"
        string reference
        timestamp disbursedOn
        timestamp nextRepayment
        timestamp createdAt
    }
    LEDGER {
        string id PK
        string title
        int amount "negative = money out"
        string kind "repayment | deposit | allocation | disbursed"
        string fundingId FK
        string note
        timestamp date
    }
```

## Collections

| Path | What it holds | Client can | Server only |
| --- | --- | --- | --- |
| `users/{uid}` | Account basics and role | owner reads; creates/updates own (not `role` after creation) | - |
| `users/{uid}/documents/{documentType}` | Uploaded borrower documents | owner reads, deletes, submits with `status: underReview` | sets `verified` / `needsAttention` |
| `users/{uid}/notifications/{id}` | In-app notifications | owner reads, marks `read` | creates |
| `profiles/{uid}` | Borrower profile answers (Section 02) | owner reads and writes | - |
| `consents/{id}` | Consent ledger (audit trail) | owner reads, grants, revokes | never deleted |
| `momoAccounts/{uid}` | Connected MoMo wallet | owner reads | writes (`eligible` comes from scoring) |
| `scores/{uid}` | Credit Passport score and factors | owner reads | writes (scoring engine) |
| `loans/{loanId}` | Loan applications and lifecycle | borrower reads own, creates with `stage: submitted` | every stage change |
| `repayments/{id}` | Repayments against a loan | borrower reads own, creates with `status: pending` | confirms / fails |
| `opportunities/{id}` | Anonymised loans shown to lenders | any signed-in user reads | writes, updates `funded` |
| `lenders/{uid}` | Lender onboarding and KYC | owner reads, creates with `kycStatus: pending`, edits own details | `kycStatus`, `walletBalance` |
| `lenders/{uid}/ledger/{id}` | Wallet history | owner reads | writes |
| `fundings/{id}` | A lender's allocation to an opportunity | lender reads own, creates with `status: pending` | status, repayments |

## Fixed document types

`users/{uid}/documents/{documentType}` uses these IDs (see
`documentCatalog` in `firestore_document_repository.dart`):

| documentType | Title | Requirement |
| --- | --- | --- |
| `national_id` | National ID | mandatory |
| `momo_statement` | MTN MoMo Statement | mandatory |
| `business_registration` | Business Registration (RDB) | mandatory |
| `bank_statement` | Bank Statement | recommended |
| `proof_of_enrollment` | Proof of Enrollment | optional |

## Main queries (and their indexes)

| Screen | Query | Index |
| --- | --- | --- |
| My loans | `loans` where `borrowerId == uid` order by `submittedAt desc` | composite |
| Repayment history | `repayments` where `loanId == id` order by `paidAt desc` | composite |
| Marketplace | `opportunities` where `status == open` order by `createdAt desc` | composite |
| Marketplace (risk) | `opportunities` where `status == open` order by `score desc` | composite |
| Portfolio | `fundings` where `lenderId == uid` order by `createdAt desc` | composite |
| Consent history | `consents` where `userId == uid` order by `grantedAt desc` | composite |
| Unread badge | `users/{uid}/notifications` where `read == false` order by `createdAt desc` | composite |

All indexes live in `backend/firestore.indexes.json`.
