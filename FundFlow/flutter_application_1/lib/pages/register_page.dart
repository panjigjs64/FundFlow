import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/gradient_background.dart';
import 'complete_profile_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _sandi = TextEditingController();
  final _konfirmasi = TextEditingController();

  Future<void> _register() async {
    if (_sandi.text != _konfirmasi.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final res = await auth.register(
      nama: _nama.text,
      email: _email.text,
      password: _sandi.text,
    );

    if (!mounted) return;
    if (!res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

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
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryBlue,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Buat Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lengkapi data diri di bawah untuk mulai.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkapmu',
                      controller: _nama,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Contoh: nama@upi.edu',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Buat Kata Sandi',
                      hint: '••••••••',
                      controller: _sandi,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Konfirmasi Kata Sandi',
                      hint: '••••••••',
                      controller: _konfirmasi,
                      obscure: true,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: isLoading ? 'Memuat...' : 'Buat Akun',
                      onPressed: isLoading ? () {} : _register,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun?',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textGrey),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Masuk di sini',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlue),
                          ),
                        ),
                      ],
                    ),
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