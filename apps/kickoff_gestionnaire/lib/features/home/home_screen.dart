import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      body: Obx(() {
        if (!controller.hasCompetitions) {
          return const _EmptyState();
        }
        if (!controller.hasMatchesToday) {
          return _NoMatchTodayState(controller: controller);
        }
        return _MatchesTodayState(controller: controller);
      }),
    );
  }
}

/// État 1 : aucune compétition créée pour l'instant.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
              child: Icon(Icons.emoji_events_outlined, color: AppColors.textMuted, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Aucune compétition pour l\'instant', style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Créez votre première compétition pour commencer.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: navigation vers la création de compétition
              },
              child: const Text('Créer une compétition'),
            ),
          ],
        ),
      ),
    );
  }
}

/// État 2 : au moins une compétition, mais aucun match programmé aujourd'hui.
class _NoMatchTodayState extends StatelessWidget {
  final HomeController controller;
  const _NoMatchTodayState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Aujourd\'hui', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderStrong, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy_outlined, color: AppColors.textMuted),
                const SizedBox(height: 8),
                Text('Aucun match aujourd\'hui', style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text('Prochain match : samedi 14:00', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Mes compétitions', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 8),
          ...controller.competitions.map((c) => Card(
                child: ListTile(
                  title: Text(c.nom, style: AppTextStyles.body),
                  subtitle: Text('${c.nombreEquipes} équipes · ${c.journeeActuelle ?? ""}', style: AppTextStyles.caption),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  onTap: () {
                    // TODO: navigation vers la compétition (onglet Compétitions)
                  },
                ),
              )),
        ],
      ),
    );
  }
}

/// État 3 : des matchs sont programmés aujourd'hui.
class _MatchesTodayState extends StatelessWidget {
  final HomeController controller;
  const _MatchesTodayState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Matchs du jour', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 8),
          ...controller.todaysMatches.map((m) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m.heure, style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${m.equipeDomicile} — ${m.equipeExterieur}', style: AppTextStyles.body),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: navigation vers l'écran de match en direct
                        },
                        child: const Text('Démarrer le match'),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}