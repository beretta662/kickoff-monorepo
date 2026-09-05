import 'package:flutter/material.dart';

/// Palette de couleurs de Kickoff.
///
/// Règle d'or : aucune couleur ne doit être écrite "en dur"
/// (ex. `Color(0xFF3C3489)`) directement dans un écran ou un widget.
/// On passe toujours par une constante de cette classe. Ça évite deux
/// problèmes classiques : des couleurs légèrement différentes d'un écran
/// à l'autre par erreur de copier-coller, et une charte graphique difficile
/// à faire évoluer plus tard (un seul endroit à modifier ici).
class AppColors {
  AppColors._();

  // Marque
  static const Color primary = Color(0xFF3C3489);
  static const Color primaryLight = Color(0xFFEEEDFE);
  static const Color accent = Color(0xFF534AB7);

  // États sémantiques
  static const Color success = Color(0xFF3B6D11); // victoire, match terminé
  static const Color successBg = Color(0xFFEAF3DE);
  static const Color danger = Color(0xFF791F1F); // défaite, carton rouge, suppression
  static const Color dangerBg = Color(0xFFF0EAEA);
  static const Color warning = Color(0xFF8A5A16); // brouillon, à reprogrammer
  static const Color warningBg = Color(0xFFF5EBD2);

  // Neutre — utilisé notamment pour un match NUL dans la forme des 3
  // derniers matchs (jamais orange, voir mémo produit).
  static const Color neutral = Color(0xFF8A86A0);
  static const Color neutralBg = Color(0xFFF0EFF5);

  // Fond et surfaces
  static const Color background = Color(0xFFF5F4FA);
  static const Color surface = Color(0xFFFFFFFF);

  // Bordures
  static const Color border = Color(0xFFECEAF5);
  static const Color borderStrong = Color(0xFFD8D5E8);

  // Texte
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF55516B);
  static const Color textMuted = Color(0xFF8A86A0);

  // Cartons (distincts des couleurs sémantiques ci-dessus,
  // car un carton jaune n'est ni un succès ni un avertissement produit)
  static const Color cardYellow = Color(0xFFF2C94C);
  static const Color cardRed = Color(0xFFC0392B);
}
