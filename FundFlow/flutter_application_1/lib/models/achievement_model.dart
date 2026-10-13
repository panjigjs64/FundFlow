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

  AchievementModel copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
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
        'id': id,
        'judul': judul,
        'deskripsi': deskripsi,
        'iconKey': iconKey,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'] ?? '',
        judul: json['judul'] ?? '',
        deskripsi: json['deskripsi'] ?? '',
        iconKey: json['iconKey'] ?? 'star',
        unlocked: json['unlocked'] ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.tryParse(json['unlockedAt'])
            : null,
      );
}

class AchievementData {
  static List<AchievementModel> defaultList() => [
        AchievementModel(
          id: 'survive_30',
          judul: 'Survivor 30 Hari',
          deskripsi: 'Bertahan 30 hari tanpa kehabisan saldo',
          iconKey: 'shield',
        ),
        AchievementModel(
          id: 'hemat_50',
          judul: 'Hemat Setengah',
          deskripsi: 'Kumpulkan tabungan 50% dari target',
          iconKey: 'savings',
        ),
        AchievementModel(
          id: 'saldo_positif',
          judul: 'Saldo Aman',
          deskripsi: 'Selesaikan periode dengan saldo positif',
          iconKey: 'star',
        ),
      ];
}