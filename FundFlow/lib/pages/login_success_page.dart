import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/gradient_background.dart';
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top accent bar
                Container(
                  height: 4,
                  width: 200,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Ikon centang dengan dekorasi titik
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Titik-titik dekoratif di sekeliling
                      Positioned(
                        top: 10,
                        left: 30,
                        child: _dot(const Color(0xFF4FC3F7)),
                      ),
                      Positioned(
                        top: 20,
                        right: 25,
                        child: _dot(const Color(0xFF4CAF50)),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 20,
                        child: _dot(const Color(0xFF4CAF50)),
                      ),
                      Positioned(
                        bottom: 25,
                        right: 30,
                        child: _dot(const Color(0xFF4FC3F7)),
                      ),
                      Positioned(
                        top: 5,
                        right: 55,
                        child: _dot(const Color(0xFFFFC107)),
                      ),
                      // Lingkaran centang
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 44),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Login Berhasil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selamat datang kembali\nAkunmu berhasil diverifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  child: CustomButton(
                    label: 'Lanjutkan',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MainNavPage()),
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