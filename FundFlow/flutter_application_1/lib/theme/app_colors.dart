import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // ==================== LIGHT MODE (FUNFLOW THEME) ============
  // ============================================================
  
  // 1. PRIMARY (Emerald Green)
  static const Color primaryGreen = Color(0xFF20B493); 
  static const Color primaryBlue = Color(0xFF8ED5F7); // Sky Blue (Digunakan sebagai aksen)

  // 2. SECONDARY (Deep Teal)
  static const Color deepTeal = Color(0xFF087F69); 

  // 3. SOFT ACCENT (Mint Green) & (Ice Blue)
  static const Color mintGreen = Color(0xFFBDEFD9);
  static const Color iceBlue = Color(0xFFDDF3FC);

  // 4. BACKGROUND
  static const Color offWhite = Color(0xFFF5FBF9); // Soft White
  static const Color darkNavy = Color(0xFF174D43); // Deep Teal Text (Untuk teks utama)
  static const Color textGrey = Color(0xFF28665A); // Forest Teal Text (Untuk sub-teks)

  // 5. STATUS
  static const Color dangerRed = Color(0xFFE95252); // Tetap pakai merah untuk error/hapus
  static const Color orange = Color(0xFFF59E0B);

  // 6. HEADER GRADIENT
  static const Color headerGreenLight = Color(0xFFBDEFD9); // Mint
  static const Color headerBlueLight = Color(0xFFDDF3FC);  // Ice Blue

  // ============================================================
  // ==================== DARK MODE =============================
  // ============================================================
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkHeaderGreen = Color(0xFF0B3A31);
  static const Color darkHeaderBlue = Color(0xFF0F2A3F);

  // ===== ALIAS (Agar komponen lama tidak error) =====
  static const Color primary = primaryGreen;
  static const Color textDark = darkNavy;
  static const Color cardWhite = Colors.white;
  static const Color bgLight = offWhite;
  static const Color lightGrey = Color(0xFFE2E8F0); // Border abu-abu terang
  static const Color accentBlue = primaryBlue;

  // ============================================================
  // ==================== HELPER FUNCTIONS ======================
  // ============================================================
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
      isDark(context) ? darkBorder : const Color(0xFFE2E8F0);

  static Color inputFill(BuildContext context) =>
      isDark(context) ? darkSurface : const Color(0xFFF8FAFC);
}