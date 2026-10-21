import 'target_model.dart';
import 'beban_wajib_model.dart';
import 'transaksi_model.dart';
import 'achievement_model.dart';

enum SimulationStatus { idle, setup, running, finished }

enum PeriodeType { mingguan, bulanan, semester, tahunan }

class SimulationState {
  final SimulationStatus status;
  final int currentDay;
  final int currentPeriod;
  final int totalHari;
  final double saldo;
  final double saldoAwal;

  final PeriodeType? periode;
  final int? periodeHari;
  
  // TAMBAHAN: Tanggal mulai simulasi untuk kalenderisasi
  final DateTime? startDate;

  final List<BebanWajibModel> bebanWajib;
  final List<TargetModel> targets;
  final List<TransaksiModel> transaksiList;
  final List<AchievementModel> achievements;
  final List<String> eventLog;

  SimulationState({
    this.status = SimulationStatus.idle,
    this.currentDay = 0,
    this.currentPeriod = 1,
    this.totalHari = 0,
    this.saldo = 0,
    this.saldoAwal = 0,
    this.periode,
    this.periodeHari,
    this.startDate,
    this.bebanWajib = const [],
    this.targets = const [],
    this.transaksiList = const [],
    this.achievements = const [],
    this.eventLog = const [],
  });

  // ===== GETTER =====
  double get totalBebanWajib =>
      bebanWajib.fold(0.0, (sum, b) => sum + b.jumlah);

  double get sisaUntukHarian {
    final sisa = saldo - totalBebanWajib;
    return sisa > 0 ? sisa : 0;
  }

  double get batasAnggaranHarian {
    if (periodeHari == null || periodeHari == 0) return 0;
    final sisaHari = periodeHari! - currentDay;
    if (sisaHari <= 0) return 0;
    return sisaUntukHarian / sisaHari;
  }

  double get totalPemasukan => transaksiList
      .where((t) => t.isPemasukan)
      .fold(0.0, (s, t) => s + t.jumlah);

  double get totalPengeluaran => transaksiList
      .where((t) => !t.isPemasukan)
      .fold(0.0, (s, t) => s + t.jumlah);

  double get totalDanaDarurat => targets
      .where((t) => t.iconKey == 'shield' || t.nama.toLowerCase().contains('darurat'))
      .fold(0.0, (s, t) => s + t.jumlahTerkumpul);

  String get periodeLabel {
    switch (periode) {
      case PeriodeType.mingguan:
        return 'Mingguan';
      case PeriodeType.bulanan:
        return 'Bulanan';
      case PeriodeType.semester:
        return 'Semester';
      case PeriodeType.tahunan:
        return 'Tahunan';
      default:
        return '-';
    }
  }

  bool get periodeSelesai =>
      periodeHari != null && currentDay >= periodeHari!;

  /// Mengembalikan tanggal aktual simulasi berdasarkan startDate + total hari berjalan
  DateTime get currentRealDate {
    if (startDate == null) return DateTime.now();
    return startDate!.add(Duration(days: totalHari));
  }

  SimulationState copyWith({
    SimulationStatus? status,
    int? currentDay,
    int? currentPeriod,
    int? totalHari,
    double? saldo,
    double? saldoAwal,
    PeriodeType? periode,
    int? periodeHari,
    DateTime? startDate,
    List<BebanWajibModel>? bebanWajib,
    List<TargetModel>? targets,
    List<TransaksiModel>? transaksiList,
    List<AchievementModel>? achievements,
    List<String>? eventLog,
  }) {
    return SimulationState(
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      totalHari: totalHari ?? this.totalHari,
      saldo: saldo ?? this.saldo,
      saldoAwal: saldoAwal ?? this.saldoAwal,
      periode: periode ?? this.periode,
      periodeHari: periodeHari ?? this.periodeHari,
      startDate: startDate ?? this.startDate,
      bebanWajib: bebanWajib ?? this.bebanWajib,
      targets: targets ?? this.targets,
      transaksiList: transaksiList ?? this.transaksiList,
      achievements: achievements ?? this.achievements,
      eventLog: eventLog ?? this.eventLog,
    );
  }
}