import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/errors/auth_failure.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_providers.dart';

const lenderHome = '/marketplace';
const borrowerHome = AppRoutes.home;

/// Where the signed-in user belongs right now. Uses the current Firebase
/// user directly, because the auth stream may not have emitted yet.
Future<String> resolveLanding(Ref ref) async {
  final user = ref.read(authRepositoryProvider).currentUser;
  if (user == null) return AppRoutes.login;
  if (!user.emailVerified) return AppRoutes.verifyEmail;
  try {
    final account = await ref.read(getUserAccountProvider)(user.uid);
    if (account == null) return AppRoutes.roleSelect;
    if (!account.onboardingComplete) return AppRoutes.phone;
    return account.role == 'lender' ? lenderHome : borrowerHome;
  } on AuthFailure {
    return AppRoutes.login;
  }
}
