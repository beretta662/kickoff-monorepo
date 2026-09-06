import 'package:flutter/material.dart';

/// Fonds, bordures et texte : ce qui change entre clair et sombre.
/// S'utilise avec `final palette = AppPalette.of(context);` dans un
/// build(), puis `palette.textPrimary`, `palette.surface`, etc.
class AppPalette {
  final Color background;
  final Color surface;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static const light = AppPalette(
    background: Color(0xFFF5F4FA),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFECEAF5),
    borderStrong: Color(0xFFD8D5E8),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF55516B),
    textMuted: Color(0xFF8A86A0),
  );

  static const dark = AppPalette(
    background: Color(0xFF14121A),
    surface: Color(0xFF1E1B2E),
    border: Color(0xFF2C2940),
    borderStrong: Color(0xFF3E3A56),
    textPrimary: Color(0xFFF5F4FA),
    textSecondary: Color(0xFFB8B4CC),
    textMuted: Color(0xFF8A86A0),
  );

  static AppPalette of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}