import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';

class ConsentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ConsentAppBar({super.key, this.title = ''});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/splash'); // fallback until the real flow exists
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.chevron_left, color: AppColors.primary),
        onPressed: () => _goBack(context),
      ),
    );
  }
}
