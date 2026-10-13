import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/gradient_background.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _institusiController = TextEditingController();
  final _tingkatController = TextEditingController();
  final _tahunController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _namaController.text = user?.nama ?? '';
    _teleponController.text = user?.nomorTelepon ?? '';
    _institusiController.text = user?.institusi ?? '';
    _tingkatController.text = user?.tingkat ?? '';
    _tahunController.text = user?.tahunLulus ?? '';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _institusiController.dispose();
    _tingkatController.dispose();
    _tahunController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    await auth.updateProfile(
      institusi: _institusiController.text.trim(),
      tingkat: _tingkatController.text.trim(),
      tahunLulus: _tahunController.text.trim(),
      nomorTelepon: _teleponController.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui ✅'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 18, color: AppColors.darkNavy),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Column(
                    children: [
                      // Avatar
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primaryBlue,
                                    width: 3),
                              ),
                              child: const Icon(Icons.person,
                                  size: 60, color: Colors.white),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Informasi Pribadi',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkNavy)),
                            const SizedBox(height: 14),
                            CustomTextField(
                              label: 'Nama Lengkap',
                              hint: 'Nama lengkapmu',
                              controller: _namaController,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              label: 'Nomor Telepon',
                              hint: '+62 812-xxxx-xxxx',
                              controller: _teleponController,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Informasi Akademik',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkNavy)),
                            const SizedBox(height: 14),
                            CustomTextField(
                              label: 'Nama Institusi',
                              hint: 'Contoh: Universitas',
                              controller: _institusiController,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              label: 'Tingkat',
                              hint: 'Contoh: S1/A1/D3/D4',
                              controller: _tingkatController,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              label: 'Tahun Lulus',
                              hint: 'Contoh: 2026',
                              controller: _tahunController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CustomButton(
          label: 'Simpan Perubahan',
          onPressed: _save,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}