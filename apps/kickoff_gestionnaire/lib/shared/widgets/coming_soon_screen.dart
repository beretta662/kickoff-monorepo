import 'package:flutter/material.dart';
import 'package:kickoff_core/kickoff_core.dart';

/// Écran générique pour toute fonctionnalité pas encore disponible.
/// Utilisé ici pour les sports autres que le football, réutilisable
/// ailleurs (ex. une phase de coupe pas encore codée).
class ComingSoonScreen extends StatelessWidget {
  final String featureName;

  const ComingSoonScreen({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top_outlined, size: 40, color: palette.textMuted),
              const SizedBox(height: 16),
              Text(featureName, style: AppTextStyles.h3(context), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('Bientôt disponible', style: AppTextStyles.bodySecondary(context), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Retour')),
            ],
          ),
        ),
      ),
    );
  }
}