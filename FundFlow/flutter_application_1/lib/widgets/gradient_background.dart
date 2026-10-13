import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3A2E), const Color(0xFF0F172A)]
              : [
                  const Color(0xFFB8E6C1),
                  Colors.white,
                  const Color(0xFFB3D9FF),
                ],
          stops: isDark ? [0.0, 1.0] : [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}