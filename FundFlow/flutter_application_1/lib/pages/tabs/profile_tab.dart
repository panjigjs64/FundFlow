import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/export_service.dart';
import '../../theme/app_colors.dart';
import '../login_page.dart';
import '../setup_simulation_page.dart';
import '../edit_profile_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notifikasi = true;
  bool _cadanganData = true;
  bool _isExporting = false;

  Future<void> _logout() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Keluar Akun'),
      content: const Text('Yakin ingin keluar dari akun ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed),
          child: const Text('Keluar',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  if (confirm == true) {
    if (!mounted) return;

    // ⚠️ Clear memory simulasi (data di storage tetap aman)
    context.read<SimulationProvider>().clearMemory();
    await context.read<AuthProvider>().logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}

  Future<void> _openSetup(BuildContext context) async {
    context.read<SimulationProvider>().clearDraft();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetupSimulationPage()),
    );
  }

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
  }

  // ============================================================
  // ==================== BUILD =================================
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulationProvider>();
    final isDark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppColors.darkHeaderBlue, AppColors.darkBg]
              : [AppColors.headerBlueLight, Colors.white],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              if (sim.isOff)
                _modeOff(context)
              else
                _modeOn(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: const [
          Icon(Icons.savings, color: AppColors.primaryGreen, size: 24),
          SizedBox(width: 6),
          Text(
            'FundFlow',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeOff(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.person,
                  size: 70, color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Pegang Kendali Keuangan\nMahasiswa Bersama FundFlow',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Minimal uang saku tanpa drama finansial. Atur anggaran harian, '
            'simulasi bulanan, dan capai target impianmu secara realistis.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10.5,
                height: 1.4,
                color: AppColors.textSub(context)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _openSetup(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text(
              'START SIMULATION',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          _profileCard(context),
          const SizedBox(height: 16),
          _pengaturanCard(context),
        ],
      ),
    );
  }

  Widget _modeOn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _profileCard(context),
          const SizedBox(height: 16),
          _pengaturanCard(context),
        ],
      ),
    );
  }

  // ============================================================
  // ==================== PROFILE CARD ==========================
  // ============================================================
  Widget _profileCard(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil Kamu',
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.text(context)),
          ),
          const SizedBox(height: 2),
          Text(
            'Kelola informasi akun dan pengaturan aplikasi anda',
            style: TextStyle(
                fontSize: 10, color: AppColors.textSub(context)),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _readonlyField(context, 'Name', user?.nama ?? '-'),
                    const SizedBox(height: 8),
                    _readonlyField(
                        context, 'Email', user?.email ?? '-'),
                    const SizedBox(height: 8),
                    _readonlyField(context, 'Nomor Telepon',
                        user?.nomorTelepon ?? '-'),
                    const SizedBox(height: 8),
                    _readonlyField(context, 'Institusi',
                        user?.institusi ?? '-'),
                    const SizedBox(height: 8),
                    _readonlyField(
                        context, 'Tingkat', user?.tingkat ?? '-'),
                    const SizedBox(height: 8),
                    _readonlyField(context, 'Tahun Lulus',
                        user?.tahunLulus ?? '-'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: AppColors.border(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 4),
                  Text('Gambar Profil',
                      style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textSub(context))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openEditProfile,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Simpan Perubahan',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ==================== PENGATURAN CARD =======================
  // ============================================================
  Widget _pengaturanCard(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final sim = context.watch<SimulationProvider>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Akun',
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.text(context)),
          ),
          const SizedBox(height: 10),

          // ===== DARK MODE =====
          _switchRow(
            context,
            '🌙 Mode Gelap',
            'Aktifkan tema gelap untuk kenyamanan mata',
            theme.isDark,
            (v) => theme.toggle(v),
          ),

          // ===== NOTIFIKASI =====
          _switchRow(
            context,
            'Notifikasi',
            'Pengaturan notifikasi & Pengingat Transaksional',
            _notifikasi,
            (v) => setState(() => _notifikasi = v),
          ),

          // ===== CADANGAN DATA =====
          _switchRow(
            context,
            'Cadangan Data',
            'Cadangkan dan pulihkan data akunmu',
            _cadanganData,
            (v) => setState(() => _cadanganData = v),
          ),

          const SizedBox(height: 12),

          // ===== EXPORT CSV =====
          Text(
            'Ekspor Data',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.text(context)),
          ),
          const SizedBox(height: 2),
          Text(
            'Ekspor laporan keuangan sebagai file CSV',
            style: TextStyle(
                fontSize: 10, color: AppColors.textSub(context)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isExporting || sim.isOff
                  ? null
                  : () async {
                      setState(() => _isExporting = true);
                      try {
                        await ExportService.exportCSV(sim.state);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal export: $e'),
                            backgroundColor: AppColors.dangerRed,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isExporting = false);
                        }
                      }
                    },
              icon: Icon(
                sim.isOff
                    ? Icons.lock_outline
                    : Icons.download_rounded,
                size: 16,
              ),
              label: Text(
                _isExporting
                    ? 'Mengekspor...'
                    : sim.isOff
                        ? 'Export CSV (mulai simulasi dulu)'
                        : 'Export CSV',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: BorderSide(
                  color: sim.isOff
                      ? AppColors.border(context)
                      : AppColors.primaryGreen,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== AKUN TERTAUT =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Akun Tertaut',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text(context))),
                  const SizedBox(height: 2),
                  Text('Google',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSub(context))),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Fitur menyusul')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 28),
                ),
                child: const Text('Edit',
                    style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ===== KEAMANAN =====
          Text('Keamanan & Privasi',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context))),
          const SizedBox(height: 2),
          Text('Ubah kata sandi & autentikasi',
              style: TextStyle(
                  fontSize: 10, color: AppColors.textSub(context))),
          const SizedBox(height: 14),

          // ===== LOGOUT =====
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text('Keluar',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ==================== HELPERS ===============================
  // ============================================================
  Widget _readonlyField(
      BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 9.5, color: AppColors.textSub(context))),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.inputFill(context),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Text(
            value,
            style: TextStyle(
                fontSize: 11, color: AppColors.text(context)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _switchRow(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSub(context))),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}