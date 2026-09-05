import 'package:flutter/material.dart';
import 'package:kickoff_core/kickoff_core.dart';

/// Écran temporaire, sans logique métier.
///
/// Son seul but est de vérifier visuellement que le thème (couleurs,
/// typographie, boutons, champs de texte, cartes) est bien appliqué
/// avant de commencer à construire les vrais écrans. Il sera supprimé
/// et remplacé par l'écran de connexion à l'étape suivante.
class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kickoff — aperçu du thème')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kickoff', style: AppTextStyles.h1),
            const SizedBox(height: 4),
            Text(
              'Application Gestionnaire',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text('Lions FC', style: AppTextStyles.body),
                        const SizedBox(height: 6),
                        Text('2', style: AppTextStyles.score.copyWith(color: AppColors.success)),
                      ],
                    ),
                    Text('—', style: AppTextStyles.caption),
                    Column(
                      children: [
                        Text('Aigles Yaoundé', style: AppTextStyles.body),
                        const SizedBox(height: 6),
                        Text('1', style: AppTextStyles.score.copyWith(color: AppColors.danger)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('Boutons', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () {}, child: const Text('Bouton principal')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () {}, child: const Text('Bouton secondaire')),
            const SizedBox(height: 16),

            Text('Champ de texte', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            const TextField(decoration: InputDecoration(hintText: 'Nom de la compétition')),
            const SizedBox(height: 16),

            Text('Badges de statut', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _StatusBadge(label: 'Actif', bg: AppColors.successBg, fg: AppColors.success),
                _StatusBadge(label: 'Brouillon', bg: AppColors.warningBg, fg: AppColors.warning),
                _StatusBadge(label: 'Suspendu', bg: AppColors.dangerBg, fg: AppColors.danger),
                _StatusBadge(label: 'Nul', bg: AppColors.neutralBg, fg: AppColors.neutral),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _StatusBadge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: fg)),
    );
  }
}
