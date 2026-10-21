import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/export_service.dart';
import '../../theme/app_colors.dart';
import '../login_page.dart';
import '../edit_profile_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isExporting = false;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (!mounted) return;
      context.read<SimulationProvider>().clearMemory();
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
    }
  }

  void _handleExportCSV() async {
    setState(() => _isExporting = true);
    try {
      await ExportService.exportCSV(context.read<SimulationProvider>().state);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ===== FUNGSI RESET SIMULASI =====
  void _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Simulasi'),
        content: const Text('Yakin ingin menghapus seluruh data simulasi ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const Text('Batal')
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            child: const Text('Ya, Reset', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      if (!mounted) return;
      // Panggil fungsi reset dari provider
      await context.read<SimulationProvider>().reset();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulasi berhasil di-reset! Silakan mulai dari awal.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // KARTU PROFIL ATAS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, size: 50, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.nama ?? 'Nama User',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'email@upi.edu',
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Profil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // MENU LIST
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _menuItem(Icons.person_outline, 'Informasi Akun'),
                    _menuItem(Icons.color_lens_outlined, 'Tema Aplikasi', trailing: Switch(
                      value: theme.isDark,
                      onChanged: (v) => theme.toggle(v),
                      activeColor: AppColors.primaryGreen,
                      activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.5),
                    )),
                    _menuItem(Icons.language, 'Bahasa', trailing: const Text('Indonesia', style: TextStyle(color: AppColors.textGrey, fontSize: 12))),
                    _menuItem(Icons.download_outlined, 'Export Laporan CSV', onTap: _handleExportCSV, 
                      trailing: _isExporting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null
                    ),
                    _menuItem(Icons.picture_as_pdf_outlined, 'Download PDF', onTap: () {}),
                    _menuItem(Icons.refresh, 'Reset Simulasi', onTap: _handleReset), // Tombol Reset
                    _menuItem(Icons.help_outline, 'Pusat Bantuan'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // TOMBOL KELUAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerRed.withValues(alpha: 0.1),
                    foregroundColor: AppColors.dangerRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('FundFlow v1.0.0', style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryGreen, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
      shape: const Border(bottom: BorderSide(color: AppColors.offWhite, width: 1)),
    );
  }
}