import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';

/// Scrollable page body with an optional pinned bottom area.
/// Scrolling prevents overflow in landscape and on small phones.
class ConsentLayout extends StatelessWidget {
  const ConsentLayout({
    required this.children,
    super.key,
    this.bottom,
    this.centered = false,
  });

  final List<Widget> children;
  final Widget? bottom;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(0, constraints.maxHeight - 48),
                ),
                child: Column(
                  mainAxisAlignment: centered
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: centered
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
          ),
        ),
        if (bottom != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: bottom,
            ),
          ),
      ],
    );
  }
}

class ConsentHeading extends StatelessWidget {
  const ConsentHeading(this.text, {super.key, this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      );
}

class ConsentBody extends StatelessWidget {
  const ConsentBody(this.text, {super.key, this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      );
}
