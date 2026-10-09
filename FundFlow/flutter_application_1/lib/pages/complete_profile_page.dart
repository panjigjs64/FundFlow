import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/gradient_background.dart';
import 'register_success_page.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _institusi = TextEditingController();
  final _tingkat = TextEditingController();
  final _tahun = TextEditingController();
  final _telepon = TextEditingController();

  void _selesai() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.lightBlue],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Lengkapi Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Isi detail akademik dan kontakmu di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Nama Institusi',
                      hint: 'Contoh: Universitas',
                      controller: _institusi,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Tingkat',
                      hint: 'Contoh: S1/A1/D3/D4',
                      controller: _tingkat,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Tahun Lulus',
                      hint: 'Contoh: 2026',
                      controller: _tahun,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Nomor Telepon',
                      hint: 'Contoh: +62 812-xxxx-xxxx',
                      controller: _telepon,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(label: 'Selesai', onPressed: _selesai),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}