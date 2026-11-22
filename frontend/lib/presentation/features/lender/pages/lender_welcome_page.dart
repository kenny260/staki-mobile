import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/lender/lender_routes.dart';
import 'package:staki_mobile/presentation/features/lender/providers/lender_providers.dart';

class LenderWelcomePage extends ConsumerWidget {
  const LenderWelcomePage({super.key});

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    await ref.read(lenderControllerProvider.notifier).start();
    if (!context.mounted) return;
    unawaited(context.push(LenderRoutes.phone));
  }

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.lenderConfirmed);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _back(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.onPrimary.withValues(alpha: 0.12),
                        ),
                        child: const Icon(
                          AppIcons.caretLeft,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'STAKI FUND',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.onPrimary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          AppIcons.bank,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Fund opportunities with better information',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Join the regulated lending infrastructure. Access '
                        'verified borrowers in Rwanda with our Credit '
                        'Passport scoring technology.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: () => unawaited(_start(context, ref)),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: AppColors.onPrimary,
                          foregroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create Investor Account',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 8),
                            Icon(AppIcons.arrowRight, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
