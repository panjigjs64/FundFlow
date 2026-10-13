import 'package:flutter/material.dart';
import '../models/simulation_state.dart';
import '../models/beban_wajib_model.dart';
import '../models/target_model.dart';
import '../models/transaksi_model.dart';
import '../models/achievement_model.dart';
import '../data/event_data.dart';
import '../repositories/local_storage.dart';

class SimulationProvider extends ChangeNotifier {
  final LocalStorage _storage = LocalStorage();

  SimulationState _state = SimulationState();
  String? _userId;

  List<BebanWajibModel> _draftBebanWajib = [];
  List<TargetModel> _draftTargets = [];

  final List<AchievementModel> _newAchievements = [];
  RandomEvent? _pendingEvent;

  // ===== GETTER =====
  SimulationState get state => _state;
  List<BebanWajibModel> get draftBebanWajib => _draftBebanWajib;
  List<TargetModel> get draftTargets => _draftTargets;
  List<AchievementModel> get newAchievements => _newAchievements;
  RandomEvent? get pendingEvent => _pendingEvent;
  String? get userId => _userId;

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
  // ==================== LOAD / PERSIST ========================
  // ============================================================
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    final raw = await _storage.getSimulation(userId);

    debugPrint('📥 LOAD for user=$userId, rawExists=${raw != null}');

    if (raw == null) {
      _state = SimulationState();
    } else {
      _state = SimulationState(
        status: SimulationStatus.values.firstWhere(
          (s) => s.name == (raw['status'] ?? 'idle'),
          orElse: () => SimulationStatus.idle,
        ),
        currentDay: raw['currentDay'] ?? 0,
        currentPeriod: raw['currentPeriod'] ?? 1,
        totalHari: raw['totalHari'] ?? 0,
        saldo: (raw['saldo'] ?? 0).toDouble(),
        saldoAwal: (raw['saldoAwal'] ?? 0).toDouble(),
        periode: raw['periode'] != null
            ? PeriodeType.values.firstWhere(
                (p) => p.name == raw['periode'],
                orElse: () => PeriodeType.bulanan,
              )
            : null,
        periodeHari: raw['periodeHari'],
        bebanWajib: (raw['bebanWajib'] as List? ?? [])
            .map((e) => BebanWajibModel.fromJson(e))
            .toList(),
        targets: (raw['targets'] as List? ?? [])
            .map((e) => TargetModel.fromJson(e))
            .toList(),
        transaksiList: (raw['transaksiList'] as List? ?? [])
            .map((e) => TransaksiModel.fromJson(e))
            .toList(),
        achievements: (raw['achievements'] as List? ?? [])
            .map((e) => AchievementModel.fromJson(e))
            .toList(),
        eventLog: (raw['eventLog'] as List? ?? []).cast<String>(),
      );

      debugPrint(
          '✅ LOADED: status=${_state.status}, saldo=${_state.saldo}, hari=${_state.totalHari}');
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_userId == null) {
      debugPrint('⚠️ PERSIST SKIPPED: userId null');
      return;
    }
    await _storage.saveSimulation(_userId!, {
      'status': _state.status.name,
      'currentDay': _state.currentDay,
      'currentPeriod': _state.currentPeriod,
      'totalHari': _state.totalHari,
      'saldo': _state.saldo,
      'saldoAwal': _state.saldoAwal,
      'periode': _state.periode?.name,
      'periodeHari': _state.periodeHari,
      'bebanWajib': _state.bebanWajib.map((e) => e.toJson()).toList(),
      'targets': _state.targets.map((e) => e.toJson()).toList(),
      'transaksiList':
          _state.transaksiList.map((e) => e.toJson()).toList(),
      'achievements': _state.achievements.map((e) => e.toJson()).toList(),
      'eventLog': _state.eventLog,
    });
    debugPrint(
        '💾 SAVED: userId=$_userId, status=${_state.status}, saldo=${_state.saldo}, hari=${_state.totalHari}');
  }

  // ============================================================
  // ==================== DRAFT MANAGEMENT ======================
  // ============================================================
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

  // ============================================================
  // ==================== FINISH SETUP ==========================
  // ============================================================
  Future<void> finishSetup({
    required PeriodeType periode,
    required int periodeHari,
    required double saldoAwal,
  }) async {
    final totalBeban =
        _draftBebanWajib.fold<double>(0, (s, b) => s + b.jumlah);
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
      tanggal: DateTime.now(),
    );
    final newList = List<TransaksiModel>.from(_state.transaksiList)
      ..add(trxBeban);
    _state = _state.copyWith(transaksiList: newList);

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
  }) async {
    if (!isPemasukan && jumlah > _state.saldo) return false;

    final trx = TransaksiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      keterangan: keterangan,
      jumlah: jumlah,
      isPemasukan: isPemasukan,
      hariKe: _state.totalHari,
      tanggal: DateTime.now(),
    );

    final newSaldo =
        isPemasukan ? _state.saldo + jumlah : _state.saldo - jumlah;
    final newList = List<TransaksiModel>.from(_state.transaksiList)..add(trx);

    _state = _state.copyWith(saldo: newSaldo, transaksiList: newList);
    _checkAchievements();
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> hapusTransaksi(String id) async {
    final trx = _state.transaksiList.firstWhere(
      (t) => t.id == id,
      orElse: () => TransaksiModel(
        id: '',
        keterangan: '',
        jumlah: 0,
        isPemasukan: false,
        hariKe: 0,
        tanggal: DateTime.now(),
      ),
    );
    if (trx.id.isEmpty) return;
    if (trx.keterangan.startsWith('Beban wajib periode')) return;
    if (trx.keterangan.startsWith('Event:')) return;

    final newSaldo = trx.isPemasukan
        ? _state.saldo - trx.jumlah
        : _state.saldo + trx.jumlah;
    final newList =
        _state.transaksiList.where((t) => t.id != id).toList();

    _state = _state.copyWith(saldo: newSaldo, transaksiList: newList);
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

      _state = _state.copyWith(
        currentDay: 0,
        currentPeriod: newPeriod,
        totalHari: newTotal,
        saldo: saldoSetelahBeban < 0 ? 0 : saldoSetelahBeban,
      );

      if (saldoSisa > 0) {
        _unlockAchievement('saldo_positif');
      }

      final trxBeban = TransaksiModel(
        id: 'beban_periode_${newPeriod}_${DateTime.now().millisecondsSinceEpoch}',
        keterangan: 'Beban wajib periode $newPeriod',
        jumlah: totalBeban,
        isPemasukan: false,
        hariKe: newTotal,
        tanggal: DateTime.now(),
      );
      final newList = List<TransaksiModel>.from(_state.transaksiList)
        ..add(trxBeban);
      _state = _state.copyWith(transaksiList: newList);
    } else {
      _state = _state.copyWith(
        currentDay: newDay,
        totalHari: newTotal,
      );
    }

    _checkAchievements();

    final event = EventData.rollEvent();
    if (event != null) {
      _pendingEvent = event;
    }

    await _persist();
    notifyListeners();
    return event;
  }

  void clearPendingEvent() {
    _pendingEvent = null;
  }

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
        tanggal: DateTime.now(),
      );
      final newList = List<TransaksiModel>.from(_state.transaksiList)
        ..add(trx);
      _state = _state.copyWith(
        saldo: _state.saldo + event.hadiah!,
        transaksiList: newList,
        eventLog: [..._state.eventLog, event.id],
      );
    } else if (event.biaya > 0) {
      if (sumber == 'saldo') {
        if (event.biaya > _state.saldo) return false;
        final trx = TransaksiModel(
          id: 'event_${event.id}_${DateTime.now().millisecondsSinceEpoch}',
          keterangan: 'Event: ${event.judul}',
          jumlah: event.biaya,
          isPemasukan: false,
          hariKe: _state.totalHari,
          tanggal: DateTime.now(),
        );
        final newList = List<TransaksiModel>.from(_state.transaksiList)
          ..add(trx);
        _state = _state.copyWith(
          saldo: _state.saldo - event.biaya,
          transaksiList: newList,
          eventLog: [..._state.eventLog, event.id],
        );
      } else if (sumber == 'dana_darurat') {
        final danaTargetIdx = _state.targets.indexWhere((t) =>
            t.iconKey == 'shield' ||
            t.nama.toLowerCase().contains('darurat'));
        if (danaTargetIdx == -1) return false;
        final dana = _state.targets[danaTargetIdx];
        if (event.biaya > dana.jumlahTerkumpul) return false;

        final newTargets = List<TargetModel>.from(_state.targets);
        newTargets[danaTargetIdx] = TargetModel(
          id: dana.id,
          nama: dana.nama,
          iconKey: dana.iconKey,
          tanggalMulai: dana.tanggalMulai,
          tanggalSelesai: dana.tanggalSelesai,
          jumlahTarget: dana.jumlahTarget,
          jumlahTerkumpul: dana.jumlahTerkumpul - event.biaya,
        );
        _state = _state.copyWith(
          targets: newTargets,
          eventLog: [..._state.eventLog, event.id],
        );
      }
    }

    _pendingEvent = null;
    _checkAchievements();
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> tolakEvent() async {
    if (_pendingEvent == null) return;
    final event = _pendingEvent!;

    if (event.biaya > 0) {
      final konsekuensi = event.biaya * 0.5;
      final trx = TransaksiModel(
        id: 'event_tolak_${event.id}_${DateTime.now().millisecondsSinceEpoch}',
        keterangan: 'Konsekuensi: ${event.judul} (ditolak)',
        jumlah: konsekuensi,
        isPemasukan: false,
        hariKe: _state.totalHari,
        tanggal: DateTime.now(),
      );
      final newList = List<TransaksiModel>.from(_state.transaksiList)
        ..add(trx);
      final newSaldo = _state.saldo - konsekuensi;
      _state = _state.copyWith(
        saldo: newSaldo < 0 ? 0 : newSaldo,
        transaksiList: newList,
        eventLog: [..._state.eventLog, '${event.id}_ditolak'],
      );
    }

    _pendingEvent = null;
    await _persist();
    notifyListeners();
  }

  // ============================================================
  // ==================== ACHIEVEMENT ===========================
  // ============================================================
  void _checkAchievements() {
    if (_state.totalHari >= 30 && _state.saldo > 0) {
      _unlockAchievement('survive_30');
    }

    for (final t in _state.targets) {
      if (t.jumlahTarget > 0 &&
          t.jumlahTerkumpul / t.jumlahTarget >= 0.5) {
        _unlockAchievement('hemat_50');
        break;
      }
    }
  }

  void _unlockAchievement(String id) {
    final idx = _state.achievements.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    if (_state.achievements[idx].unlocked) return;

    final newList = List<AchievementModel>.from(_state.achievements);
    final unlocked = newList[idx].copyWith(
      unlocked: true,
      unlockedAt: DateTime.now(),
    );
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
  // ==================== NABUNG / AMBIL ========================
  // ============================================================
  Future<bool> nabungTarget(String targetId, double jumlah) async {
    if (jumlah > _state.saldo) return false;

    final newTargets = _state.targets.map((t) {
      if (t.id == targetId) {
        return TargetModel(
          id: t.id,
          nama: t.nama,
          iconKey: t.iconKey,
          tanggalMulai: t.tanggalMulai,
          tanggalSelesai: t.tanggalSelesai,
          jumlahTarget: t.jumlahTarget,
          jumlahTerkumpul: t.jumlahTerkumpul + jumlah,
        );
      }
      return t;
    }).toList();

    _state = _state.copyWith(
      saldo: _state.saldo - jumlah,
      targets: newTargets,
    );

    _checkAchievements();
    await _persist();
    notifyListeners();
    return true;
  }

  Future<bool> ambilDariTarget(String targetId, double jumlah) async {
    final target = _state.targets.firstWhere((t) => t.id == targetId);
    if (jumlah > target.jumlahTerkumpul) return false;

    final newTargets = _state.targets.map((t) {
      if (t.id == targetId) {
        return TargetModel(
          id: t.id,
          nama: t.nama,
          iconKey: t.iconKey,
          tanggalMulai: t.tanggalMulai,
          tanggalSelesai: t.tanggalSelesai,
          jumlahTarget: t.jumlahTarget,
          jumlahTerkumpul: t.jumlahTerkumpul - jumlah,
        );
      }
      return t;
    }).toList();

    _state = _state.copyWith(
      saldo: _state.saldo + jumlah,
      targets: newTargets,
    );

    await _persist();
    notifyListeners();
    return true;
  }

  // ============================================================
  // ==================== CLEAR MEMORY (baru) ===================
  // ============================================================
  /// Bersihkan state di MEMORI saja, TIDAK hapus dari storage.
  /// Dipakai sebelum load user baru (login/logout).
  void clearMemory() {
    _state = SimulationState();
    _draftBebanWajib = [];
    _draftTargets = [];
    _newAchievements.clear();
    _pendingEvent = null;
    _userId = null;
    debugPrint('🧹 MEMORY CLEARED (storage tetap aman)');
    notifyListeners();
  }

  // ============================================================
  // ==================== RESET PERMANEN ========================
  // ============================================================
  /// Hapus data dari STORAGE juga (dipakai tombol Reset di app).
  Future<void> reset() async {
    if (_userId == null) return;
    await _storage.clearSimulation(_userId!);
    _state = SimulationState();
    _draftBebanWajib = [];
    _draftTargets = [];
    _newAchievements.clear();
    _pendingEvent = null;
    notifyListeners();
  }
}