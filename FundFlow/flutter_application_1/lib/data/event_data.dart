class RandomEvent {
  final String id;
  final String judul;
  final String deskripsi;
  final double biaya;         // biaya yang harus dibayar (0 kalau tidak ada)
  final double? hadiah;       // hadiah uang (kalau ada)
  final double weight;        // peluang (semakin besar semakin sering)
  final EventTipe tipe;

  const RandomEvent({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.biaya = 0,
    this.hadiah,
    required this.weight,
    required this.tipe,
  });
}

enum EventTipe {
  pengeluaran,   // harus bayar
  pemasukan,     // dapat uang
  opsional,      // user bisa pilih terima/tolak
}

class EventData {
  static const List<RandomEvent> all = [
    // ===== PENGELUARAN (BAD) =====
    RandomEvent(
      id: 'hp_rusak',
      judul: 'HP Rusak',
      deskripsi: 'HP kamu tiba-tiba mati. Harus service ke tukang.',
      biaya: 350000,
      weight: 12,
      tipe: EventTipe.pengeluaran,
    ),
    RandomEvent(
      id: 'sakit',
      judul: 'Sakit Demam',
      deskripsi: 'Kamu demam dan harus beli obat + periksa ke klinik.',
      biaya: 150000,
      weight: 15,
      tipe: EventTipe.pengeluaran,
    ),
    RandomEvent(
      id: 'ban_bocor',
      judul: 'Ban Motor Bocor',
      deskripsi: 'Di tengah jalan ban motor bocor. Harus tambal.',
      biaya: 50000,
      weight: 18,
      tipe: EventTipe.pengeluaran,
    ),
    RandomEvent(
      id: 'tugas_print',
      judul: 'Print Tugas Mendadak',
      deskripsi: 'Dosen minta print tugas tebal. Kecebur biaya print.',
      biaya: 30000,
      weight: 20,
      tipe: EventTipe.pengeluaran,
    ),
    RandomEvent(
      id: 'kondangan',
      judul: 'Kondangan Teman',
      deskripsi: 'Teman sekelas nikah, wajib bawa kado + transport.',
      biaya: 200000,
      weight: 14,
      tipe: EventTipe.pengeluaran,
    ),
    RandomEvent(
      id: 'kehilangan',
      judul: 'Dompet Hilang',
      deskripsi: 'Dompetmu hilang di kantin. Uang tunai di dalamnya raib.',
      biaya: 100000,
      weight: 8,
      tipe: EventTipe.pengeluaran,
    ),

    // ===== PEMASUKAN (GOOD) =====
    RandomEvent(
      id: 'beasiswa',
      judul: 'Dapat Beasiswa',
      deskripsi: 'Kamu dapat beasiswa prestasi mini. Cuan!',
      hadiah: 500000,
      weight: 5,
      tipe: EventTipe.pemasukan,
    ),
    RandomEvent(
      id: 'freelance',
      judul: 'Proyek Freelance',
      deskripsi: 'Kamu dapat proyek freelance kecil dari kampus.',
      hadiah: 300000,
      weight: 8,
      tipe: EventTipe.pemasukan,
    ),
    RandomEvent(
      id: 'uang_saku_bonus',
      judul: 'Bonus dari Orang Tua',
      deskripsi: 'Orang tua kirim uang saku tambahan.',
      hadiah: 250000,
      weight: 12,
      tipe: EventTipe.pemasukan,
    ),

    // ===== OPSIONAL =====
    RandomEvent(
      id: 'diskon_gadget',
      judul: 'Diskon Gadget',
      deskripsi: 'Ada diskon flash sale gadget idaman. Mau beli?',
      biaya: 750000,
      weight: 10,
      tipe: EventTipe.opsional,
    ),
  ];

  /// Poin 4: sistem gacha — 25% kemungkinan event muncul per maju hari
  static const double peluangEventPerHari = 0.25;

  /// Pilih event random berdasarkan weight
  static RandomEvent? rollEvent() {
    // Roll dulu apakah event muncul
    final roll = _random.nextDouble();
    if (roll > peluangEventPerHari) return null;

    // Kalau muncul, pilih event berdasarkan weight
    final totalWeight = all.fold<double>(0, (s, e) => s + e.weight);
    var pick = _random.nextDouble() * totalWeight;
    for (final e in all) {
      pick -= e.weight;
      if (pick <= 0) return e;
    }
    return all.first;
  }
}

// Simple random generator
final _random = _SimpleRandom();

class _SimpleRandom {
  int _seed = DateTime.now().millisecondsSinceEpoch;
  double nextDouble() {
    _seed = (_seed * 9301 + 49297) % 233280;
    return _seed / 233280;
  }
}