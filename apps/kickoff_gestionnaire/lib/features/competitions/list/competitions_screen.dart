import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../../../routes.dart';
import '../../../shared/widgets/coming_soon_screen.dart';
import '../draft/draft_competition_screen.dart';
import 'competitions_controller.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompetitionsController());
    final palette = AppPalette.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Compétitions', style: AppTextStyles.h2(context)),
                InkWell(
                  onTap: () async {
                    await Get.toNamed(AppRoutes.createCompetition);
                    controller.loadCompetitions();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.competitions.isEmpty) {
                  return Center(
                    child: Text('Aucune compétition ici pour l\'instant.', style: AppTextStyles.bodySecondary(context)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadCompetitions,
                  child: ListView.separated(
                    itemCount: controller.competitions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final competition = controller.competitions[index];
                      return _CompetitionAccordionItem(competition: competition, controller: controller, palette: palette);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetitionAccordionItem extends StatelessWidget {
  final CompetitionListItem competition;
  final CompetitionsController controller;
  final AppPalette palette;

  const _CompetitionAccordionItem({required this.competition, required this.controller, required this.palette});

  @override
  Widget build(BuildContext context) {
    final estActive = competition.statut == 'active';

    return Container(
      decoration: BoxDecoration(border: Border.all(color: palette.border), borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        final estOuvert = controller.expandedId.value == competition.id;
        return Column(
          children: [
            InkWell(
              onTap: () => controller.toggleExpanded(competition.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(7)),
                      alignment: Alignment.center,
                      child: Text(
                        competition.nom.isNotEmpty ? competition.nom[0].toUpperCase() : '?',
                        style: AppTextStyles.caption(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(competition.nom, style: AppTextStyles.body(context)),
                          Text(
                            estActive
                                ? '${competition.nombreEquipesActuel} équipes'
                                : '${competition.nombreEquipesActuel} sur ${competition.nombreEquipesPrevu} équipes',
                            style: AppTextStyles.caption(context),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: estActive ? AppColors.successBg : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        estActive ? 'Active' : 'Brouillon',
                        style: AppTextStyles.caption(context).copyWith(color: estActive ? AppColors.success : AppColors.warning),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(estOuvert ? Icons.expand_less : Icons.expand_more, size: 18, color: palette.textMuted),
                  ],
                ),
              ),
            ),
            if (estOuvert)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: estActive ? _buildActionsActive(context) : _buildActionsBrouillon(context),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildActionsActive(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 0.9,
      children: [
        _QuickAction(icon: Icons.list_alt_outlined, label: 'Classement', palette: palette, onTap: () {
          Get.to(() => const ComingSoonScreen(featureName: 'Classement'));
        }),
        _QuickAction(icon: Icons.swap_horiz, label: 'Transferts', palette: palette, onTap: () {
          Get.to(() => const ComingSoonScreen(featureName: 'Transferts'));
        }),
        _QuickAction(icon: Icons.calendar_month_outlined, label: 'Calendrier', palette: palette, onTap: () {
          Get.toNamed('${AppRoutes.calendar}?id=${competition.id}');
        }),
        _QuickAction(icon: Icons.groups_outlined, label: 'Équipes', palette: palette, onTap: () {
          Get.to(() => const ComingSoonScreen(featureName: 'Gestion des équipes'));
        }),
      ],
    );
  }

  Widget _buildActionsBrouillon(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: competition.nombreEquipesPrevu == 0
                ? 0
                : (competition.nombreEquipesActuel / competition.nombreEquipesPrevu).clamp(0, 1),
            minHeight: 4,
            backgroundColor: palette.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            await Get.to(() => DraftCompetitionScreen(competitionId: competition.id));
            controller.loadCompetitions();
          },
          child: const Text('Gérer les équipes et lancer'),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppPalette palette;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption(context), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}