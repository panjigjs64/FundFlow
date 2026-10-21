class TransaksiModel {
  final String id;
  final String keterangan;
  final double jumlah;
  final bool isPemasukan;
  final int hariKe;
  final DateTime tanggal;
  final String kategori; // BARU: Makanan, Transport, dll

  TransaksiModel({
    required this.id,
    required this.keterangan,
    required this.jumlah,
    required this.isPemasukan,
    required this.hariKe,
    required this.tanggal,
    this.kategori = 'Lainnya',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'keterangan': keterangan,
        'jumlah': jumlah,
        'isPemasukan': isPemasukan,
        'hariKe': hariKe,
        'tanggal': tanggal.toIso8601String(),
        'kategori': kategori,
      };

  factory TransaksiModel.fromJson(Map<String, dynamic> json) => TransaksiModel(
        id: json['id'] ?? '',
        keterangan: json['keterangan'] ?? '',
        jumlah: (json['jumlah'] ?? 0).toDouble(),
        isPemasukan: json['isPemasukan'] ?? false,
        hariKe: json['hariKe'] ?? 0,
        tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
        kategori: json['kategori'] ?? 'Lainnya',
      );
}