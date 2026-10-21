import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/simulation_provider.dart';
import '../../theme/app_colors.dart';

class InsightTab extends StatefulWidget {
  const InsightTab({super.key});
  @override
  State<InsightTab> createState() => _InsightTabState();
}

class _InsightTabState extends State<InsightTab> {
  String _filter = 'Bulan';

  String _formatRp(double angka) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(angka);

  // ============================================================
  // LOGIKA KALENDER DINAMIS
  // ============================================================
  String _getTanggalLabel(DateTime currentDate, String filter, int totalHari) {
    if (filter == 'Minggu') {
      // Hitung minggu ke berapa berdasarkan total hari yang sudah dijalani
      int mingguKe = (totalHari ~/ 7) + 1;
      return 'Minggu ke-$mingguKe';
    } else if (filter == 'Bulan') {
      return DateFormat('MMMM yyyy', 'id_ID').format(currentDate);
    } else {
      return DateFormat('yyyy', 'id_ID').format(currentDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulationProvider>();
    final s = sim.state;

    // --- Hitung Alokasi Kategori Asli dari Transaksi ---
    final Map<String, double> kategoriMap = {};
    for (var t in s.transaksiList.where((t) => !t.isPemasukan)) {
      // (Opsional) Jangan hitung tabungan agar pie chart fokus ke jajan/harian
      if (t.kategori == 'Tabungan') continue; 
      kategoriMap[t.kategori] = (kategoriMap[t.kategori] ?? 0) + t.jumlah;
    }
    final totalPengeluaran = kategoriMap.values.fold(0.0, (a, b) => a + b);
    
    // --- Warna Pie Chart ---
    final colors = [AppColors.primaryGreen, AppColors.primaryBlue, Colors.orange, Colors.purple, Colors.red];
    int colorIdx = 0;
    List<PieChartSectionData> pieSections = [];
    kategoriMap.forEach((key, value) {
      if (value > 0) {
        pieSections.add(PieChartSectionData(color: colors[colorIdx % colors.length], value: value, title: '', radius: 20));
        colorIdx++;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.card(context),
      appBar: AppBar(title: const Text('Insight', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.card(context), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== FILTER TABS (Minggu, Bulan, Tahun) =====
            Container(
              decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: ['Minggu', 'Bulan', 'Tahun'].map((e) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = e),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: _filter == e ? AppColors.primaryGreen : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                      child: Text(e, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: _filter == e ? Colors.white : AppColors.textGrey)),
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ===== TAMPILAN TANGGAL KALENDER DINAMIS =====
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 16, color: AppColors.textSub(context)),
                  const SizedBox(width: 8),
                  Text(
                    _getTanggalLabel(s.currentRealDate, _filter, s.totalHari),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text(context)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSub(context)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // ===== RINGKASAN PEMASUKAN & PENGELUARAN =====
            Row(
              children: [
                Expanded(child: _summaryBox('Total Pemasukan', s.totalPemasukan, AppColors.primaryGreen)),
                const SizedBox(width: 12),
                Expanded(child: _summaryBox('Total Pengeluaran', s.totalPengeluaran, AppColors.dangerRed)),
              ],
            ),
            const SizedBox(height: 24),

            // ===== PIE CHART ALOKASI =====
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border(context))),
              child: pieSections.isEmpty 
                ? Center(child: Text('Belum ada pengeluaran', style: TextStyle(color: AppColors.textSub(context))))
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(height: 150, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 50, sections: pieSections))),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: kategoriMap.entries.map((e) {
                            final pct = totalPengeluaran > 0 ? (e.value / totalPengeluaran * 100).toStringAsFixed(0) : '0';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(children: [
                                Icon(Icons.circle, size: 10, color: colors[kategoriMap.keys.toList().indexOf(e.key) % colors.length]),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12))),
                                Text('$pct%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ]),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  ),
            ),
            const SizedBox(height: 24),

            // ===== LINE CHART DINAMIS =====
            Text('Tren Keuangan ($_filter)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text(context))),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border(context))),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border(context), strokeWidth: 1, dashArray: [4, 4])),
                  titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sim.getTrenKeuangan(_filter), 
                      isCurved: true, 
                      color: AppColors.primaryGreen, 
                      barWidth: 3, 
                      dotData: const FlDotData(show: false), 
                      belowBarData: BarAreaData(show: true, color: AppColors.primaryGreen.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBox(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 12, color: color)),
        const SizedBox(height: 4),
        Text(_formatRp(amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}