import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/simulation_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/transaksi_dialog.dart';
import '../../widgets/event_dialog.dart';         // IMPORT EVENT
import '../../widgets/achievement_dialog.dart';   // IMPORT ACHIEVEMENT
import '../setup_simulation_page.dart';
import '../notifikasi_page.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _formatRp(double angka) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(angka);

  void _showTambahTransaksi(BuildContext context, bool isPemasukan) {
    final sim = context.read<SimulationProvider>();
    showDialog(
      context: context,
      builder: (_) => TransaksiDialog(
        isPemasukanDefault: isPemasukan,
        onSubmit: (ket, jumlah, isPem, kategori) async {
          await sim.tambahTransaksi(keterangan: ket, jumlah: jumlah, isPemasukan: isPem, kategori: kategori);
          if (sim.ewsMessage != null) _showEws(context, sim.ewsMessage!);
        },
      ),
    );
  }

  void _showEws(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange), SizedBox(width: 8), Text('Peringatan Dini')]),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mengerti'))],
      ),
    );
  }

  // ============================================================
  // ==================== HANDLE MAJU HARI ======================
  // ============================================================
  Future<void> _handleMajuHari(BuildContext context) async {
    final sim = context.read<SimulationProvider>();
    
    // 1. Maju Hari
    final event = await sim.majuHari();
    if (!context.mounted) return;

    // 2. Tampilkan Event (Jika ada)
    if (event != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => EventDialog(
          event: event,
          saldoSaatIni: sim.state.saldo,
          danaDarurat: sim.state.totalDanaDarurat,
          onTerima: (sumber) async {
            Navigator.pop(ctx);
            await sim.terimaEvent(sumber);
          },
          onTolak: () async {
            Navigator.pop(ctx);
            await sim.tolakEvent();
          },
        ),
      );
    }

    // 3. Tampilkan Achievement (Jika ada yang baru terbuka)
    while (sim.newAchievements.isNotEmpty) {
      final achievement = sim.newAchievements.first;
      if (!context.mounted) break;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AchievementDialog(achievement: achievement),
      );
      sim.clearNewAchievements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulationProvider>();
    final s = sim.state;
    final user = context.watch<AuthProvider>().currentUser;

    if (sim.isOff) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.savings, size: 80, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              const Text('Belum ada simulasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupSimulationPage())),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                child: const Text('MULAI SIMULASI SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.card(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, ${user?.nama.split(' ').first ?? 'User'}! 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text(context))),
                      Text('Langkah kecil hari ini, untuk masa depanmu.', style: TextStyle(fontSize: 12, color: AppColors.textSub(context))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage())),
                    child: CircleAvatar(backgroundColor: AppColors.offWhite, child: Icon(Icons.notifications_outlined, color: AppColors.textSub(context))),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // KARTU SALDO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Periode ${s.currentPeriod} • ${s.periodeLabel}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(DateFormat('dd MMM yyyy').format(s.currentRealDate), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Total Saldo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(_formatRp(s.saldo), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _miniStat(Icons.arrow_downward, 'Pemasukan', _formatRp(s.totalPemasukan)),
                        const SizedBox(width: 16),
                        _miniStat(Icons.arrow_upward, 'Pengeluaran', _formatRp(s.totalPengeluaran)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // TOMBOL MAJU HARI (Memicu Event & Achievement)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleMajuHari(context), // PANGGIL FUNGSI INI
                      icon: const Icon(Icons.fast_forward, size: 16),
                      label: const Text('MAJU HARI (TEST)'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // AKSI CEPAT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionBtn(context, Icons.add_circle, 'Tambah', () => _showTambahTransaksi(context, false)),
                  _actionBtn(context, Icons.receipt_long, 'Transaksi', () {}),
                  _actionBtn(context, Icons.flag, 'Target', () {}),
                  _actionBtn(context, Icons.pie_chart, 'Insight', () {}),
                ],
              ),
              const SizedBox(height: 24),

              // TRANSAKSI TERAKHIR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaksi Terakhir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text(context))),
                  TextButton(onPressed: () {}, child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)))
                ],
              ),
              const SizedBox(height: 8),
              ...s.transaksiList.reversed.take(3).map((t) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: AppColors.card(context),
                elevation: 0,
                shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.border(context)), borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (t.isPemasukan ? AppColors.primaryGreen : AppColors.dangerRed).withValues(alpha: 0.1),
                    child: Icon(t.isPemasukan ? Icons.arrow_downward : Icons.arrow_upward, color: t.isPemasukan ? AppColors.primaryGreen : AppColors.dangerRed, size: 20),
                  ),
                  title: Text(t.keterangan, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text(context))),
                  subtitle: Text('${t.kategori} • ${DateFormat('dd MMM').format(t.tanggal)}', style: TextStyle(fontSize: 12, color: AppColors.textSub(context))),
                  trailing: Text('${t.isPemasukan ? '+' : '-'}${_formatRp(t.jumlah)}', style: TextStyle(fontWeight: FontWeight.bold, color: t.isPemasukan ? AppColors.primaryGreen : AppColors.dangerRed)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _actionBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.offWhite, shape: BoxShape.circle, border: Border.all(color: AppColors.border(context))),
            child: Icon(icon, color: AppColors.primaryGreen),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub(context))),
      ],
    );
  }
}