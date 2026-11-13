import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';

void main() {
  test('estimate matches the Figma sample (500,000 over 6 months)', () {
    const estimate = LoanEstimate(principal: 500000, termMonths: 6);
    expect(estimate.interest, 45000);
    expect(estimate.fee, 10000);
    expect(estimate.total, 555000);
    expect(estimate.monthly, 92500);
  });

  test('monthly repayment for the other terms', () {
    int monthly(int months) =>
        LoanEstimate(principal: 500000, termMonths: months).monthly;
    expect(monthly(3), 177500);
    expect(monthly(9), 64167);
    expect(monthly(12), 50000);
  });

  test('formatRwf groups thousands', () {
    expect(formatRwf(1200000), 'RWF 1,200,000');
    expect(formatRwf(50000), 'RWF 50,000');
    expect(formatRwf(500), 'RWF 500');
  });

  test('formatDate matches the Figma style', () {
    expect(formatDate(DateTime(2023, 10, 24)), 'Oct 24, 2023');
  });
}
