import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_provider.dart';
import 'package:staki_mobile/presentation/features/credit_passport/widgets/factor_detail_card.dart';
import 'package:staki_mobile/presentation/features/credit_passport/widgets/passport_app_bar.dart';

class BreakdownPage extends ConsumerWidget {
  const BreakdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(creditScoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PassportAppBar(title: 'Understand your score'),
      body: score.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Could not load your score factors. Please try again.'),
        ),
        data: (s) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Score factors in detail',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (s == null)
                      const Text('Your score factors are not ready yet.')
                    else
                      ...s.factors.map((f) => FactorDetailCard(factor: f)),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: FilledButton(
                  // TODO(chris): confirm the target screen in Figma.
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: const StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'See how to improve',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      Icon(AppIcons.arrowRight, size: 18),
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
