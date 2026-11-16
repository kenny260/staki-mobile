// Demo data for Staki Fund. Values match the mock repositories in the app,
// so screens look the same after they switch to Firestore.
// Never put real personal data here.

const ts = (y, m, d) => new Date(Date.UTC(y, m - 1, d, 9, 0, 0));

// Every Cloudinary account has a public "sample" image; used as a stand-in.
const SAMPLE_FILE =
  'https://res.cloudinary.com/ybzufhwg/image/upload/sample.jpg';

const BORROWER_UID = 'demo-borrower';
const LENDER_UID = 'demo-lender';

const authUsers = [
  {
    uid: BORROWER_UID,
    email: 'borrower@staki.demo',
    password: 'StakiDemo123!',
    displayName: 'Demo Borrower',
  },
  {
    uid: LENDER_UID,
    email: 'lender@staki.demo',
    password: 'StakiDemo123!',
    displayName: 'Demo Lender',
  },
];

const users = {
  [BORROWER_UID]: {
    role: 'borrower',
    displayName: 'Demo Borrower',
    email: 'borrower@staki.demo',
    phone: '788000111',
    photoUrl: null,
    borrowerType: 'business',
    onboardingComplete: true,
    createdAt: ts(2026, 6, 20),
    updatedAt: ts(2026, 6, 20),
  },
  [LENDER_UID]: {
    role: 'lender',
    displayName: 'Demo Lender',
    email: 'lender@staki.demo',
    phone: '788000222',
    photoUrl: null,
    borrowerType: null,
    onboardingComplete: true,
    createdAt: ts(2026, 7, 1),
    updatedAt: ts(2026, 7, 1),
  },
};

const profiles = {
  [BORROWER_UID]: {
    borrowerType: 'business',
    answers: {
      businessName: 'Kigali Fresh Market',
      businessType: 'Retail / Trade',
      yearsOperating: '2-5 years',
      monthlyRevenue: '1M-5M',
      location: 'Nyarugenge, Kigali',
    },
    updatedAt: ts(2026, 6, 21),
  },
};

// users/{uid}/documents/{documentType}
const documents = {
  [BORROWER_UID]: {
    national_id: {
      fileName: 'national_id.jpg',
      url: SAMPLE_FILE,
      publicId: 'sample',
      resourceType: 'image',
      bytes: 109669,
      status: 'verified',
      note: null,
      uploadedAt: ts(2026, 6, 22),
    },
    momo_statement: {
      fileName: 'momo_statement.jpg',
      url: SAMPLE_FILE,
      publicId: 'sample',
      resourceType: 'image',
      bytes: 109669,
      status: 'needsAttention',
      note: 'Document is blurry. Please retake.',
      uploadedAt: ts(2026, 6, 22),
    },
    business_registration: {
      fileName: 'rdb_certificate.pdf',
      url: SAMPLE_FILE,
      publicId: 'sample',
      resourceType: 'image',
      bytes: 109669,
      status: 'underReview',
      note: null,
      uploadedAt: ts(2026, 6, 23),
    },
  },
};

const consents = {
  'CONSENT-demo-momo': {
    userId: BORROWER_UID,
    type: 'momo',
    granted: true,
    grantedAt: ts(2026, 6, 24),
    revokedAt: null,
  },
};

const momoAccounts = {
  [BORROWER_UID]: {
    maskedNumber: '078 *** **67',
    status: 'connected',
    eligible: true,
    connectedAt: ts(2026, 6, 24),
  },
};

const scores = {
  [BORROWER_UID]: {
    value: 742,
    band: 'veryGood',
    assessmentStatus: 'complete',
    factors: [
      {
        title: 'Cash-flow strength',
        levelLabel: 'HIGH',
        progress: 0.85,
        summary: 'Your incoming cash flow is consistent and healthy.',
        helped: 'Consistent weekly deposits over the last 6 months.',
        improve: 'More consistent monthly activity.',
      },
      {
        title: 'Financial consistency',
        levelLabel: 'GOOD',
        progress: 0.65,
        summary:
          'Your financial activity is stable and predictable over time.',
        helped: 'Long history of active account usage.',
        improve: 'Avoid sudden, large drops in transaction volume.',
      },
    ],
    updatedAt: ts(2026, 11, 16),
  },
};

const LOAN_ID = 'LN-DEMO-001';

const loans = {
  [LOAN_ID]: {
    borrowerId: BORROWER_UID,
    partner: 'Bank of Kigali',
    amount: 500000,
    approvedAmount: 500000,
    termMonths: 6,
    purpose: 'workingCapital',
    stage: 'active',
    interestLabel: '1.5% / month',
    monthlyPayment: 92500,
    totalRepayable: 555000,
    paidAmount: 277500,
    nextDueDate: ts(2026, 11, 15),
    submittedAt: ts(2026, 7, 1),
    updatedAt: ts(2026, 10, 15),
  },
};

const repayments = Object.fromEntries(
  [8, 9, 10].map((month) => [
    `RP-DEMO-${month}`,
    {
      loanId: LOAN_ID,
      borrowerId: BORROWER_UID,
      amount: 92500,
      method: 'momo',
      reference: `STK-RP-2026${String(month).padStart(2, '0')}15`,
      status: 'confirmed',
      paidAt: ts(2026, month, 15),
    },
  ]),
);

const defaultPoints = [
  'Identity (KYC)',
  'Business registration',
  'MoMo transaction history',
];

const opportunities = {
  'OPP-1042': {
    loanId: null,
    sector: 'MSME Retail',
    title: 'Inventory Expansion',
    requested: 5000000,
    funded: 3500000,
    termMonths: 12,
    annualReturn: 18,
    score: 780,
    verification: 'KYC + 2 more',
    cashFlow: 'Strong',
    affordability: 'Moderate',
    repaymentHistory: 'Excellent',
    repaymentStructure: 'Monthly Principal + Interest',
    verifiedPoints: defaultPoints,
    status: 'open',
    createdAt: ts(2026, 10, 1),
  },
  'OPP-0891': {
    loanId: null,
    sector: 'Transport/Logistics',
    title: 'Equipment Purchase',
    requested: 12000000,
    funded: 12000000,
    termMonths: 24,
    annualReturn: 16.5,
    score: 810,
    verification: 'KYC + 3 more',
    cashFlow: 'Excellent',
    affordability: 'Strong',
    repaymentHistory: 'Excellent',
    repaymentStructure: 'Monthly Principal + Interest',
    verifiedPoints: defaultPoints,
    status: 'funded',
    createdAt: ts(2026, 7, 10),
  },
  'OPP-1095': {
    loanId: null,
    sector: 'Tech Startup',
    title: 'Working Capital',
    requested: 3000000,
    funded: 900000,
    termMonths: 6,
    annualReturn: 20,
    score: 640,
    verification: 'KYC + 1 more',
    cashFlow: 'Moderate',
    affordability: 'Moderate',
    repaymentHistory: 'Good',
    repaymentStructure: 'Monthly Principal + Interest',
    verifiedPoints: defaultPoints,
    status: 'open',
    createdAt: ts(2026, 10, 3),
  },
  'OPP-0777': {
    loanId: null,
    sector: 'Agriculture',
    title: 'Seasonal Inputs',
    requested: 7500000,
    funded: 7500000,
    termMonths: 18,
    annualReturn: 17,
    score: 760,
    verification: 'KYC + 2 more',
    cashFlow: 'Strong',
    affordability: 'Strong',
    repaymentHistory: 'Good',
    repaymentStructure: 'Monthly Principal + Interest',
    verifiedPoints: defaultPoints,
    status: 'funded',
    createdAt: ts(2026, 9, 1),
  },
};

const lenders = {
  [LENDER_UID]: {
    phone: '788000222',
    investorType: 'individual',
    kycStatus: 'verified',
    idDocumentUrl: SAMPLE_FILE,
    selfieUrl: SAMPLE_FILE,
    riskAcknowledged: true,
    structureAccepted: true,
    walletBalance: 5000000,
    submittedAt: ts(2026, 7, 1),
  },
};

// lenders/{uid}/ledger/{id}
const ledger = {
  [LENDER_UID]: {
    'LG-001': {
      title: 'Repayment: OPP-1042',
      amount: 500000,
      kind: 'repayment',
      fundingId: 'FND-a1',
      note: null,
      date: ts(2026, 10, 15),
    },
    'LG-002': {
      title: 'Deposit cleared',
      amount: 2000000,
      kind: 'deposit',
      fundingId: null,
      note: null,
      date: ts(2026, 10, 10),
    },
    'LG-003': {
      title: 'Allocation: OPP-1095',
      amount: -500000,
      kind: 'allocation',
      fundingId: null,
      note: null,
      date: ts(2026, 10, 5),
    },
  },
};

const fundings = {
  'FND-a1': {
    lenderId: LENDER_UID,
    opportunityId: 'OPP-1042',
    loanId: null,
    sector: 'MSME Retail',
    amount: 5000000,
    fee: 50000,
    outstanding: 3500000,
    status: 'performing',
    daysLate: 0,
    schedule: 'Monthly (12m)',
    reference: 'STK-AL-1042',
    disbursedOn: ts(2026, 7, 15),
    nextRepayment: ts(2026, 11, 15),
    createdAt: ts(2026, 7, 14),
  },
  'FND-a2': {
    lenderId: LENDER_UID,
    opportunityId: 'OPP-0891',
    loanId: null,
    sector: 'Transport/Logistics',
    amount: 2000000,
    fee: 20000,
    outstanding: 1500000,
    status: 'late',
    daysLate: 5,
    schedule: 'Monthly (24m)',
    reference: 'STK-AL-0891',
    disbursedOn: ts(2026, 7, 20),
    nextRepayment: ts(2026, 10, 20),
    createdAt: ts(2026, 7, 19),
  },
  'FND-a3': {
    lenderId: LENDER_UID,
    opportunityId: 'OPP-0777',
    loanId: null,
    sector: 'Agriculture',
    amount: 7500000,
    fee: 75000,
    outstanding: 7000000,
    status: 'performing',
    daysLate: 0,
    schedule: 'Monthly (18m)',
    reference: 'STK-AL-0777',
    disbursedOn: ts(2026, 9, 28),
    nextRepayment: ts(2026, 11, 28),
    createdAt: ts(2026, 9, 27),
  },
};

// users/{uid}/notifications/{id}
const notifications = {
  [LENDER_UID]: {
    n1: {
      title: 'Repayment received',
      body: 'A scheduled repayment of RWF 500,000 for OPP-1042 was ' +
        'processed successfully.',
      kind: 'success',
      read: false,
      createdAt: ts(2026, 11, 16),
    },
    n2: {
      title: 'Funding allocation confirmed',
      body: 'Your RWF 500,000 allocation to OPP-1095 has been confirmed ' +
        'by Bank of Kigali.',
      kind: 'info',
      read: false,
      createdAt: ts(2026, 11, 15),
    },
    n3: {
      title: 'Payment delayed',
      body: 'OPP-0891 has missed its scheduled repayment on Oct 20. ' +
        'Collection processes have been initiated.',
      kind: 'warning',
      read: true,
      createdAt: ts(2026, 11, 11),
    },
    n4: {
      title: 'Opportunity fully funded',
      body: 'OPP-0891 has reached its funding goal of RWF 12,000,000.',
      kind: 'neutral',
      read: true,
      createdAt: ts(2026, 10, 18),
    },
    n5: {
      title: 'KYC update required',
      body: 'Please update your institutional mandate documents to ' +
        'maintain active lender status.',
      kind: 'kyc',
      read: true,
      createdAt: ts(2026, 10, 10),
    },
  },
  [BORROWER_UID]: {
    b1: {
      title: 'Repayment received',
      body: 'Your RWF 92,500 repayment to Bank of Kigali was received.',
      kind: 'success',
      read: false,
      createdAt: ts(2026, 10, 15),
    },
    b2: {
      title: 'Document needs attention',
      body: 'Your MTN MoMo statement is blurry. Please retake it.',
      kind: 'warning',
      read: false,
      createdAt: ts(2026, 6, 25),
    },
  },
};

module.exports = {
  authUsers,
  // Top-level collections: { collection: { docId: data } }
  collections: {
    users,
    profiles,
    consents,
    momoAccounts,
    scores,
    loans,
    repayments,
    opportunities,
    lenders,
    fundings,
  },
  // Subcollections: { parentCollection: { sub: { parentId: { docId: data } } } }
  subcollections: {
    users: { documents, notifications },
    lenders: { ledger },
  },
};
