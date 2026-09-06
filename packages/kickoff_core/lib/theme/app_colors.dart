import 'package:flutter/material.dart';

/// Couleurs de marque et sémantiques : elles NE changent PAS entre le
/// mode clair et le mode sombre. Pour les fonds, bordures et texte,
/// qui eux changent selon le thème, voir AppPalette.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3C3489);
  static const Color primaryLight = Color(0xFFEEEDFE);
  static const Color accent = Color(0xFF534AB7);

  static const Color success = Color(0xFF3B6D11);
  static const Color successBg = Color(0xFFEAF3DE);
  static const Color danger = Color(0xFF791F1F);
  static const Color dangerBg = Color(0xFFF0EAEA);
  static const Color warning = Color(0xFF8A5A16);
  static const Color warningBg = Color(0xFFF5EBD2);

  static const Color neutral = Color(0xFF8A86A0);
  static const Color neutralBg = Color(0xFFF0EFF5);

  static const Color cardYellow = Color(0xFFF2C94C);
  static const Color cardRed = Color(0xFFC0392B);
}