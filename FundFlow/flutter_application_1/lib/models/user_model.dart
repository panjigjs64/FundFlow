class UserModel {
  final String id;
  final String nama;
  final String email;
  final String password;
  final String? institusi;
  final String? tingkat;
  final String? tahunLulus;
  final String? nomorTelepon;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    this.institusi,
    this.tingkat,
    this.tahunLulus,
    this.nomorTelepon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'email': email,
        'password': password,
        'institusi': institusi,
        'tingkat': tingkat,
        'tahunLulus': tahunLulus,
        'nomorTelepon': nomorTelepon,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        nama: json['nama'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        institusi: json['institusi'],
        tingkat: json['tingkat'],
        tahunLulus: json['tahunLulus'],
        nomorTelepon: json['nomorTelepon'],
      );
}