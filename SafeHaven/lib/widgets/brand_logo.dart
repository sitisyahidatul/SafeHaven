import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// SafeHaven logo (icon image from the design) + two-tone name.
/// Used on Onboarding and Login only; inner screens use a plain text title.
class BrandLogo extends StatelessWidget {
  final double scale;
  final String? tagline;
  const BrandLogo({super.key, this.scale = 1.0, this.tagline});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo_icon.png', height: 78 * scale),
        SizedBox(height: 6 * scale),
        Text.rich(
          TextSpan(
            style: TextStyle(
                fontSize: 30 * scale,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5),
            children: const [
              TextSpan(text: 'Safe', style: TextStyle(color: AppTheme.primary)),
              TextSpan(text: 'Haven', style: TextStyle(color: AppTheme.accent)),
            ],
          ),
        ),
        if (tagline != null) ...[
          const SizedBox(height: 2),
          Text(
            tagline!,
            style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink),
          ),
        ],
      ],
    );
  }
}

/// Small horizontal version (icon + name) for tight spaces such as the top of Onboarding.
class BrandLogoRow extends StatelessWidget {
  const BrandLogoRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo_icon.png', height: 34),
        const SizedBox(width: 8),
        Text.rich(
          const TextSpan(
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4),
            children: [
              TextSpan(text: 'Safe', style: TextStyle(color: AppTheme.primary)),
              TextSpan(text: 'Haven', style: TextStyle(color: AppTheme.accent)),
            ],
          ),
        ),
      ],
    );
  }
}
