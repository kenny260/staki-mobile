import 'package:flutter/material.dart';

/// The Staki fund logo, exported from Figma (Tokens & Assets page).
class StakiLogo extends StatelessWidget {
  const StakiLogo({super.key, this.size = 96});

  /// Width and height of the square logo.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/staki-logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Staki fund',
    );
  }
}
