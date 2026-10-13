import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/simulation_provider.dart';
import '../../theme/app_colors.dart';
import '../../data/target_icons.dart';
import '../../widgets/transaksi_dialog.dart';
import '../../widgets/event_dialog.dart';
import '../../widgets/achievement_dialog.dart';
import '../setup_simulation_page.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  String _formatRp(double angka) {
    final str = angka.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buf.write(str[i]);
      c++;
      if (c % 3 == 0 && i != 0) buf.write('.');
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  Future<void> _openSetup(BuildContext context) async {
    context.read<SimulationProvider>().clearDraft();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetupSimulationPage()),
    );
  }

  Future<void> _showTransaksiDialog(
      BuildContext context, bool isPemasukan) async {
    final sim = context.read<SimulationProvider>();
    await showDialog(
      context: context,
      builder: (_) => TransaksiDialog(
        isPemasukan: isPemasukan,
        onSubmit: (ket, jumlah) async {
          final ok = await sim.tambahTransaksi(
            keterangan: ket,
            jumlah: jumlah,
            isPemasukan: isPemasukan,
          );
          if (!context.mounted) return;
          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saldo tidak cukup untuk pengeluaran ini'),
                backgroundColor: AppColors.dangerRed,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${isPemasukan ? "Pemasukan" : "Pengeluaran"} berhasil dicatat'),
                backgroundColor: isPemasukan
                    ? AppColors.primaryGreen
                    : AppColors.dangerRed,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _konfirmasiMajuHari(BuildContext context) async {
    final sim = context.read<SimulationProvider>();

    if (!sim.isSetupLengkap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Setup belum lengkap! Beban wajib dan target harus diisi.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    final nextDay = sim.state.currentDay + 1;
    final periodeHari = sim.state.periodeHari ?? 30;
    final isAkhirPeriode = nextDay >= periodeHari;
    final totalBeban = sim.totalBebanWajib;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAkhirPeriode
            ? 'Akhiri Periode ${sim.state.currentPeriod}?'
            : 'Maju ke Hari $nextDay?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAkhirPeriode
                  ? 'Ini hari terakhir periode ke-${sim.state.currentPeriod}.'
                  : 'Kamu akan maju ke hari ke-$nextDay dari $periodeHari.',
              style: const TextStyle(fontSize: 12),
            ),
            if (isAkhirPeriode) ...[
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 6),
              const Text('Rincian Periode Baru:',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _detailRow('Saldo sisa', _formatRp(sim.state.saldo)),
              _detailRow(
                  'Beban wajib baru', '-${_formatRp(totalBeban)}'),
              const Divider(height: 14),
              _detailRow(
                'Saldo awal periode baru',
                _formatRp(sim.state.saldo - totalBeban < 0
                    ? 0
                    : sim.state.saldo - totalBeban),
                bold: true,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(isAkhirPeriode ? 'Akhiri Periode' : 'Maju'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final event = await sim.majuHari();
    if (!context.mounted) return;

    if (event != null) {
      await _showEventDialog(context, sim);
    }

    if (!context.mounted) return;
    await _showAchievementQueue(context, sim);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAkhirPeriode
            ? 'Periode ${sim.state.currentPeriod} dimulai!'
            : 'Hari ke-$nextDay'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Future<void> _showEventDialog(
      BuildContext context, SimulationProvider sim) async {
    final event = sim.pendingEvent;
    if (event == null) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EventDialog(
        event: event,
        saldoSaatIni: sim.state.saldo,
        danaDarurat: sim.state.totalDanaDarurat,
        onTerima: (sumber) async {
          Navigator.pop(ctx);
          final ok = await sim.terimaEvent(sumber);
          if (!context.mounted) return;
          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saldo/dana darurat tidak cukup!'),
                backgroundColor: AppColors.dangerRed,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event diproses ✅'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          }
        },
        onTolak: () async {
          Navigator.pop(ctx);
          await sim.tolakEvent();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event ditolak. Konsekuensi diterapkan.'),
              backgroundColor: Color(0xFFF59E0B),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAchievementQueue(
      BuildContext context, SimulationProvider sim) async {
    while (sim.newAchievements.isNotEmpty) {
      final achievement = sim.newAchievements.first;
      if (!context.mounted) break;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AchievementDialog(achievement: achievement),
      );
      sim.clearNewAchievements();
      if (sim.newAchievements.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Widget _detailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textGrey)),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.normal,
                  color: bold
                      ? AppColors.primaryGreen
                      : AppColors.darkNavy)),
        ],
      ),
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
              ? [AppColors.darkHeaderGreen, AppColors.darkBg]
              : [AppColors.headerGreenLight, Colors.white],
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
              if (sim.isOff) _modeOff(context) else _modeOn(context, sim),
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

  // ================== MODE OFF ==================
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
              child: Icon(Icons.savings,
                  size: 70, color: AppColors.primaryGreen),
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
              backgroundColor: AppColors.primaryGreen,
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
          _saldoCardKosong(context),
          const SizedBox(height: 16),
          _anggaranKosong(context),
        ],
      ),
    );
  }

  Widget _saldoCardKosong(BuildContext context) {
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
        children: [
          Text('Saldo Saat Ini',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context))),
          const SizedBox(height: 4),
          Text('Rp 0,00',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context))),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                  child: _MiniStat(
                      title: 'Penghasilan', value: 'Rp 0,00')),
              SizedBox(width: 8),
              Expanded(
                  child: _MiniStat(
                      title: 'Pengeluaran', value: 'Rp 0,00')),
              SizedBox(width: 8),
              Expanded(
                  child: _MiniStat(title: 'Hemat', value: 'Rp 0,00')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _placeholder(context, 'Grafik Pengeluaran')),
              const SizedBox(width: 8),
              Expanded(
                  child: _placeholder(context, 'Status Keuangan')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _anggaranKosong(BuildContext context) {
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
          Center(
            child: Text(
              'BATAS ANGGARAN HARIAN:\nTERSISA Rp0,00',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.4,
                color: AppColors.text(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== MODE ON ==================
  Widget _modeOn(BuildContext context, SimulationProvider sim) {
    final s = sim.state;
    final trxHariIni =
        s.transaksiList.where((t) => t.hariKe == s.totalHari).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header Hari & Tombol Maju
          Container(
            padding: const EdgeInsets.all(12),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hari ${s.currentDay + 1} / ${s.periodeHari ?? 30}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Periode ${s.currentPeriod} • ${s.periodeLabel}',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSub(context)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _konfirmasiMajuHari(context),
                  icon: const Icon(Icons.fast_forward, size: 16),
                  label: const Text('Maju Hari',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Saldo Card
          Container(
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
              children: [
                Text('Saldo Saat Ini',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context))),
                const SizedBox(height: 4),
                Text(_formatRp(s.saldo),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                          title: 'Pemasukan',
                          value: _formatRp(s.totalPemasukan)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStat(
                          title: 'Pengeluaran',
                          value: _formatRp(s.totalPengeluaran)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStat(
                          title: 'Hemat',
                          value: _formatRp(s.saldo)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Pemasukan/Pengeluaran
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showTransaksiDialog(context, true),
                  icon: const Icon(Icons.arrow_downward, size: 16),
                  label: const Text('Pemasukan',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showTransaksiDialog(context, false),
                  icon: const Icon(Icons.arrow_upward, size: 16),
                  label: const Text('Pengeluaran',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Batas Anggaran
          Container(
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
                Center(
                  child: Text(
                    'BATAS ANGGARAN HARIAN:\nTERSISA ${_formatRp(s.batasAnggaranHarian)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: AppColors.text(context),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Kebutuhan Bulanan',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context))),
                const SizedBox(height: 8),
                if (s.bebanWajib.isEmpty)
                  Text('Belum ada beban wajib',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSub(context)))
                else
                  ...s.bebanWajib.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _progressRow(
                          context: context,
                          nama: b.nama,
                          max: s.totalBebanWajib,
                          value: b.jumlah,
                          jumlahText: _formatRp(b.jumlah),
                        ),
                      )),
                const SizedBox(height: 14),
                Text('Keinginan Pribadi',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context))),
                const SizedBox(height: 8),
                if (s.targets.isEmpty)
                  Text('Belum ada target',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSub(context)))
                else
                  ...s.targets.map((t) {
                    final ic = TargetIcons.getByKey(t.iconKey);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _progressRow(
                        context: context,
                        nama: t.nama,
                        max: t.jumlahTarget,
                        value: t.jumlahTerkumpul,
                        jumlahText: _formatRp(t.jumlahTarget),
                        iconData: ic,
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transaksi Hari Ini
          Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Transaksi Hari Ini',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text(context))),
                    Text('${trxHariIni.length} item',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSub(context))),
                  ],
                ),
                const SizedBox(height: 10),
                if (trxHariIni.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill(context),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.border(context)),
                    ),
                    child: Center(
                      child: Text('Belum ada transaksi hari ini',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSub(context))),
                    ),
                  )
                else
                  ...trxHariIni.reversed.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _transaksiItem(context, sim, t),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transaksiItem(
      BuildContext context, SimulationProvider sim, dynamic t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: (t.isPemasukan
                      ? AppColors.primaryGreen
                      : AppColors.dangerRed)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              t.isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: t.isPemasukan
                  ? AppColors.primaryGreen
                  : AppColors.dangerRed,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(t.keterangan,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context))),
          ),
          Text(
            '${t.isPemasukan ? "+" : "-"} ${_formatRp(t.jumlah)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: t.isPemasukan
                  ? AppColors.primaryGreen
                  : AppColors.dangerRed,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Hapus Transaksi'),
                  content: Text(
                      'Hapus "${t.keterangan}"? Saldo akan dikembalikan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dangerRed),
                      child: const Text('Hapus',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await sim.hapusTransaksi(t.id);
              }
            },
            child: Icon(Icons.close,
                size: 14, color: AppColors.textSub(context)),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context, String label) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.inputFill(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Center(
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: AppColors.textSub(context))),
      ),
    );
  }

  Widget _progressRow({
    required BuildContext context,
    required String nama,
    required double max,
    required double value,
    required String jumlahText,
    TargetIcon? iconData,
  }) {
    final progress = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconData != null) ...[
                Icon(iconData.icon, size: 14, color: iconData.color),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(nama,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context))),
              ),
              Text(jumlahText,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSub(context))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.border(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                iconData?.color ?? AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====== MINI STAT WIDGET (FIXED — tidak butuh parentContext) ======
class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputFill(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10, color: AppColors.textSub(context))),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context))),
        ],
      ),
    );
  }
}