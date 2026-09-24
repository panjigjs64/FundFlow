import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB2DFDB), // hijau muda
            Color(0xFFE0F7FA), // putih kebiruan
            Color(0xFFB3E5FC), // biru muda
          ],
        ),
      ),
      child: child,
    );
  }
}