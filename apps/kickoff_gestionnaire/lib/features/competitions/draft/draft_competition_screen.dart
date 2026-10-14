import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../../../routes.dart';
import '../../../shared/widgets/dashed_border_painter.dart';
import '../teams/add_team_screen.dart';
import '../teams/team_detail_screen.dart';
import 'draft_competition_controller.dart';
import 'launch_competition_screen.dart';

class DraftCompetitionScreen extends StatelessWidget {
  final String competitionId;
  const DraftCompetitionScreen({super.key, required this.competitionId});

  String _initiales(String nom) {
    final mots = nom.trim().split(RegExp(r'\s+'));
    if (mots.isEmpty || mots.first.isEmpty) return '?';
    final premiere = mots[0][0];
    final seconde = mots.length > 1 && mots[1].isNotEmpty ? mots[1][0] : '';
    return (premiere + seconde).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DraftCompetitionController(competitionId: competitionId), tag: competitionId);
    final palette = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(controller.nom.value, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                if (controller.statut.value == 'brouillon')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(6)),
                    child: Text('Brouillon', style: AppTextStyles.caption(context).copyWith(color: AppColors.warning)),
                  ),
              ],
            )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.statut.value == 'active') {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Cette compétition est déjà lancée.', style: AppTextStyles.body(context)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.offNamed('${AppRoutes.calendar}?id=$competitionId'),
                    child: const Text('Voir le calendrier'),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(controller.sousTitre, style: AppTextStyles.bodySecondary(context)),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: palette.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Ajoutez vos équipes au fur et à mesure. Rien n'est figé tant que la compétition n'est pas lancée.",
                          style: AppTextStyles.caption(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Équipes ajoutées', style: AppTextStyles.bodySecondary(context)),
                    Text('${controller.equipes.length} sur ${controller.nombreEquipesPrevu.value} prévues', style: AppTextStyles.caption(context)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: controller.nombreEquipesPrevu.value == 0
                        ? 0
                        : (controller.equipes.length / controller.nombreEquipesPrevu.value).clamp(0, 1),
                    minHeight: 4,
                    backgroundColor: palette.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: controller.equipes.length,
                    itemBuilder: (context, index) {
                      final equipe = controller.equipes[index];
                      final complete = equipe.joueursCount >= controller.nombreTitulaires.value;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => Get.to(() => TeamDetailScreen(
                              equipeId: equipe.id,
                              equipeNom: equipe.nom,
                              effectifMax: controller.effectifMax.value,
                              nombreTitulaires: controller.nombreTitulaires.value,
                              onCountChanged: (count) {
                                final i = controller.equipes.indexWhere((e) => e.id == equipe.id);
                                if (i >= 0) {
                                  controller.equipes[i] = Equipe(id: equipe.id, nom: equipe.nom, joueursCount: count);
                                }
                              },
                            )),
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            _initiales(equipe.nom),
                            style: AppTextStyles.caption(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                        title: Text(equipe.nom, style: AppTextStyles.body(context)),
                        subtitle: Text(
                          '${equipe.joueursCount} / ${controller.nombreTitulaires.value} titulaires',
                          style: AppTextStyles.caption(context),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              complete ? Icons.check : Icons.close,
                              color: complete ? AppColors.success : AppColors.danger,
                              size: 20,
                            ),
                            if (!complete)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                onPressed: () => _confirmerSuppression(context, controller, equipe),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                InkWell(
                  onTap: () async {
                    final equipe = await Get.to<Equipe>(() => AddTeamScreen(
                          competitionId: competitionId,
                          effectifMax: controller.effectifMax.value,
                        ));
                    if (equipe != null) controller.equipes.add(equipe);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: DashedBorderPainter(color: palette.borderStrong, radius: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 20, color: palette.textSecondary),
                          const SizedBox(width: 6),
                          Text('Ajouter une équipe', style: AppTextStyles.caption(context)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                InkWell(
                  onTap: () => _showModifierNombreDialog(context, controller),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "Modifier le nombre d'équipes prévu",
                        style: AppTextStyles.caption(context).copyWith(color: AppColors.accent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () => Get.to(() => LaunchCompetitionScreen(controller: controller)),
                  icon: const Icon(Icons.flag_outlined, size: 20),
                  label: const Text('Lancer la compétition'),
                ),
                const SizedBox(height: 6),
                Text(
                  'Le calendrier sera généré et les équipes ne pourront plus être ajoutées ou retirées après le lancement.',
                  style: AppTextStyles.caption(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _confirmerSuppression(BuildContext context, DraftCompetitionController controller, Equipe equipe) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retirer cette équipe ?'),
        content: Text('${equipe.nom} et ses joueurs seront définitivement supprimés.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              controller.supprimerEquipe(equipe.id);
              Get.back();
            },
            child: const Text('Retirer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showModifierNombreDialog(BuildContext context, DraftCompetitionController controller) {
    final textController = TextEditingController(text: '${controller.nombreEquipesPrevu.value}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nombre d'équipes prévu"),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Ex. 8'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              final valeur = int.tryParse(textController.text);
              if (valeur != null && valeur > 0) controller.changerNombreEquipesPrevu(valeur);
              Get.back();
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}