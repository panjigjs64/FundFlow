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

    // ===== HEADER =====
    buffer.writeln('LAPORAN KEUANGAN FUNDFLOW');
    buffer.writeln('Diekspor: ${_formatDate(DateTime.now())}');
    buffer.writeln('');

    // ===== RINGKASAN =====
    buffer.writeln('=== RINGKASAN ===');
    buffer.writeln('Periode,${state.periodeLabel}');
    buffer.writeln('Periode Ke-,${state.currentPeriod}');
    buffer.writeln('Total Hari,${state.totalHari}');
    buffer.writeln('Saldo Awal,${_formatRp(state.saldoAwal)}');
    buffer.writeln('Saldo Saat Ini,${_formatRp(state.saldo)}');
    buffer.writeln('Total Pemasukan,${_formatRp(state.totalPemasukan)}');
    buffer.writeln(
        'Total Pengeluaran,${_formatRp(state.totalPengeluaran)}');
    buffer.writeln(
        'Total Beban Wajib,${_formatRp(state.totalBebanWajib)}');
    buffer.writeln(
        'Total Dana Darurat,${_formatRp(state.totalDanaDarurat)}');
    buffer.writeln('');

    // ===== BEBAN WAJIB =====
    buffer.writeln('=== BEBAN WAJIB ===');
    buffer.writeln('Nama,Jumlah');
    for (final b in state.bebanWajib) {
      buffer.writeln('${_escape(b.nama)},${_formatRp(b.jumlah)}');
    }
    buffer.writeln('');

    // ===== TARGET =====
    buffer.writeln('=== TARGET ===');
    buffer.writeln('Nama,Periode,Target,Terkumpul,Progress');
    for (final t in state.targets) {
      buffer.writeln(
          '${_escape(t.nama)},${_escape(t.labelPeriode)},${_formatRp(t.jumlahTarget)},${_formatRp(t.jumlahTerkumpul)},${(t.progress * 100).toStringAsFixed(1)}%');
    }
    buffer.writeln('');

    // ===== TRANSAKSI =====
    buffer.writeln('=== TRANSAKSI ===');
    buffer.writeln('Hari,Tanggal,Keterangan,Tipe,Jumlah');
    for (final t in state.transaksiList) {
      buffer.writeln(
          '${t.hariKe},${_formatDate(t.tanggal)},${_escape(t.keterangan)},${t.isPemasukan ? "Pemasukan" : "Pengeluaran"},${_formatRp(t.jumlah)}');
    }
    buffer.writeln('');

    // ===== ACHIEVEMENT =====
    buffer.writeln('=== PENCAPAIAN ===');
    buffer.writeln('Judul,Deskripsi,Status');
    for (final a in state.achievements) {
      buffer.writeln(
          '${_escape(a.judul)},${_escape(a.deskripsi)},${a.unlocked ? "Tercapai" : "Belum"}');
    }

    // ===== SIMPAN & SHARE =====
    final dir = await getTemporaryDirectory();
    final filename =
        'FundFlow_Export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
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