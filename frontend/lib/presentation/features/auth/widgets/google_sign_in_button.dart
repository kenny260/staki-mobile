import 'package:flutter/material.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

/// Google button for the login and register screens. Add the "G" logo here
/// once the design provides an asset.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    super.key,
    this.label = 'Continue with Google',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppOutlinedButton(label: label, onPressed: onPressed);
  }
}
