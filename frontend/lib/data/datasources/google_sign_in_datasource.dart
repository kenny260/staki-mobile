import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Written for google_sign_in 7.x (singleton + initialize + authenticate).
/// If pubspec pins 6.x, the API differs (GoogleSignIn().signIn()).
class GoogleSignInDatasource {
  GoogleSignInDatasource({required this.serverClientId});

  /// The *Web* OAuth client ID from Firebase Console
  /// (Authentication > Sign-in method > Google > Web SDK configuration).
  final String serverClientId;

  final GoogleSignIn _gsi = GoogleSignIn.instance;
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    await _gsi.initialize(serverClientId: serverClientId);
    _ready = true;
  }

  /// Returns null when the user closes the picker.
  Future<AuthCredential?> getCredential() async {
    await _init();
    try {
      final account = await _gsi.authenticate();
      final idToken = account.authentication.idToken;
      return GoogleAuthProvider.credential(idToken: idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _init();
    await _gsi.signOut();
  }
}
