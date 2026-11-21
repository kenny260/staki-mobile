import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:staki_mobile/data/datasources/loan_datasource.dart';
import 'package:staki_mobile/data/repositories/firestore_lifecycle_repository.dart';
import 'package:staki_mobile/data/repositories/firestore_loan_repository.dart';
import 'package:staki_mobile/presentation/features/loan_lifecycle/providers/lifecycle_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';

class _MockDatasource extends Mock implements LoanDatasource {}

Map<String, dynamic> _loan(String stage, {String id = 'L1'}) => {
      'id': id,
      'borrowerId': 'u1',
      'partner': 'Bank of Kigali',
      'amount': 500000,
      'approvedAmount': 500000,
      'termMonths': 6,
      'purpose': 'inventory',
      'stage': stage,
      'interestLabel': '1.5% monthly',
      'monthlyPayment': 92500,
      'totalRepayable': 555000,
      'paidAmount': 277500,
      'submittedAt': Timestamp.fromDate(DateTime(2026, 7)),
      'nextDueDate': Timestamp.fromDate(DateTime(2026, 11, 15)),
    };

void main() {
  late _MockDatasource ds;
  late FirestoreLoanRepository loans;
  late FirestoreLifecycleRepository lifecycle;

  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  setUp(() {
    ds = _MockDatasource();
    loans = FirestoreLoanRepository(datasource: ds, uid: 'u1');
    lifecycle = FirestoreLifecycleRepository(datasource: ds, uid: 'u1');
    when(() => ds.loansOf('u1')).thenAnswer((_) async => []);
  });

  group('eligibility from the Credit Passport', () {
    test('Very Good score is eligible for the top offer', () async {
      when(() => ds.scoreOf('u1')).thenAnswer((_) async => {'value': 758});
      final result = await loans.fetchEligibility();
      expect(result.status, EligibilityStatus.eligible);
      expect(result.offer!.maxAmount, 1200000);
      expect(result.offer!.pendingVerification, isFalse);
    });

    test('Fair score is partially eligible pending verification', () async {
      when(() => ds.scoreOf('u1')).thenAnswer((_) async => {'value': 600});
      final result = await loans.fetchEligibility();
      expect(result.status, EligibilityStatus.partiallyEligible);
      expect(result.offer!.maxAmount, 500000);
      expect(result.offer!.pendingVerification, isTrue);
    });

    test('Poor score or no score is not eligible', () async {
      when(() => ds.scoreOf('u1')).thenAnswer((_) async => {'value': 450});
      expect(
        (await loans.fetchEligibility()).status,
        EligibilityStatus.notEligible,
      );
      when(() => ds.scoreOf('u1')).thenAnswer((_) async => null);
      expect(
        (await loans.fetchEligibility()).status,
        EligibilityStatus.notEligible,
      );
    });

    test('a pending application shows under review', () async {
      when(() => ds.loansOf('u1'))
          .thenAnswer((_) async => [_loan('submitted')]);
      expect(
        (await loans.fetchEligibility()).status,
        EligibilityStatus.underReview,
      );
    });
  });

  group('applications', () {
    test('submit writes a loan that matches the rules', () async {
      when(() => ds.createLoan(any())).thenAnswer((_) async => {'id': 'L2'});
      await loans.submit(
        const LoanDraft(
          amount: 600000,
          termMonths: 9,
          purpose: LoanPurpose.equipment,
        ),
      );
      final data = verify(() => ds.createLoan(captureAny())).captured.single
          as Map<String, dynamic>;
      expect(data['borrowerId'], 'u1');
      expect(data['stage'], 'submitted');
      expect(data['amount'], 600000);
      expect(data['termMonths'], 9);
      expect(data['purpose'], 'equipment');
      expect(data['paidAmount'], 0);
    });

    test('submit without a purpose is refused', () {
      expect(
        () => loans.submit(const LoanDraft()),
        throwsA(isA<LoanException>()),
      );
    });

    test('a submitted application can be withdrawn', () async {
      when(() => ds.loansOf('u1'))
          .thenAnswer((_) async => [_loan('submitted', id: 'L9')]);
      when(() => ds.deleteLoan('L9')).thenAnswer((_) async {});
      await loans.cancelApplication();
      verify(() => ds.deleteLoan('L9')).called(1);
    });

    test('an application under review cannot be withdrawn', () {
      when(() => ds.loansOf('u1'))
          .thenAnswer((_) async => [_loan('underReview')]);
      expect(loans.cancelApplication, throwsA(isA<LoanException>()));
    });
  });

  group('loan lifecycle', () {
    test('reads the active loan with its payments newest first', () async {
      when(() => ds.loansOf('u1')).thenAnswer((_) async => [_loan('active')]);
      when(() => ds.repaymentsOf('u1', 'L1')).thenAnswer(
        (_) async => [
          {
            'amount': 92500,
            'status': 'confirmed',
            'paidAt': Timestamp.fromDate(DateTime(2026, 9, 15)),
          },
          {
            'amount': 92500,
            'status': 'confirmed',
            'paidAt': Timestamp.fromDate(DateTime(2026, 10, 15)),
          },
          {
            'amount': 92500,
            'status': 'failed',
            'paidAt': Timestamp.fromDate(DateTime(2026, 10, 16)),
          },
        ],
      );
      final account = await lifecycle.fetchLoan();
      expect(account.stage, LoanStage.active);
      expect(account.outstanding, 277500);
      expect(account.payments, hasLength(2));
      expect(account.payments.first.date, DateTime(2026, 10, 15));
    });

    test('repay saves a pending repayment and returns a receipt', () async {
      when(() => ds.loansOf('u1')).thenAnswer((_) async => [_loan('active')]);
      when(() => ds.repaymentsOf('u1', 'L1')).thenAnswer((_) async => []);
      when(() => ds.createRepayment(any())).thenAnswer((_) async => {});
      await lifecycle.fetchLoan();
      final receipt = await lifecycle.repay(PayMethod.momo);
      final data = verify(() => ds.createRepayment(captureAny()))
          .captured
          .single as Map<String, dynamic>;
      expect(data['status'], 'pending');
      expect(data['method'], 'momo');
      expect(data['loanId'], 'L1');
      expect(data['amount'], 92500);
      expect(receipt.amount, 92500);
      expect(receipt.reference, startsWith('TXN-'));
    });

    test('no loan gives a clear message', () {
      expect(lifecycle.fetchLoan, throwsA(isA<LifecycleException>()));
    });
  });
}
