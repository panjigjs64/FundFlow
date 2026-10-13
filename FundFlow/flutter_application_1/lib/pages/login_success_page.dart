import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/gradient_background.dart';
import '../theme/app_colors.dart';
import 'main_nav_page.dart';

class LoginSuccessPage extends StatelessWidget {
  const LoginSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          top: 10,
                          left: 30,
                          child: _dot(AppColors.primaryBlue)),
                      Positioned(
                          top: 20,
                          right: 25,
                          child: _dot(AppColors.primaryGreen)),
                      Positioned(
                          bottom: 15,
                          left: 20,
                          child: _dot(AppColors.primaryGreen)),
                      Positioned(
                          bottom: 25,
                          right: 30,
                          child: _dot(AppColors.primaryBlue)),
                      Positioned(
                          top: 5,
                          right: 55,
                          child: _dot(const Color(0xFFFFC107))),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 44),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Login Berhasil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selamat datang kembali\nAkunmu berhasil diverifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSub(context)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  child: CustomButton(
                    label: 'Lanjutkan',
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MainNavPage()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}