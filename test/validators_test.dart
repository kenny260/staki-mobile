import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/core/utils/validators.dart';

/// Unit tests for the shared validators. Rubric needs >= 3 unit tests;
/// this file starts you at the Proficient bar. Add more per feature.
void main() {
  group('Validators.email', () {
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
    test(
      'rejects malformed',
      () => expect(Validators.email('nope'), isNotNull),
    );
    test(
      'accepts valid',
      () => expect(Validators.email('aisha@staki.rw'), isNull),
    );
  });

  group('Validators.password', () {
    test('rejects short', () => expect(Validators.password('123'), isNotNull));
    test('accepts 8+', () => expect(Validators.password('password1'), isNull));
  });
}
