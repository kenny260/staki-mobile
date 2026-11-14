import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/onboarding/widgets/role_confirmed_view.dart';

/// A04_BorrowerConfirmed
class A04BorrowerConfirmedPage extends StatelessWidget {
  const A04BorrowerConfirmedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleConfirmedView(
      icon: AppIcons.wallet,
      title: 'Welcome, Borrower',
      message: "Next, we'll help you create your account and start building "
          'your Staki fund profile.',
      onContinue: () => context.push(AppRoutes.phone),
    );
  }
}
