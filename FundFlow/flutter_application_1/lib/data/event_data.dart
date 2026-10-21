

class RandomEvent {
  final String id;
  final String judul;
  final String deskripsi;
  final double biaya;
  final double? hadiah;
  final double weight;
  final EventTipe tipe;

  const RandomEvent({
    required this.id, required this.judul, required this.deskripsi,
    this.biaya = 0, this.hadiah, required this.weight, required this.tipe,
  });
}

enum EventTipe { pengeluaran, pemasukan, opsional }

class EventData {
  static const List<RandomEvent> all = [
    // ===== PENGELUARAN (BAD) =====
    RandomEvent(id: 'ban_bocor', judul: 'Ban Motor Bocor', deskripsi: 'Di tengah jalan ban motor bocor. Harus tambal.', biaya: 30000, weight: 15, tipe: EventTipe.pengeluaran),
    RandomEvent(id: 'tugas_print', judul: 'Print Tugas', deskripsi: 'Dosen minta print tugas tebal. Kecebur biaya print.', biaya: 25000, weight: 15, tipe: EventTipe.pengeluaran),
    RandomEvent(id: 'sakit', judul: 'Sakit Demam', deskripsi: 'Kamu demam dan harus beli obat + periksa ke klinik.', biaya: 150000, weight: 12, tipe: EventTipe.pengeluaran),
    RandomEvent(id: 'kondangan', judul: 'Kondangan Teman', deskripsi: 'Teman sekelas nikah, wajib bawa kado + transport.', biaya: 200000, weight: 10, tipe: EventTipe.pengeluaran),
    RandomEvent(id: 'kuota_habis', judul: 'Kuota Habis', deskripsi: 'Kuota internet habis di tengah ujian online.', biaya: 50000, weight: 15, tipe: EventTipe.pengeluaran),
    RandomEvent(id: 'service_hp', judul: 'HP Rusak', deskripsi: 'Layar HP tiba-tiba mati total. Harus service.', biaya: 350000, weight: 8, tipe: EventTipe.pengeluaran),

    // ===== PEMASUKAN (GOOD) =====
    RandomEvent(id: 'uang_bonus', judul: 'Uang Saku Bonus', deskripsi: 'Orang tua kirim uang saku tambahan.', hadiah: 250000, weight: 10, tipe: EventTipe.pemasukan),
    RandomEvent(id: 'freelance', judul: 'Proyek Freelance', deskripsi: 'Kamu dapat proyek freelance kecil dari kampus.', hadiah: 300000, weight: 8, tipe: EventTipe.pemasukan),
    RandomEvent(id: 'beasiswa', judul: 'Beasiswa Mini', deskripsi: 'Kamu menang lomba esai tingkat jurusan. Cuan!', hadiah: 500000, weight: 5, tipe: EventTipe.pemasukan),

    // ===== OPSIONAL =====
    RandomEvent(id: 'diskon_gadget', judul: 'Diskon Gadget', deskripsi: 'Ada flash sale gadget idaman. Mau beli?', biaya: 750000, weight: 10, tipe: EventTipe.opsional),
  ];

  static const double peluangEventPerHari = 0.25;

  static RandomEvent? rollEvent() {
    final roll = _random.nextDouble();
    if (roll > peluangEventPerHari) return null;

    final totalWeight = all.fold<double>(0, (s, e) => s + e.weight);
    var pick = _random.nextDouble() * totalWeight;
    for (final e in all) {
      pick -= e.weight;
      if (pick <= 0) return e;
    }
    return all.first;
  }
}

final _random = _SimpleRandom();

class _SimpleRandom {
  int _seed = DateTime.now().millisecondsSinceEpoch;
  double nextDouble() {
    _seed = (_seed * 9301 + 49297) % 233280;
    return _seed / 233280;
  }
}