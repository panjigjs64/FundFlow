class BebanWajibModel {
  final String id;
  final String nama;
  final double jumlah;

  BebanWajibModel({
    required this.id,
    required this.nama,
    required this.jumlah,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'jumlah': jumlah,
      };

  factory BebanWajibModel.fromJson(Map<String, dynamic> json) => BebanWajibModel(
        id: json['id'] ?? '',
        nama: json['nama'] ?? '',
        jumlah: (json['jumlah'] ?? 0).toDouble(),
      );
}