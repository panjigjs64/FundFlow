import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/app_colors.dart';
import 'dart:async';
import '../widgets/gradient_background.dart';
import 'login_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== LOGO F =====
              // Ganti dengan Image.asset jika sudah punya filenya
              Image.asset(
                'assets/images/logo_fundflow.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                // Fallback kalau gambar belum ada (biar tidak error)
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 140,
                    height: 140,
                    child: Center(
                      child: Text(
                        'F',
                        style: TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ===== TEXT "FundFlow" dengan 2 warna =====
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  children: [
                    TextSpan(
                      text: 'Fund',
                      style: TextStyle(color: AppColors.primaryGreen), // hijau
                    ),
                    TextSpan(
                      text: 'Flow',
                      style: TextStyle(color: AppColors.primaryBlue), // biru
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}