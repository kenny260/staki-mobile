import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';

class MomoLogo extends StatelessWidget {
  const MomoLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // TODO(chris): ask Binthia for a momoYellow token. warning is a
        // stand-in so there is no raw hex in this file.
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        'MoMo',
        style: TextStyle(
          fontSize: size * 0.27,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
