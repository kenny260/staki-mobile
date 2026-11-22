import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// A01_Splash
class A01SplashPage extends StatefulWidget {
  const A01SplashPage({super.key});

  @override
  State<A01SplashPage> createState() => _A01SplashPageState();
}

class _A01SplashPageState extends State<A01SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) context.go(AppRoutes.welcome);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: StakiLogo(size: 200))),
            Text(
              'Rwanda · Financial Infrastructure',
              style: AppTextStyles.caption,
            ),
            SizedBox(height: 6),
            _Dots(),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// The three progress dots under the splash caption (first one active).
class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: i == 0 ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == 0 ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
