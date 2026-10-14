import 'package:flutter/material.dart';
import 'package:kickoff_core/kickoff_core.dart';

/// Écran affiché quand un chargement échoue, avec un bouton pour
/// réessayer. À utiliser à la place d'un état "vide", qui laisserait
/// croire qu'il n'y a simplement aucune donnée.
class LoadErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const LoadErrorView({
    super.key,
    required this.onRetry,
    this.message = 'Impossible de charger les données.',
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: palette.textMuted),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.body(context), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Vérifiez votre connexion puis réessayez.', style: AppTextStyles.caption(context), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}