import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/constants/spacing.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
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
            Expanded(child: Center(child: StakiLogo(size: 44))),
            Text(
              'Rwanda · Financial infrastructure',
              style: AppTextStyles.caption,
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
