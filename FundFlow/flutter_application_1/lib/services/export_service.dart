import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/simulation_state.dart';

class ExportService {
  static String _formatRp(double n) {
    final f = NumberFormat('#,###', 'id_ID');
    return 'Rp ${f.format(n)}';
  }

  static String _formatDate(DateTime d) {
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  static Future<void> exportCSV(SimulationState state) async {
    final buffer = StringBuffer();

    // HEADER
    buffer.writeln('LAPORAN KEUANGAN FUNDFLOW');
    buffer.writeln('Diekspor: ${_formatDate(DateTime.now())}');
    buffer.writeln('');

    // RINGKASAN
    buffer.writeln('=== RINGKASAN ===');
    buffer.writeln('Periode,${state.periodeLabel}');
    buffer.writeln('Periode Ke-,${state.currentPeriod}');
    buffer.writeln('Total Hari,${state.totalHari}');
    buffer.writeln('Saldo Awal,${_formatRp(state.saldoAwal)}');
    buffer.writeln('Saldo Saat Ini,${_formatRp(state.saldo)}');
    buffer.writeln('Total Pemasukan,${_formatRp(state.totalPemasukan)}');
    buffer.writeln('Total Pengeluaran,${_formatRp(state.totalPengeluaran)}');
    buffer.writeln('');

    // TRANSAKSI
    buffer.writeln('=== TRANSAKSI ===');
    buffer.writeln('Hari,Tanggal,Kategori,Keterangan,Tipe,Jumlah');
    for (final t in state.transaksiList) {
      buffer.writeln(
          '${t.hariKe},${_formatDate(t.tanggal)},${_escape(t.kategori)},${_escape(t.keterangan)},${t.isPemasukan ? "Pemasukan" : "Pengeluaran"},${_formatRp(t.jumlah)}');
    }

    // SIMPAN & SHARE
    final dir = await getTemporaryDirectory();
    final filename = 'FundFlow_Export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Laporan Keuangan FundFlow',
      text: 'Laporan keuangan FundFlow Anda',
    );
  }

  static String _escape(String s) {
    if (s.contains(',') || s.contains('"')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}