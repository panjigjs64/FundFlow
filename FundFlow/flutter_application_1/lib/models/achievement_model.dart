class AchievementModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String iconKey;
  final bool unlocked;
  final DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.iconKey,
    this.unlocked = false,
    this.unlockedAt,
  });

  AchievementModel copyWith({bool? unlocked, DateTime? unlockedAt}) {
    return AchievementModel(
      id: id,
      judul: judul,
      deskripsi: deskripsi,
      iconKey: iconKey,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'judul': judul, 'deskripsi': deskripsi,
        'iconKey': iconKey, 'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory AchievementModel.fromJson(Map<String, dynamic> json) => AchievementModel(
        id: json['id'] ?? '', judul: json['judul'] ?? '',
        deskripsi: json['deskripsi'] ?? '', iconKey: json['iconKey'] ?? 'star',
        unlocked: json['unlocked'] ?? false,
        unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt']) : null,
      );
}

class AchievementData {
  static List<AchievementModel> defaultList() => [
        AchievementModel(id: 'start_sim', judul: 'Langkah Awal', deskripsi: 'Selesaikan setup simulasi pertamamu.', iconKey: 'flag'),
        AchievementModel(id: 'survive_30', judul: 'Penyintas 30 Hari', deskripsi: 'Bertahan hidup 30 hari tanpa kehabisan saldo.', iconKey: 'shield'),
        AchievementModel(id: 'hemat_50', judul: 'Pahlawan Hemat', deskripsi: 'Kumpulkan 50% dari total target tabunganmu.', iconKey: 'savings'),
        AchievementModel(id: 'dana_aman', judul: 'Dana Aman', deskripsi: 'Kumpulkan Dana Darurat minimal Rp 500.000.', iconKey: 'lock'),
        AchievementModel(id: 'disiplin', judul: 'Disiplin Tinggi', deskripsi: 'Selesaikan 1 periode tanpa boros.', iconKey: 'star'),
      ];
}