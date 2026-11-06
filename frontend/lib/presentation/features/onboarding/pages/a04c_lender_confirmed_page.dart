import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/presentation/features/onboarding/widgets/role_confirmed_view.dart';

/// A04c_LenderConfirmed
class A04cLenderConfirmedPage extends StatelessWidget {
  const A04cLenderConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleConfirmedView(
      icon: Icons.trending_up_rounded,
      title: 'Welcome, Lender',
      message: "Next, we'll set up your lender account and verify your "
          'credentials to get you started.',
      onContinue: () => context.push(AppRoutes.phone),
    );
  }
}
