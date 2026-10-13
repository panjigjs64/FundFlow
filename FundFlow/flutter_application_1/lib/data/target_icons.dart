import 'package:flutter/material.dart';

class TargetIcon {
  final String key;
  final IconData icon;
  final Color color;
  final String label;

  const TargetIcon({
    required this.key,
    required this.icon,
    required this.color,
    required this.label,
  });
}

class TargetIcons {
  static const List<TargetIcon> all = [
    TargetIcon(
      key: 'shield',
      icon: Icons.shield,
      color: Color(0xFFE95252),
      label: 'Dana Darurat',
    ),
    TargetIcon(
      key: 'education',
      icon: Icons.school,
      color: Color(0xFF2563EB),
      label: 'Pendidikan',
    ),
    TargetIcon(
      key: 'laptop',
      icon: Icons.laptop,
      color: Color(0xFF334155),
      label: 'Gadget',
    ),
    TargetIcon(
      key: 'home',
      icon: Icons.home,
      color: Color(0xFF33CC66),
      label: 'Rumah',
    ),
    TargetIcon(
      key: 'travel',
      icon: Icons.flight,
      color: Color(0xFF3399FF),
      label: 'Traveling',
    ),
    TargetIcon(
      key: 'car',
      icon: Icons.directions_car,
      color: Color(0xFF64748B),
      label: 'Kendaraan',
    ),
    TargetIcon(
      key: 'book',
      icon: Icons.menu_book,
      color: Color(0xFF8B5CF6),
      label: 'Buku',
    ),
    TargetIcon(
      key: 'savings',
      icon: Icons.savings,
      color: Color(0xFF33CC66),
      label: 'Tabungan',
    ),
    TargetIcon(
      key: 'health',
      icon: Icons.favorite,
      color: Color(0xFFE95252),
      label: 'Kesehatan',
    ),
    TargetIcon(
      key: 'gift',
      icon: Icons.card_giftcard,
      color: Color(0xFFF59E0B),
      label: 'Hadiah',
    ),
  ];

  static TargetIcon getByKey(String key) {
    return all.firstWhere(
      (t) => t.key == key,
      orElse: () => all.first,
    );
  }
}