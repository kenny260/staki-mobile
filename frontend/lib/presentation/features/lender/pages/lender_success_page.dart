import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';

class LenderSuccessPage extends StatelessWidget {
  const LenderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
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
                    AppIcons.checkCircle,
                    size: 40,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'KYC Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your investor profile has been successfully created. You '
                  'are now ready to fund opportunities.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  // TODO(chris): point at LE01 once the marketplace is built.
                  onPressed: () => context.go('/marketplace'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.onPrimary,
                    foregroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Go to Dashboard',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
