/// Point d'entrée public du package partagé `kickoff_core`.
///
/// Les deux apps (Gestionnaire et Fans) importent ce fichier plutôt que
/// les fichiers internes un par un :
///
/// ```dart
/// import 'package:kickoff_core/kickoff_core.dart';
/// ```
///
/// Ça garde la liberté de réorganiser les fichiers à l'intérieur de
/// `kickoff_core` plus tard sans casser les imports dans les deux apps.
library kickoff_core;

export 'theme/app_colors.dart';
export 'theme/app_text_styles.dart';
export 'theme/app_theme.dart';
