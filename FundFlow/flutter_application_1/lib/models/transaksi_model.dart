class TransaksiModel {
  final String id;
  final String keterangan;
  final double jumlah;
  final bool isPemasukan;
  final int hariKe; // hari ke-berapa dalam simulasi
  final DateTime tanggal;

  TransaksiModel({
    required this.id,
    required this.keterangan,
    required this.jumlah,
    required this.isPemasukan,
    required this.hariKe,
    required this.tanggal,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'keterangan': keterangan,
        'jumlah': jumlah,
        'isPemasukan': isPemasukan,
        'hariKe': hariKe,
        'tanggal': tanggal.toIso8601String(),
      };

  factory TransaksiModel.fromJson(Map<String, dynamic> json) => TransaksiModel(
        id: json['id'] ?? '',
        keterangan: json['keterangan'] ?? '',
        jumlah: (json['jumlah'] ?? 0).toDouble(),
        isPemasukan: json['isPemasukan'] ?? false,
        hariKe: json['hariKe'] ?? 0,
        tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      );
}