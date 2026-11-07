import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/utils/validators.dart';

void main() {
  group('Rwandan phone helpers', () {
    test('accept common formats', () {
      expect(Validators.isValidRwandaPhone('078 400 2213'), isTrue);
      expect(Validators.isValidRwandaPhone('+250 784 002 213'), isTrue);
    });
    test('reject short or non-mobile numbers', () {
      expect(Validators.isValidRwandaPhone('078 123 456'), isFalse);
      expect(Validators.isValidRwandaPhone('0212345678'), isFalse);
    });
    test('display format', () {
      expect(Validators.displayRwandaPhone('0784002213'), '+250 784 002 213');
    });
  });

  test('AppColors.forScore maps the five bands', () {
    expect(AppColors.forScore(579), AppColors.scorePoor);
    expect(AppColors.forScore(580), AppColors.scoreFair);
    expect(AppColors.forScore(670), AppColors.scoreGood);
    expect(AppColors.forScore(740), AppColors.scoreVeryGood);
    expect(AppColors.forScore(800), AppColors.scoreExceptional);
  });
}
