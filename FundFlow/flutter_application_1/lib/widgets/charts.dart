import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';

// ============================================================
// ============== PIE CHART — ALOKASI PENGELUARAN =============
// ============================================================
class AlokasiPieChart extends StatelessWidget {
  final Map<String, double> data; // label -> jumlah
  final double totalSaldo;

  const AlokasiPieChart({
    super.key,
    required this.data,
    required this.totalSaldo,
  });

  static const List<Color> _palette = [
    Color(0xFF33CC66),
    Color(0xFF3399FF),
    Color(0xFF2563EB),
    Color(0xFFF59E0B),
    Color(0xFFE95252),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Belum ada data pengeluaran',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ),
      );
    }

    final entries = data.entries.toList();
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 45,
              sections: List.generate(entries.length, (i) {
                final e = entries[i];
                final percent = total > 0 ? (e.value / total) * 100 : 0;
                return PieChartSectionData(
                  color: _palette[i % _palette.length],
                  value: e.value,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: 45,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: List.generate(entries.length, (i) {
            final e = entries[i];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${e.key} (${_formatShort(e.value)})',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.darkNavy),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  String _formatShort(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}rb';
    return n.toStringAsFixed(0);
  }
}

// ============================================================
// ============== BAR CHART — TABUNGAN vs TARGET =============
// ============================================================
class TabunganBarChart extends StatelessWidget {
  final List<TabunganBarData> data;

  const TabunganBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Belum ada target untuk ditampilkan',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ),
      );
    }

    final maxY = data
            .map((e) => e.target)
            .fold<double>(0, (a, b) => a > b ? a : b) *
        1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY <= 0 ? 100 : maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.lightGrey,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: SizedBox(
                      width: 60,
                      child: Text(
                        data[idx].label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.darkNavy,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  _formatRp(rod.toY),
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            final d = data[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                // Bar target (background abu-abu)
                BarChartRodData(
                  toY: d.target,
                  color: AppColors.lightGrey,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
                // Bar terkumpul (hijau/biru)
                BarChartRodData(
                  toY: d.terkumpul,
                  color: d.color,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _formatRp(double n) {
    if (n >= 1000000) return 'Rp ${(n / 1000000).toStringAsFixed(1)}jt';
    if (n >= 1000) return 'Rp ${(n / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${n.toStringAsFixed(0)}';
  }
}

class TabunganBarData {
  final String label;
  final double target;
  final double terkumpul;
  final Color color;

  TabunganBarData({
    required this.label,
    required this.target,
    required this.terkumpul,
    required this.color,
  });
}

// ============================================================
// ============== LINE CHART — TREN SALDO HARIAN ==============
// ============================================================
class TrenSaldoLineChart extends StatelessWidget {
  final List<double> dataPoints; // saldo per hari

  const TrenSaldoLineChart({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.length < 2) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Butuh minimal 2 hari untuk grafik tren',
            style: TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ),
      );
    }

    final maxY = dataPoints.fold<double>(0, (a, b) => a > b ? a : b);
    final minY = dataPoints.fold<double>(maxY, (a, b) => a < b ? a : b);
    final padding = (maxY - minY) * 0.2;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: (minY - padding) < 0 ? 0 : minY - padding,
          maxY: maxY + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval:
                (maxY - minY + 2 * padding) / 4 > 0
                    ? (maxY - minY + 2 * padding) / 4
                    : 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.lightGrey,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: const FlTitlesData(
            leftTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        'Hari ${s.x.toInt() + 1}\n${_formatRp(s.y)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                dataPoints.length,
                (i) => FlSpot(i.toDouble(), dataPoints[i]),
              ),
              isCurved: true,
              color: AppColors.primaryGreen,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.3),
                    AppColors.primaryGreen.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRp(double n) {
    if (n >= 1000000) return 'Rp ${(n / 1000000).toStringAsFixed(1)}jt';
    if (n >= 1000) return 'Rp ${(n / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${n.toStringAsFixed(0)}';
  }
}