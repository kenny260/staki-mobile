import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staki_mobile/data/datasources/pin_store.dart';

void main() {
  late PinStore store;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    store = PinStore();
  });

  test('no PIN is saved at first', () async {
    expect(await store.hasPin('u1'), isFalse);
    expect(await store.verify('u1', '1234'), isFalse);
  });

  test('a saved PIN verifies, a wrong one does not', () async {
    await store.save('u1', '1234');
    expect(await store.hasPin('u1'), isTrue);
    expect(await store.verify('u1', '1234'), isTrue);
    expect(await store.verify('u1', '4321'), isFalse);
  });

  test('the PIN itself is not stored', () async {
    await store.save('u1', '1234');
    const storage = FlutterSecureStorage();
    final raw = await storage.read(key: 'pin_hash_u1');
    expect(raw, isNotNull);
    expect(raw, isNot(contains('1234')));
  });

  test('saving again replaces the old PIN', () async {
    await store.save('u1', '1234');
    await store.save('u1', '5678');
    expect(await store.verify('u1', '1234'), isFalse);
    expect(await store.verify('u1', '5678'), isTrue);
  });

  test('each account has its own PIN', () async {
    await store.save('u1', '1234');
    expect(await store.hasPin('u2'), isFalse);
    expect(await store.verify('u2', '1234'), isFalse);
  });
}
