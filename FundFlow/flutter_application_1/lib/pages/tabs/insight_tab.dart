import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/simulation_provider.dart';
import '../../theme/app_colors.dart';
import '../../data/target_icons.dart';
import '../../widgets/charts.dart';
import '../setup_simulation_page.dart';

class InsightTab extends StatelessWidget {
  const InsightTab({super.key});

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
              if (sim.isOff)
                _modeOff(context)
              else
                _modeOn(context, sim),
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

  // ============ OFF ============
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
              child: Icon(Icons.bar_chart,
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
          _insightCardKosong(context),
          _kinerjaCardKosong(context),
        ],
      ),
    );
  }

  Widget _insightCardKosong(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
            Text('Insight & Analisis Keuangan Anda',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(context))),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.7,
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputFill(context),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.border(context)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kinerjaCardKosong(BuildContext context) {
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
          Text('Rincian Kinerja Anggaran',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context))),
          const SizedBox(height: 12),
          _tableRow(context, 'Saldo', 'Rp 0,00', 'Rp 0,00'),
          _tableRow(context, 'Tabungan', 'Rp 0,00', 'Rp 0,00'),
          _tableRow(context, 'Beban Wajib', 'Rp 0,00', 'Rp 0,00'),
        ],
      ),
    );
  }

  // ============ ON ============
  Widget _modeOn(BuildContext context, SimulationProvider sim) {
    final s = sim.state;

    // DATA PIE CHART
    final Map<String, double> alokasiData = {};
    for (final b in s.bebanWajib) {
      alokasiData[b.nama] = b.jumlah;
    }
    for (final t in s.transaksiList) {
      if (!t.isPemasukan &&
          !t.keterangan.startsWith('Beban wajib') &&
          !t.keterangan.startsWith('Event')) {
        alokasiData[t.keterangan] =
            (alokasiData[t.keterangan] ?? 0) + t.jumlah;
      }
    }

    // DATA BAR CHART
    final barData = s.targets.map((t) {
      final ic = TargetIcons.getByKey(t.iconKey);
      return TabunganBarData(
        label: t.nama,
        target: t.jumlahTarget,
        terkumpul: t.jumlahTerkumpul,
        color: ic.color,
      );
    }).toList();

    // DATA LINE CHART
    final trenData = <double>[];
    double running = s.saldoAwal;
    for (int d = 0; d <= s.totalHari; d++) {
      final trxHariItu =
          s.transaksiList.where((t) => t.hariKe == d).toList();
      for (final t in trxHariItu) {
        running += t.isPemasukan ? t.jumlah : -t.jumlah;
      }
      trenData.add(running < 0 ? 0 : running);
    }

    // STATISTIK
    final pengeluaranHarian = s.totalPengeluaran -
        s.bebanWajib.fold<double>(0, (sum, b) => sum + b.jumlah);
    final hariBerjalan = s.totalHari + 1;
    final rataHarian =
        hariBerjalan > 0 ? pengeluaranHarian / hariBerjalan : 0.0;
    final hariBertahan = rataHarian > 0 ? s.saldo / rataHarian : 999.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Card 1: Statistik
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
                Text('Insight & Analisis Keuangan Anda',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context))),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.55,
                  children: [
                    _statCard(
                      'Budget vs Pengeluaran',
                      '${_formatRp(s.saldoAwal)} / ${_formatRp(s.totalPengeluaran)}',
                      AppColors.primaryBlue,
                      Icons.account_balance_wallet,
                    ),
                    _statCard(
                      'Rata-rata Harian',
                      _formatRp(rataHarian),
                      AppColors.primaryGreen,
                      Icons.trending_down,
                    ),
                    _statCard(
                      'Pola Belanja',
                      '${s.transaksiList.where((t) => !t.isPemasukan).length} trx',
                      AppColors.deepBlue,
                      Icons.receipt_long,
                    ),
                    _statCard(
                      'Saldo Bertahan',
                      hariBertahan > 900
                          ? '∞ hari'
                          : '${hariBertahan.toStringAsFixed(0)} hari',
                      AppColors.darkNavy,
                      Icons.hourglass_bottom,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Pie Chart
          _chartCard(
            context: context,
            title: 'Alokasi Pengeluaran Bulanan',
            child: AlokasiPieChart(
              data: alokasiData,
              totalSaldo: s.saldoAwal,
            ),
          ),
          const SizedBox(height: 16),

          // Card 3: Bar Chart
          _chartCard(
            context: context,
            title: 'Tabungan Bulanan vs Target Tujuan',
            child: TabunganBarChart(data: barData),
          ),
          const SizedBox(height: 16),

          // Card 4: Line Chart
          _chartCard(
            context: context,
            title: 'Tren Saldo Harian',
            child: TrenSaldoLineChart(dataPoints: trenData),
          ),
          const SizedBox(height: 16),

          // Card 5: Tabel Rincian
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
                Text('Rincian Kinerja Anggaran',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context))),
                const SizedBox(height: 12),
                _tableRow(context, 'Saldo', _formatRp(s.saldoAwal),
                    _formatRp(s.saldo)),
                _tableRow(context, 'Tabungan', 'Rp 0,00',
                    _formatRp(s.totalDanaDarurat)),
                _tableRow(context, 'Beban Wajib', '-',
                    _formatRp(s.totalBebanWajib)),
                _tableRow(context, 'Pemasukan', '-',
                    _formatRp(s.totalPemasukan)),
                _tableRow(context, 'Pengeluaran', '-',
                    _formatRp(s.totalPengeluaran)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _chartCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
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
          Text(title,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context))),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _tableRow(
      BuildContext context, String label, String rencana, String aktual) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context)))),
          Expanded(
              child: Text(rencana,
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSub(context)))),
          Expanded(
              child: Text(aktual,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context)))),
        ],
      ),
    );
  }
}