class TargetModel {
  final String id;
  final String nama;
  final String iconKey;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final double jumlahTarget;
  final double jumlahTerkumpul;

  TargetModel({
    required this.id,
    required this.nama,
    required this.iconKey,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.jumlahTarget,
    this.jumlahTerkumpul = 0,
  });

  double get progress =>
      jumlahTarget > 0
          ? (jumlahTerkumpul / jumlahTarget).clamp(0.0, 1.0)
          : 0.0;

  /// Total hari dari mulai sampai selesai
  int get totalHari =>
      tanggalSelesai.difference(tanggalMulai).inDays + 1;

  /// Sisa hari dari sekarang
  int get sisaHari {
    final now = DateTime.now();
    if (now.isAfter(tanggalSelesai)) return 0;
    return tanggalSelesai.difference(now).inDays + 1;
  }

  /// Progress waktu (0.0 - 1.0) — berapa persen waktu sudah berjalan
  double get progressWaktu {
    if (totalHari <= 0) return 0;
    final terlewat = totalHari - sisaHari;
    return (terlewat / totalHari).clamp(0.0, 1.0);
  }

  /// Target tabungan per hari
  double get targetPerHari {
    if (totalHari <= 0) return 0;
    return jumlahTarget / totalHari;
  }

  /// Apakah target sudah lewat deadline?
  bool get isKadaluarsa {
    return DateTime.now().isAfter(tanggalSelesai) && progress < 1.0;
  }

  /// Format tanggal untuk display
  String get labelPeriode {
    return '${_formatDate(tanggalMulai)} – ${_formatDate(tanggalSelesai)}';
  }

  String _formatDate(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'iconKey': iconKey,
        'tanggalMulai': tanggalMulai.toIso8601String(),
        'tanggalSelesai': tanggalSelesai.toIso8601String(),
        'jumlahTarget': jumlahTarget,
        'jumlahTerkumpul': jumlahTerkumpul,
      };

  factory TargetModel.fromJson(Map<String, dynamic> json) => TargetModel(
        id: json['id'] ?? '',
        nama: json['nama'] ?? '',
        iconKey: json['iconKey'] ?? 'shield',
        tanggalMulai: DateTime.tryParse(json['tanggalMulai'] ?? '') ??
            DateTime.now(),
        tanggalSelesai: DateTime.tryParse(json['tanggalSelesai'] ?? '') ??
            DateTime.now().add(const Duration(days: 30)),
        jumlahTarget: (json['jumlahTarget'] ?? 0).toDouble(),
        jumlahTerkumpul: (json['jumlahTerkumpul'] ?? 0).toDouble(),
      );
}