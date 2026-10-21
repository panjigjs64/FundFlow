import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/simulation_provider.dart';
import '../../theme/app_colors.dart';
import '../../data/target_icons.dart';
import '../../models/target_model.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({super.key});

  String _formatRp(double angka) => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(angka);

  // MODAL UNTUK NABUNG / AMBIL
  void _showAksiTarget(BuildContext context, TargetModel t) {
    final sim = context.read<SimulationProvider>();
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kelola Target: ${t.nama}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nominal (Rp)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final amt = double.tryParse(controller.text) ?? 0;
                      if (amt > 0) {
                        await sim.nabungTarget(t.id, amt);
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                    child: const Text('NABUNG'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final amt = double.tryParse(controller.text) ?? 0;
                      if (amt > 0) {
                        await sim.ambilDariTarget(t.id, amt);
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                    child: const Text('AMBIL'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulationProvider>();
    final targets = sim.state.targets;
    final totalTarget = targets.fold<double>(0, (s, t) => s + t.jumlahTarget);
    final totalTerkumpul = targets.fold<double>(0, (s, t) => s + t.jumlahTerkumpul);
    final overallProgress = totalTarget > 0 ? (totalTerkumpul / totalTarget) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.card(context),
      appBar: AppBar(title: const Text('Target', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.card(context), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KARTU TOTAL
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border(context))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.savings, color: AppColors.primaryGreen), const SizedBox(width: 8), Text('Total Tabungan Target', style: TextStyle(color: AppColors.textSub(context), fontSize: 12))]),
                  const SizedBox(height: 8),
                  Text(_formatRp(totalTerkumpul), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text(context))),
                  const SizedBox(height: 16),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: overallProgress, minHeight: 10, backgroundColor: AppColors.border(context), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // LIST TARGET
            ...targets.map((t) {
              final ic = TargetIcons.getByKey(t.iconKey);
              return GestureDetector(
                onTap: () => _showAksiTarget(context, t),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border(context))),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: ic.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(ic.icon, color: ic.color)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t.nama, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text(context))), Text('${(t.progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub(context)))]),
                            const SizedBox(height: 4),
                            Text('${_formatRp(t.jumlahTerkumpul)} / ${_formatRp(t.jumlahTarget)}', style: TextStyle(fontSize: 12, color: AppColors.textSub(context))),
                            const SizedBox(height: 8),
                            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: t.progress, minHeight: 6, backgroundColor: AppColors.offWhite, valueColor: AlwaysStoppedAnimation<Color>(ic.color))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
            Text('Pencapaian (Achievement)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text(context))),
            const SizedBox(height: 12),
            ...sim.state.achievements.map((a) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: a.unlocked ? AppColors.primaryGreen.withValues(alpha: 0.1) : AppColors.offWhite, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(a.unlocked ? Icons.emoji_events : Icons.lock_outline, color: a.unlocked ? AppColors.primaryGreen : Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(child: Text(a.judul, style: TextStyle(fontWeight: FontWeight.bold, color: a.unlocked ? AppColors.primaryGreen : AppColors.textSub(context)))),
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}