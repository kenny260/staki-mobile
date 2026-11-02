import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/presentation/features/credit_passport/providers/credit_passport_models.dart';

class FactorDetailCard extends StatelessWidget {
  const FactorDetailCard({required this.factor, super.key});

  final ScoreFactor factor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(factor.icon, size: 18, color: AppColors.success),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  factor.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  factor.levelLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Text(
            factor.summary,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _Reason(
            icon: Icons.trending_up,
            color: AppColors.success,
            label: 'WHAT HELPED',
            text: factor.helped,
          ),
          const SizedBox(height: 10),
          _Reason(
            icon: Icons.trending_down,
            color: AppColors.warning,
            label: 'WHAT COULD IMPROVE',
            text: factor.improve,
          ),
        ],
      ),
    );
  }
}

class _Reason extends StatelessWidget {
  const _Reason({
    required this.icon,
    required this.color,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
