import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/simulation_provider.dart';
import '../../theme/app_colors.dart';

class TransaksiTab extends StatelessWidget {
  const TransaksiTab({super.key});

  String _formatRp(double angka) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(angka);
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulationProvider>();
    final list = sim.state.transaksiList;

    return Scaffold(
      backgroundColor: AppColors.card(context),
      appBar: AppBar(
        title: const Text('Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.card(context),
        elevation: 0,
        centerTitle: true,
      ),
      body: list.isEmpty
          ? Center(child: Text('Belum ada transaksi', style: TextStyle(color: AppColors.textGrey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final t = list[list.length - 1 - index]; // Terbaru di atas
                final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(t.tanggal);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (t.isPemasukan ? AppColors.primaryGreen : AppColors.dangerRed).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          t.isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                          color: t.isPemasukan ? AppColors.primaryGreen : AppColors.dangerRed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.kategori.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                            Text(t.keterangan, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                          ],
                        ),
                      ),
                      Text(
                        '${t.isPemasukan ? '+' : '-'} ${_formatRp(t.jumlah)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: t.isPemasukan ? AppColors.primaryGreen : AppColors.darkNavy),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}