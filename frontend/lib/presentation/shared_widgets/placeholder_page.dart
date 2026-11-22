import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/core/theme/text_styles.dart';

/// Temporary page used while a Figma screen is not yet built.
/// Each screen code name (e.g. A05_Phone) gets one route pointing here until
/// the owner replaces it with the real screen. Keeps navigation testable from
/// day one.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.screenCode,
    required this.title,
    super.key,
    this.owner,
  });

  /// Figma code name, e.g. "A05_Phone".
  final String screenCode;
  final String title;
  final String? owner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(screenCode)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AppIcons.wrench,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                owner == null ? 'Not built yet' : 'Owner: $owner',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
