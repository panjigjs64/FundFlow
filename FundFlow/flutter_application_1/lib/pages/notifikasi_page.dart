import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/simulation_provider.dart';
import '../theme/app_colors.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulationProvider>();
    final notifications = sim.notifikasiList;

    return Scaffold(
      backgroundColor: AppColors.card(context),
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.card(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(context)),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _filterChip('Semua', true),
                _filterChip('Transaksi', false),
                _filterChip('Target', false),
                _filterChip('Sistem', false),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Text('Tidak ada notifikasi baru',
                        style: TextStyle(color: AppColors.textSub(context))))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (n['color'] as Color).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(n['icon'] as IconData, color: n['color'] as Color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n['title'] as String,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.text(context))),
                                  const SizedBox(height: 4),
                                  Text(n['desc'] as String,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSub(context))),
                                  const SizedBox(height: 6),
                                  Text(n['time'] as String,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSub(context))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: AppColors.lightGrey),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: isActive ? Colors.white : AppColors.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}