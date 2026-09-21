import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'calendar_controller.dart';

class CalendarScreen extends StatelessWidget {
  final String competitionId;
  const CalendarScreen({super.key, required this.competitionId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController(competitionId: competitionId), tag: competitionId);
    final palette = AppPalette.of(context);
    final formatteurJour = DateFormat('EEEE d MMM', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.matchs.isEmpty) {
          return Center(
            child: Text('Aucun match programmé.', style: AppTextStyles.bodySecondary(context)),
          );
        }

        final groupes = controller.matchsParJour;
        final jours = groupes.keys.toList()..sort();

        return SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jours.length,
            itemBuilder: (context, index) {
              final jour = jours[index];
              final matchsDuJour = groupes[jour]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_capitalize(formatteurJour.format(jour)), style: AppTextStyles.bodySecondary(context)),
                    const SizedBox(height: 6),
                    ...matchsDuJour.map((match) => _MatchRow(match: match, palette: palette)),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _MatchRow extends StatelessWidget {
  final MatchCalendrier match;
  final AppPalette palette;

  const _MatchRow({required this.match, required this.palette});

  @override
  Widget build(BuildContext context) {
    final heure = DateFormat('HH:mm').format(match.dateHeure);
    final estTermine = match.statut == 'termine';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: estTermine ? palette.background : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text('${match.equipeDomicile} — ${match.equipeExterieur}', style: AppTextStyles.body(context)),
          ),
          if (estTermine)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(6)),
              child: Text('Terminé', style: AppTextStyles.caption(context).copyWith(color: AppColors.success)),
            )
          else
            Row(
              children: [
                Text(heure, style: AppTextStyles.caption(context)),
                const SizedBox(width: 6),
                Icon(Icons.edit_outlined, size: 14, color: palette.textMuted),
                // TODO: navigation vers l'écran de report de match — pas encore construit
              ],
            ),
        ],
      ),
    );
  }
}