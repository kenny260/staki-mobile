import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';

class InfrastructureNotice extends StatelessWidget {
  const InfrastructureNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.info, size: 16, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Staki fund is a technology infrastructure '
                        'provider. ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: 'We do not lend money directly and we do not '
                        'hold customer funds.',
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
