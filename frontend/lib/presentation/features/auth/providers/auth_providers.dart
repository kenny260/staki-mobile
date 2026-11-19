import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/constants/auth_constants.dart';
import 'package:staki_mobile/data/datasources/firebase_auth_datasource.dart';
import 'package:staki_mobile/data/datasources/google_sign_in_datasource.dart';
import 'package:staki_mobile/data/datasources/user_bootstrap_datasource.dart';
import 'package:staki_mobile/data/repositories/auth_repository_impl.dart';
import 'package:staki_mobile/data/repositories/firebase_user_repository.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';
import 'package:staki_mobile/domain/repositories/auth_repository.dart';
import 'package:staki_mobile/domain/repositories/user_repository.dart';
import 'package:staki_mobile/domain/usecases/check_email_verified.dart';
import 'package:staki_mobile/domain/usecases/ensure_user_document.dart';
import 'package:staki_mobile/domain/usecases/register_email.dart';
import 'package:staki_mobile/domain/usecases/send_email_verification.dart';
import 'package:staki_mobile/domain/usecases/send_password_reset.dart';
import 'package:staki_mobile/domain/usecases/sign_in_email.dart';
import 'package:staki_mobile/domain/usecases/sign_in_google.dart';
import 'package:staki_mobile/domain/usecases/sign_out.dart';
import 'package:staki_mobile/domain/usecases/watch_auth_state.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';

// If the app already has providers for FirebaseAuth / FirebaseFirestore,
// delete these two and reuse those.
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// ---------- repositories ----------

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    FirebaseAuthDatasource(ref.watch(firebaseAuthProvider)),
    GoogleSignInDatasource(serverClientId: googleWebClientId),
  ),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => FirebaseUserRepository(
    UserBootstrapDatasource(ref.watch(firestoreProvider)),
  ),
);

// ---------- use cases ----------

final registerEmailProvider = Provider(
  (ref) => RegisterWithEmail(ref.watch(authRepositoryProvider)),
);
final signInEmailProvider = Provider(
  (ref) => SignInWithEmail(ref.watch(authRepositoryProvider)),
);
final signInGoogleProvider = Provider(
  (ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)),
);
final signOutProvider = Provider(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);
final sendPasswordResetProvider = Provider(
  (ref) => SendPasswordReset(ref.watch(authRepositoryProvider)),
);
final sendEmailVerificationProvider = Provider(
  (ref) => ResendVerificationEmail(ref.watch(authRepositoryProvider)),
);
final checkEmailVerifiedProvider = Provider(
  (ref) => CheckEmailVerified(ref.watch(authRepositoryProvider)),
);
final watchAuthStateProvider = Provider(
  (ref) => WatchAuthState(ref.watch(authRepositoryProvider)),
);
final ensureUserDocumentProvider = Provider(
  (ref) => EnsureUserDocument(ref.watch(userRepositoryProvider)),
);

// ---------- state ----------

/// Signed-in user, or null. Also re-emits after reload (email verified).
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(watchAuthStateProvider)(),
);

/// Role chosen on A03, as the string the Firestore rules expect.
/// If selectedRoleProvider already holds a String, drop the `.name`.
final signUpRoleProvider = Provider<String?>(
  (ref) => ref.watch(selectedRoleProvider)?.name,
);
