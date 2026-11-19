import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDatasource {
  FirebaseAuthDatasource(this._auth);
  final FirebaseAuth _auth;

  /// userChanges() also fires after reload(), unlike authStateChanges().
  Stream<User?> userChanges() => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  Future<User> register(String email, String password) async {
    final c = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return c.user!;
  }

  Future<User> signIn(String email, String password) async {
    final c = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return c.user!;
  }

  Future<User> signInWithCredential(AuthCredential credential) async =>
      (await _auth.signInWithCredential(credential)).user!;

  Future<void> sendVerificationEmail() =>
      _auth.currentUser!.sendEmailVerification();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<User?> reload() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser;
  }

  Future<void> signOut() => _auth.signOut();
}
