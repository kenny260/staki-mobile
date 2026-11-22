import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';

class DataSourceCard extends StatelessWidget {
  const DataSourceCard({
    required this.leading,
    required this.title,
    required this.connected,
    required this.dataUsed,
    required this.whyNeeded,
    required this.onTap,
    super.key,
  });

  final Widget leading;
  final String title;
  final bool connected;
  final String dataUsed;
  final String whyNeeded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          connected ? 'Connected' : 'Not connected',
                          style: TextStyle(
                            fontSize: 11,
                            color: connected
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    AppIcons.caretRight,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _Label('DATA USED'),
              const SizedBox(height: 2),
              _Value(dataUsed),
              const SizedBox(height: 10),
              const _Label("WHY IT'S NEEDED"),
              const SizedBox(height: 2),
              _Value(whyNeeded),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      );
}

class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
      );
}
