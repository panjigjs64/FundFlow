import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/simulation_state.dart';
import '../models/beban_wajib_model.dart';
import '../models/target_model.dart';
import '../models/transaksi_model.dart';
import '../models/achievement_model.dart';
import '../data/event_data.dart';
import '../repositories/local_storage.dart';
import '../theme/app_colors.dart';

class SimulationProvider extends ChangeNotifier {
  final LocalStorage _storage = LocalStorage();

  SimulationState _state = SimulationState();
  String? _userId;

  List<BebanWajibModel> _draftBebanWajib = [];
  List<TargetModel> _draftTargets = [];

  final List<AchievementModel> _newAchievements = [];
  RandomEvent? _pendingEvent;
  String? _ewsMessage;

  // ===== GETTER =====
  SimulationState get state => _state;
  List<BebanWajibModel> get draftBebanWajib => _draftBebanWajib;
  List<TargetModel> get draftTargets => _draftTargets;
  List<AchievementModel> get newAchievements => _newAchievements;
  RandomEvent? get pendingEvent => _pendingEvent;
  String? get userId => _userId;
  String? get ewsMessage => _ewsMessage;

  bool get isRunning => _state.status == SimulationStatus.running;
  bool get isIdle => _state.status == SimulationStatus.idle;
  bool get isSetup => _state.status == SimulationStatus.setup;
  bool get isFinished => _state.status == SimulationStatus.finished;
  bool get isOff => isIdle || isFinished;

  bool get isSetupLengkap =>
      _state.bebanWajib.isNotEmpty && _state.targets.isNotEmpty;

  double get totalBebanWajib =>
      _state.bebanWajib.fold(0.0, (s, b) => s + b.jumlah);

  // ============================================================
  // ==================== NOTIFIKASI GETTER =====================
  // ============================================================
  List<Map<String, dynamic>> get notifikasiList {
    final list = <Map<String, dynamic>>[];

    // 1. EWS
    if (_state.saldo < (_state.totalBebanWajib * 0.2) && _state.saldo > 0) {
      list.add({
        'title': 'Saldo Menipis',
        'desc': 'Saldo kamu di bawah 20% dari beban wajib. Segera hemat!',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
        'time': 'Baru saja',
      });
    }

    // 2. Target
    for (final t in _state.targets) {
      if (t.progress >= 1.0) {
        list.add({
          'title': 'Target Tercapai!',
          'desc': 'Selamat! Target ${t.nama} sudah terkumpul 100%.',
          'icon': Icons.emoji_events,
          'color': AppColors.primaryGreen,
          'time': 'Hari ini',
        });
      } else if (t.progress >= 0.8) {
        list.add({
          'title': 'Target Hampir Tercapai',
          'desc': '${t.nama} sudah mencapai ${(t.progress * 100).toStringAsFixed(0)}%.',
          'icon': Icons.flag,
          'color': AppColors.primaryBlue,
          'time': '1 hari lalu',
        });
      }
    }

    // 3. Event
    if (_state.eventLog.isNotEmpty) {
      list.add({
        'title': 'Aktivitas Event',
        'desc': 'Kamu baru saja menghadapi ${_state.eventLog.length} event simulasi.',
        'icon': Icons.notifications_active,
        'color': AppColors.darkNavy,
        'time': '2 hari lalu',
      });
    }

    return list;
  }

  // ============================================================
  // ==================== TREN KEUANGAN =========================
  // ============================================================
  List<FlSpot> getTrenKeuangan(String filter) {
    if (_state.transaksiList.isEmpty) return [const FlSpot(0, 0)];

    final trx = List<TransaksiModel>.from(_state.transaksiList)
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    List<FlSpot> spots = [];
    double runningSaldo = _state.saldoAwal;
    
    int dayLimit = filter == 'Minggu' ? 7 : (filter == 'Bulan' ? 30 : 365);
    if (_state.totalHari < dayLimit) dayLimit = _state.totalHari;

    int currentDay = 0;
    spots.add(FlSpot(0, runningSaldo)); 

    for (var t in trx) {
      if (t.hariKe > dayLimit) break;
      
      while (currentDay < t.hariKe && currentDay < dayLimit) {
        currentDay++;
        spots.add(FlSpot(currentDay.toDouble(), runningSaldo));
      }

      runningSaldo += t.isPemasukan ? t.jumlah : -t.jumlah;
      
      if (spots.isNotEmpty && spots.last.x == t.hariKe.toDouble()) {
        spots[spots.length - 1] = FlSpot(t.hariKe.toDouble(), runningSaldo);
      } else if (currentDay == t.hariKe) {
         spots.add(FlSpot(currentDay.toDouble(), runningSaldo));
      }
    }

    while (currentDay < dayLimit) {
      currentDay++;
      spots.add(FlSpot(currentDay.toDouble(), runningSaldo));
    }

    if (spots.length == 1) spots.add(FlSpot(1, runningSaldo));
    return spots;
  }

  // ============================================================
  // ==================== LOAD / PERSIST ========================
  // ============================================================
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    final raw = await _storage.getSimulation(userId);

    if (raw == null) {
      _state = SimulationState();
    } else {
      _state = SimulationState(
        status: SimulationStatus.values.firstWhere((s) => s.name == (raw['status'] ?? 'idle'), orElse: () => SimulationStatus.idle),
        currentDay: raw['currentDay'] ?? 0,
        currentPeriod: raw['currentPeriod'] ?? 1,
        totalHari: raw['totalHari'] ?? 0,
        saldo: (raw['saldo'] ?? 0).toDouble(),
        saldoAwal: (raw['saldoAwal'] ?? 0).toDouble(),
        periode: raw['periode'] != null ? PeriodeType.values.firstWhere((p) => p.name == raw['periode'], orElse: () => PeriodeType.bulanan) : null,
        periodeHari: raw['periodeHari'],
        startDate: raw['startDate'] != null ? DateTime.parse(raw['startDate']) : null,
        bebanWajib: (raw['bebanWajib'] as List? ?? []).map((e) => BebanWajibModel.fromJson(e)).toList(),
        targets: (raw['targets'] as List? ?? []).map((e) => TargetModel.fromJson(e)).toList(),
        transaksiList: (raw['transaksiList'] as List? ?? []).map((e) => TransaksiModel.fromJson(e)).toList(),
        achievements: (raw['achievements'] as List? ?? []).map((e) => AchievementModel.fromJson(e)).toList(),
        eventLog: (raw['eventLog'] as List? ?? []).cast<String>(),
      );
    }
    _checkEarlyWarningSystem(_state.saldo);
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_userId == null) return;
    await _storage.saveSimulation(_userId!, {
      'status': _state.status.name,
      'currentDay': _state.currentDay,
      'currentPeriod': _state.currentPeriod,
      'totalHari': _state.totalHari,
      'saldo': _state.saldo,
      'saldoAwal': _state.saldoAwal,
      'periode': _state.periode?.name,
      'periodeHari': _state.periodeHari,
      'startDate': _state.startDate?.toIso8601String(),
      'bebanWajib': _state.bebanWajib.map((e) => e.toJson()).toList(),
      'targets': _state.targets.map((e) => e.toJson()).toList(),
      'transaksiList': _state.transaksiList.map((e) => e.toJson()).toList(),
      'achievements': _state.achievements.map((e) => e.toJson()).toList(),
      'eventLog': _state.eventLog,
    });
  }

  // ============================================================
  // ==================== SETUP & DRAFT =========================
  // ============================================================
  void startSetup() {
    _state = _state.copyWith(status: SimulationStatus.setup);
    notifyListeners();
  }

  void addDraftBeban(String nama, double jumlah) {
    _draftBebanWajib.add(BebanWajibModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: nama,
      jumlah: jumlah,
    ));
    notifyListeners();
  }

  void removeDraftBeban(String id) {
    _draftBebanWajib.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void addDraftTarget({
    required String nama,
    required String iconKey,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required double jumlahTarget,
  }) {
    _draftTargets.add(TargetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: nama,
      iconKey: iconKey,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalSelesai,
      jumlahTarget: jumlahTarget,
    ));
    notifyListeners();
  }

  void removeDraftTarget(String id) {
    _draftTargets.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void clearDraft() {
    _draftBebanWajib = [];
    _draftTargets = [];
    notifyListeners();
  }

  Future<void> finishSetup({
    required PeriodeType periode,
    required int periodeHari,
    required double saldoAwal,
  }) async {
    final totalBeban = _draftBebanWajib.fold<double>(0, (s, b) => s + b.jumlah);
    final saldoSetelahBeban = saldoAwal - totalBeban;

    _state = _state.copyWith(
      status: SimulationStatus.running,
      saldoAwal: saldoAwal,
      saldo: saldoSetelahBeban < 0 ? 0 : saldoSetelahBeban,
      currentDay: 0,
      currentPeriod: 1,
      totalHari: 0,
      periode: periode,
      periodeHari: periodeHari,
      startDate: DateTime.now(),
      bebanWajib: List.from(_draftBebanWajib),
      targets: List.from(_draftTargets),
      transaksiList: [],
      achievements: AchievementData.defaultList(),
      eventLog: [],
    );

    final trxBeban = TransaksiModel(
      id: 'beban_periode_1_${DateTime.now().millisecondsSinceEpoch}',
      keterangan: 'Beban wajib periode 1',
      jumlah: totalBeban,
      isPemasukan: false,
      hariKe: 0,
      tanggal: _state.currentRealDate,
      kategori: 'Beban Wajib',
    );
    _state = _state.copyWith(transaksiList: [trxBeban]);
    _checkAchievements();

    _draftBebanWajib = [];
    _draftTargets = [];
    await _persist();
    notifyListeners();
  }

  // ============================================================
  // ==================== TRANSAKSI =============================
  // ============================================================
  Future<bool> tambahTransaksi({
    required String keterangan,
    required double jumlah,
    required bool isPemasukan,
    required String kategori,
  }) async {
    if (!isPemasukan && jumlah > _state.saldo) return false;

    final trx = TransaksiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      keterangan: keterangan,
      jumlah: jumlah,
      isPemasukan: isPemasukan,
      hariKe: _state.totalHari,
      tanggal: _state.currentRealDate,
      kategori: kategori,
    );

    final newSaldo = isPemasukan ? _state.saldo + jumlah : _state.saldo - jumlah;
    final newList = List<TransaksiModel>.from(_state.transaksiList)..add(trx);

    _state = _state.copyWith(saldo: newSaldo, transaksiList: newList);
    _checkAchievements();
    _checkEarlyWarningSystem(newSaldo);

    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> hapusTransaksi(String id) async {
    final trx = _state.transaksiList.firstWhere(
      (t) => t.id == id,
      orElse: () => TransaksiModel(id: '', keterangan: '', jumlah: 0, isPemasukan: false, hariKe: 0, tanggal: DateTime.now()),
    );
    if (trx.id.isEmpty) return;
    if (trx.keterangan.startsWith('Beban wajib periode')) return;
    if (trx.keterangan.startsWith('Event:')) return;

    final newSaldo = trx.isPemasukan ? _state.saldo - trx.jumlah : _state.saldo + trx.jumlah;
    final newList = _state.transaksiList.where((t) => t.id != id).toList();

    _state = _state.copyWith(saldo: newSaldo, transaksiList: newList);
    _checkEarlyWarningSystem(newSaldo);
    await _persist();
    notifyListeners();
  }

  // ============================================================
  // ==================== MAJU HARI =============================
  // ============================================================
  Future<RandomEvent?> majuHari() async {
    if (!isRunning) return null;

    final periodeHari = _state.periodeHari ?? 30;
    final newDay = _state.currentDay + 1;
    final newTotal = _state.totalHari + 1;

    if (newDay >= periodeHari) {
      final newPeriod = _state.currentPeriod + 1;
      final totalBeban = totalBebanWajib;
      final saldoSisa = _state.saldo;
      final saldoSetelahBeban = saldoSisa - totalBeban;

      if (_state.totalPengeluaran <= (_state.saldoAwal * 0.8)) {
        _unlockAchievement('disiplin');
      }

      _state = _state.copyWith(
        currentDay: 0,
        currentPeriod: newPeriod,
        totalHari: newTotal,
        saldo: saldoSetelahBeban < 0 ? 0 : saldoSetelahBeban,
      );

      if (saldoSisa > 0) _unlockAchievement('survive_30');

      final trxBeban = TransaksiModel(
        id: 'beban_periode_${newPeriod}_${DateTime.now().millisecondsSinceEpoch}',
        keterangan: 'Beban wajib periode $newPeriod',
        jumlah: totalBeban,
        isPemasukan: false,
        hariKe: newTotal,
        tanggal: _state.currentRealDate,
        kategori: 'Beban Wajib',
      );
      _state = _state.copyWith(transaksiList: [..._state.transaksiList, trxBeban]);
    } else {
      _state = _state.copyWith(currentDay: newDay, totalHari: newTotal);
    }

    _checkAchievements();
    _checkEarlyWarningSystem(_state.saldo);

    final event = EventData.rollEvent();
    if (event != null) _pendingEvent = event;

    await _persist();
    notifyListeners();
    return event;
  }

  void clearPendingEvent() => _pendingEvent = null;

  // ============================================================
  // ==================== HANDLE EVENT ==========================
  // ============================================================
  Future<bool> terimaEvent(String sumber) async {
    if (_pendingEvent == null) return false;
    final event = _pendingEvent!;

    if (event.tipe == EventTipe.pemasukan && event.hadiah != null) {
      final trx = TransaksiModel(
        id: 'event_${event.id}_${DateTime.now().millisecondsSinceEpoch}',
        keterangan: 'Event: ${event.judul}',
        jumlah: event.hadiah!,
        isPemasukan: true,
        hariKe: _state.totalHari,
        tanggal: _state.currentRealDate,
        kategori: 'Event',
      );
      _state = _state.copyWith(saldo: _state.saldo + event.hadiah!, transaksiList: [..._state.transaksiList, trx], eventLog: [..._state.eventLog, event.id]);
    } else if (event.biaya > 0) {
      if (sumber == 'saldo') {
        if (event.biaya > _state.saldo) return false;
        final trx = TransaksiModel(
          id: 'event_${event.id}_${DateTime.now().millisecondsSinceEpoch}',
          keterangan: 'Event: ${event.judul}',
          jumlah: event.biaya,
          isPemasukan: false,
          hariKe: _state.totalHari,
          tanggal: _state.currentRealDate,
          kategori: 'Event',
        );
        _state = _state.copyWith(saldo: _state.saldo - event.biaya, transaksiList: [..._state.transaksiList, trx], eventLog: [..._state.eventLog, event.id]);
      } else if (sumber == 'dana_darurat') {
        final danaTargetIdx = _state.targets.indexWhere((t) => t.iconKey == 'shield' || t.nama.toLowerCase().contains('darurat'));
        if (danaTargetIdx == -1) return false;
        final dana = _state.targets[danaTargetIdx];
        if (event.biaya > dana.jumlahTerkumpul) return false;

        final newTargets = List<TargetModel>.from(_state.targets);
        newTargets[danaTargetIdx] = TargetModel(
          id: dana.id, nama: dana.nama, iconKey: dana.iconKey, tanggalMulai: dana.tanggalMulai, tanggalSelesai: dana.tanggalSelesai, jumlahTarget: dana.jumlahTarget, jumlahTerkumpul: dana.jumlahTerkumpul - event.biaya,
        );
        _state = _state.copyWith(targets: newTargets, eventLog: [..._state.eventLog, event.id]);
      }
    }

    _pendingEvent = null;
    _checkAchievements();
    _checkEarlyWarningSystem(_state.saldo);
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> tolakEvent() async {
    if (_pendingEvent == null) return;
    final event = _pendingEvent!;

    // Event Opsional ditolak tidak kena denda
    if (event.biaya > 0 && event.tipe == EventTipe.pengeluaran) {
      final konsekuensi = event.biaya * 0.5;
      final trx = TransaksiModel(
        id: 'event_tolak_${event.id}_${DateTime.now().millisecondsSinceEpoch}',
        keterangan: 'Denda: ${event.judul} (Ditolak)',
        jumlah: konsekuensi,
        isPemasukan: false,
        hariKe: _state.totalHari,
        tanggal: _state.currentRealDate,
        kategori: 'Event',
      );
      final newSaldo = _state.saldo - konsekuensi;
      _state = _state.copyWith(
        saldo: newSaldo < 0 ? 0 : newSaldo,
        transaksiList: [..._state.transaksiList, trx],
        eventLog: [..._state.eventLog, '${event.id}_ditolak'],
      );
    } else {
      _state = _state.copyWith(
        eventLog: [..._state.eventLog, '${event.id}_ditolak_tanpa_denda'],
      );
    }

    _pendingEvent = null;
    _checkEarlyWarningSystem(_state.saldo);
    await _persist();
    notifyListeners();
  }

  // ============================================================
  // ==================== ACHIEVEMENT ===========================
  // ============================================================
  void _checkAchievements() {
    if (_state.status == SimulationStatus.running) _unlockAchievement('start_sim');
    if (_state.totalHari >= 30 && _state.saldo > 0) _unlockAchievement('survive_30');

    if (_state.targets.isNotEmpty) {
      final totalTarget = _state.targets.fold<double>(0, (s, t) => s + t.jumlahTarget);
      final totalTerkumpul = _state.targets.fold<double>(0, (s, t) => s + t.jumlahTerkumpul);
      if (totalTarget > 0 && (totalTerkumpul / totalTarget) >= 0.5) _unlockAchievement('hemat_50');
    }

    final danaDarurat = _state.targets.where((t) => t.iconKey == 'shield' || t.nama.toLowerCase().contains('darurat')).fold<double>(0, (s, t) => s + t.jumlahTerkumpul);
    if (danaDarurat >= 500000) _unlockAchievement('dana_aman');
  }

  void _unlockAchievement(String id) {
    final idx = _state.achievements.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    if (_state.achievements[idx].unlocked) return;

    final newList = List<AchievementModel>.from(_state.achievements);
    final unlocked = newList[idx].copyWith(unlocked: true, unlockedAt: DateTime.now());
    newList[idx] = unlocked;

    _state = _state.copyWith(achievements: newList);
    _newAchievements.add(unlocked);
    notifyListeners();
  }

  void clearNewAchievements() {
    _newAchievements.clear();
    notifyListeners();
  }

  // ============================================================
  // ==================== NABUNG / AMBIL (SINKRON TRANSAKSI) ====
  // ============================================================
  Future<bool> nabungTarget(String targetId, double jumlah) async {
    if (jumlah > _state.saldo) return false;

    final target = _state.targets.firstWhere((t) => t.id == targetId);

    final newTargets = _state.targets.map((t) {
      if (t.id == targetId) {
        return TargetModel(id: t.id, nama: t.nama, iconKey: t.iconKey, tanggalMulai: t.tanggalMulai, tanggalSelesai: t.tanggalSelesai, jumlahTarget: t.jumlahTarget, jumlahTerkumpul: t.jumlahTerkumpul + jumlah);
      }
      return t;
    }).toList();

    final trx = TransaksiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      keterangan: 'Menabung: ${target.nama}',
      jumlah: jumlah,
      isPemasukan: false,
      hariKe: _state.totalHari,
      tanggal: _state.currentRealDate,
      kategori: 'Tabungan',
    );

    _state = _state.copyWith(
        saldo: _state.saldo - jumlah, 
        targets: newTargets, 
        transaksiList: [..._state.transaksiList, trx]
    );
    
    _checkAchievements();
    _checkEarlyWarningSystem(_state.saldo);
    await _persist();
    notifyListeners();
    return true;
  }

  Future<bool> ambilDariTarget(String targetId, double jumlah) async {
    final target = _state.targets.firstWhere((t) => t.id == targetId);
    if (jumlah > target.jumlahTerkumpul) return false;

    final newTargets = _state.targets.map((t) {
      if (t.id == targetId) {
        return TargetModel(id: t.id, nama: t.nama, iconKey: t.iconKey, tanggalMulai: t.tanggalMulai, tanggalSelesai: t.tanggalSelesai, jumlahTarget: t.jumlahTarget, jumlahTerkumpul: t.jumlahTerkumpul - jumlah);
      }
      return t;
    }).toList();

    final trx = TransaksiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      keterangan: 'Tarik Tabungan: ${target.nama}',
      jumlah: jumlah,
      isPemasukan: true,
      hariKe: _state.totalHari,
      tanggal: _state.currentRealDate,
      kategori: 'Tarik Tabungan',
    );

    _state = _state.copyWith(
        saldo: _state.saldo + jumlah, 
        targets: newTargets, 
        transaksiList: [..._state.transaksiList, trx]
    );

    _checkEarlyWarningSystem(_state.saldo);
    await _persist();
    notifyListeners();
    return true;
  }

  // ============================================================
  // ==================== EWS / RESET ===========================
  // ============================================================
  void _checkEarlyWarningSystem(double currentSaldo) {
    final danaDarurat = _state.totalDanaDarurat;
    final threshold = _state.totalBebanWajib * 0.2;

    if (currentSaldo <= 0) {
      _ewsMessage = "Waduh! Saldo kamu habis. Coba ambil dari tabungan target atau kurangi pengeluaran.";
    } else if (currentSaldo < threshold && danaDarurat <= 0) {
      _ewsMessage = "Peringatan! Saldo kamu menipis dan Dana Darurat kosong. Segera hemat!";
    } else {
      _ewsMessage = null;
    }
  }

  void clearEwsMessage() {
    _ewsMessage = null;
    notifyListeners();
  }

  void clearMemory() {
    _state = SimulationState();
    _draftBebanWajib = [];
    _draftTargets = [];
    _newAchievements.clear();
    _pendingEvent = null;
    _ewsMessage = null;
    _userId = null;
    notifyListeners();
  }

  Future<void> reset() async {
    if (_userId == null) return;
    await _storage.clearSimulation(_userId!);
    _state = SimulationState();
    _draftBebanWajib = [];
    _draftTargets = [];
    _newAchievements.clear();
    _pendingEvent = null;
    _ewsMessage = null;
    notifyListeners();
  }
}