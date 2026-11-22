import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

void showLoanMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Page frame: header, divider, scrolling body and a pinned bottom area.
class LoanScaffold extends StatelessWidget {
  const LoanScaffold({
    required this.title,
    required this.children,
    super.key,
    this.subtitle,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottom;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.splash);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: title,
              subtitle: subtitle,
              onBack: () => _back(context),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class LoanHeading extends StatelessWidget {
  const LoanHeading(this.text, {super.key, this.size = 20});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      );
}

class LoanBody extends StatelessWidget {
  const LoanBody(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      );
}

/// Small information box. Set [blue] for the blue variant (L03).
class LoanNote extends StatelessWidget {
  const LoanNote({
    required this.text,
    super.key,
    this.boldTail,
    this.blue = false,
  });

  final String text;
  final String? boldTail;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    final textColor = blue ? AppColors.infoText : AppColors.textSecondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: blue ? AppColors.infoBg : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppIcons.info,
            size: 16,
            color: blue ? AppColors.info : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: text,
                children: [
                  if (boldTail != null)
                    TextSpan(
                      text: ' $boldTail',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                ],
              ),
              style: TextStyle(fontSize: 11, height: 1.4, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable card with a green border when selected (L03, L04).
class LoanOptionCard extends StatelessWidget {
  const LoanOptionCard({
    required this.selected,
    required this.onTap,
    required this.child,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.successBg : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.success : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class LoanSummaryRow extends StatelessWidget {
  const LoanSummaryRow({
    required this.label,
    required this.value,
    super.key,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: bold ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: bold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
