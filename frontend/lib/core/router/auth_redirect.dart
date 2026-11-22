import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/domain/entities/app_user.dart';

/// Screens a signed-out user may open.
const _publicRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.welcome,
  AppRoutes.roleSelect,
  AppRoutes.borrowerConfirmed,
  AppRoutes.lenderConfirmed,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
};

bool _isPublic(String location) =>
    _publicRoutes.contains(location) || location.startsWith('/dev/');

/// Returns where to send the user, or null to stay where they are.
///
/// Deliberately small: it does NOT move signed-in users away from the
/// login or register screens, because right after sign-in the auth stream
/// fires before users/{uid} exists. The pages navigate after they finish.
/// [landing] is only called on cold start, at the splash route.
Future<String?> authRedirect({
  required String location,
  required AsyncValue<AppUser?> auth,
  required Future<String> Function() landing,
}) async {
  // Firebase is still restoring the session: wait, do not guess.
  if (auth.isLoading && !auth.hasValue) return null;

  final user = auth.valueOrNull;

  if (user == null) return _isPublic(location) ? null : AppRoutes.login;

  if (!user.emailVerified) {
    return location == AppRoutes.verifyEmail ? null : AppRoutes.verifyEmail;
  }

  if (location == AppRoutes.splash) {
    try {
      return await landing();
    } on Object {
      return null;
    }
  }
  return null;
}
