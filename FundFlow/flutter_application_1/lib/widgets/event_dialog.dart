import 'package:flutter/material.dart';
import '../data/event_data.dart';
import '../theme/app_colors.dart';

class EventDialog extends StatelessWidget {
  final RandomEvent event;
  final double saldoSaatIni;
  final double danaDarurat;
  final Function(String sumber) onTerima;
  final VoidCallback onTolak;

  const EventDialog({
    super.key,
    required this.event,
    required this.saldoSaatIni,
    required this.danaDarurat,
    required this.onTerima,
    required this.onTolak,
  });

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

  @override
  Widget build(BuildContext context) {
    final isPengeluaran = event.tipe == EventTipe.pengeluaran;
    final isPemasukan = event.tipe == EventTipe.pemasukan;
    final isOpsional = event.tipe == EventTipe.opsional;

    Color accent = AppColors.primaryBlue;
    IconData icon = Icons.info;
    if (isPengeluaran) {
      accent = AppColors.dangerRed;
      icon = Icons.warning_amber_rounded;
    } else if (isPemasukan) {
      accent = AppColors.primaryGreen;
      icon = Icons.celebration;
    } else if (isOpsional) {
      accent = const Color(0xFFF59E0B);
      icon = Icons.local_offer;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              event.judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.deskripsi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textGrey, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPemasukan ? Icons.add : Icons.remove,
                    color: accent,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPemasukan
                        ? '+ ${_formatRp(event.hadiah ?? 0)}'
                        : '- ${_formatRp(event.biaya)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Info saldo & dana darurat
            Row(
              children: [
                Expanded(
                  child: _infoBox('Saldo', _formatRp(saldoSaatIni),
                      AppColors.primaryGreen),
                ),
                if (isPengeluaran || isOpsional) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _infoBox('Dana Darurat',
                        _formatRp(danaDarurat), AppColors.primaryBlue),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // ===== TOMBOL AKSI =====
            if (isPemasukan)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => onTerima('saldo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Terima Cuan',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              )
            else ...[
              // Terima dengan Saldo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: event.biaya <= saldoSaatIni
                      ? () => onTerima('saldo')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.lightGrey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Bayar dengan Saldo',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              // Bayar dengan Dana Darurat
              if (danaDarurat > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: event.biaya <= danaDarurat
                        ? () => onTerima('dana_darurat')
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.lightGrey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Pakai Dana Darurat',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              const SizedBox(height: 8),
              // Tolak
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onTolak,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerRed,
                    side: const BorderSide(color: AppColors.dangerRed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tolak (Konsekuensi)',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textGrey)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}