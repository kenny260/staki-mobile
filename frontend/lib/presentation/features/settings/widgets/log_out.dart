import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/auth/providers/auth_controller.dart';
import 'package:staki_mobile/presentation/features/onboarding/providers/onboarding_providers.dart';

/// Asks "Log out?", signs out and returns to Welcome.
/// Used by Settings and the Profile tab.
Future<void> confirmLogOut(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    // Close with the dialog's own context: on a bottom tab the page has its
    // own navigator, and popping that one would remove the tab's only page.
    builder: (dialogContext) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text(
        'You will need to log in again with your email or Google account.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Log out'),
        ),
      ],
    ),
  );
  if (!(ok ?? false) || !context.mounted) return;

  // Grab the router first: signing out makes the router leave this page,
  // so this context is gone by the time we want to navigate.
  final router = GoRouter.of(context);
  final signedOut = await ref.read(authControllerProvider.notifier).signOut();
  if (!signedOut) return;

  // Forget the previous person's choices so a new account starts clean.
  ref
    ..invalidate(selectedRoleProvider)
    ..invalidate(phoneNumberProvider);
  router.go(AppRoutes.welcome);
}
