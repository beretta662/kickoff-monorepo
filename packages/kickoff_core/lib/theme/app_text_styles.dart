import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';

/// Styles de texte réutilisables. Chaque style est une fonction qui
/// prend le `context` en argument (ex. `AppTextStyles.h1(context)`),
/// pour appliquer automatiquement la bonne couleur selon le thème.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle h1(BuildContext context) => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppPalette.of(context).textPrimary,
      );

  static TextStyle h2(BuildContext context) => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppPalette.of(context).textPrimary,
      );

  static TextStyle h3(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppPalette.of(context).textPrimary,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppPalette.of(context).textPrimary,
      );

  static TextStyle bodySecondary(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppPalette.of(context).textSecondary,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppPalette.of(context).textMuted,
      );

  /// N'a pas besoin de context : la couleur du bouton vient déjà du
  /// thème (ElevatedButtonTheme / OutlinedButtonTheme), pas d'ici.
  static TextStyle button = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static TextStyle score(BuildContext context) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppPalette.of(context).textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}