import 'package:flutter/material.dart';

class AppColors {
  // ===== PRIMARY =====
  static const Color primaryBlue = Color(0xFF3399FF);
  static const Color primaryGreen = Color(0xFF33CC66);

  // ===== TEXT =====
  static const Color darkNavy = Color(0xFF334155);
  static const Color black = Color(0xFF000000);
  static const Color textGrey = Color(0xFF64748B);

  // ===== BACKGROUND =====
  static const Color offWhite = Color(0xFFF8FAFC);

  // ===== ACCENT =====
  static const Color deepBlue = Color(0xFF2563EB);
  static const Color lightGrey = Color(0xFFD9D9D9);
  static const Color dangerRed = Color(0xFFE95252);

  // ===== GRADIENT HEADER =====
  static const Color headerGreenLight = Color(0xFFC8F0D4);
  static const Color headerBlueLight = Color(0xFFCCE4FF);

  // ============================================================
  // ==================== DARK MODE COLORS ======================
  // ============================================================
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkHeaderGreen = Color(0xFF1A3A2E);
  static const Color darkHeaderBlue = Color(0xFF1A2F4A);

  // ===== ALIAS =====
  static const Color primary = primaryGreen;
  static const Color textDark = darkNavy;
  static const Color cardWhite = Colors.white;
  static const Color bgLight = offWhite;

  // ===== HELPER =====
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDark(context) ? darkBg : offWhite;
  static Color card(BuildContext context) =>
      isDark(context) ? darkCard : Colors.white;
  static Color text(BuildContext context) =>
      isDark(context) ? darkTextPrimary : darkNavy;
  static Color textSub(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textGrey;
  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightGrey;
  static Color inputFill(BuildContext context) =>
      isDark(context) ? darkSurface : offWhite;
}