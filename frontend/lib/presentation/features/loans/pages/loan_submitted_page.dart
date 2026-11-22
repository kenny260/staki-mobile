import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_models.dart';
import 'package:staki_mobile/presentation/features/loans/providers/loan_providers.dart';

class LoanSubmittedPage extends ConsumerWidget {
  const LoanSubmittedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final application = ref.watch(applicationProvider).valueOrNull;
    final message = application == null
        ? 'Your loan request has been sent. We will notify you once they '
            'review your Credit Passport.'
        : 'Your loan request for ${formatRwf(application.amount)} has been '
            'sent to ${application.partner}. We will notify you once they '
            'review your Credit Passport.';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.onPrimary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          AppIcons.fileText,
                          size: 38,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Application Submitted',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: FilledButton(
                // TODO(chris): point at the dashboard once that screen exists.
                onPressed: () => context.go(AppRoutes.creditPassport),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.onPrimary,
                  foregroundColor: AppColors.primary,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Return to Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
