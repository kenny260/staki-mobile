import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the app PIN on this phone only, in the encrypted keystore.
/// It never stores the PIN itself: only a random salt and the SHA-256 of
/// salt + PIN, one entry per account so two people on one phone don't mix.
class PinStore {
  PinStore([FlutterSecureStorage? storage, Random? random])
      : _storage = storage ?? const FlutterSecureStorage(),
        _random = random ?? Random.secure();

  final FlutterSecureStorage _storage;
  final Random _random;

  static String _key(String uid) => 'pin_hash_$uid';

  static String _hash(String salt, String pin) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  Future<bool> hasPin(String uid) async =>
      await _storage.read(key: _key(uid)) != null;

  Future<void> save(String uid, String pin) async {
    final salt = base64Url.encode(
      List<int>.generate(16, (_) => _random.nextInt(256)),
    );
    await _storage.write(key: _key(uid), value: '$salt:${_hash(salt, pin)}');
  }

  /// True when [pin] matches the saved one. False if none is saved.
  Future<bool> verify(String uid, String pin) async {
    final stored = await _storage.read(key: _key(uid));
    if (stored == null) return false;
    final split = stored.indexOf(':');
    if (split < 0) return false;
    final salt = stored.substring(0, split);
    return stored.substring(split + 1) == _hash(salt, pin);
  }
}

final pinStoreProvider = Provider<PinStore>((ref) => PinStore());
