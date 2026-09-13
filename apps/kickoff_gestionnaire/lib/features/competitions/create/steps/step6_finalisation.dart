import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../create_competition_controller.dart';

class Step6Finalisation extends StatelessWidget {
  const Step6Finalisation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCompetitionController>();

    return Obx(() {
      if (controller.type.value == CompetitionType.championnat) {
        return const _FinalisationChampionnat();
      }
      return const _FinalisationCoupe();
    });
  }
}

class _FinalisationChampionnat extends StatelessWidget {
  const _FinalisationChampionnat();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCompetitionController>();
    final palette = AppPalette.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finalisation', style: AppTextStyles.h3(context)),
          const SizedBox(height: 16),

          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.alimenteCoupeFuture.value,
                onChanged: (v) => controller.alimenteCoupeFuture.value = v,
                activeColor: AppColors.primary,
                title: Text('Alimenter une coupe plus tard ?', style: AppTextStyles.body(context)),
                subtitle: Text('Les mieux classés se qualifieront', style: AppTextStyles.caption(context)),
              )),

          Obx(() {
            if (!controller.alimenteCoupeFuture.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Équipes éliminées après le championnat', style: AppTextStyles.bodySecondary(context)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            if (controller.nombreEquipesEliminees.value > 0) controller.nombreEquipesEliminees.value--;
                          },
                          child: Icon(Icons.remove, size: 18, color: palette.textSecondary),
                        ),
                        Text('${controller.nombreEquipesEliminees.value}', style: AppTextStyles.body(context)),
                        InkWell(
                          onTap: () {
                            if (controller.nombreEquipesEliminees.value < controller.nombreEquipesPrevu.value - 1) {
                              controller.nombreEquipesEliminees.value++;
                            }
                          },
                          child: Icon(Icons.add, size: 18, color: palette.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.nombreEquipesQualifiees} équipes se qualifieront '
                    '(estimation, basée sur ${controller.nombreEquipesPrevu.value} équipes prévues)',
                    style: AppTextStyles.caption(context),
                  ),
                ],
              ),
            );
          }),

          _RecapCard(controller: controller, palette: palette),
        ],
      ),
    );
  }
}

class _FinalisationCoupe extends StatelessWidget {
  const _FinalisationCoupe();

  static const _championnatsDisponibles = <String>['Ligue Mfoundi 2026'];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCompetitionController>();
    final palette = AppPalette.of(context);
    final aUnChampionnat = _championnatsDisponibles.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Structure de la coupe', style: AppTextStyles.h3(context)),
          const SizedBox(height: 16),

          if (!aUnChampionnat) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: palette.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Aucun championnat disponible à associer pour l'instant. "
                      "Cette coupe démarrera directement, sans qualification préalable.",
                      style: AppTextStyles.caption(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SansChampionnatSection(controller: controller, palette: palette),
          ] else ...[
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: controller.associerChampionnat.value,
                  onChanged: (v) {
                    controller.associerChampionnat.value = v;
                    if (v && controller.championnatReference.value == null) {
                      controller.championnatReference.value = _championnatsDisponibles.first;
                    }
                  },
                  activeColor: AppColors.primary,
                  title: Text('Associer un championnat', style: AppTextStyles.body(context)),
                  subtitle: Text('Basé sur le classement existant', style: AppTextStyles.caption(context)),
                )),
            const SizedBox(height: 12),

            Obx(() {
              if (!controller.associerChampionnat.value) {
                return _SansChampionnatSection(controller: controller, palette: palette);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Championnat de référence', style: AppTextStyles.bodySecondary(context)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: palette.borderStrong), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: palette.surface,
                        value: controller.championnatReference.value,
                        items: _championnatsDisponibles
                            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: AppTextStyles.body(context))))
                            .toList(),
                        onChanged: (v) => controller.championnatReference.value = v,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Qui participe ?', style: AppTextStyles.bodySecondary(context)),
                  const SizedBox(height: 8),
                  _RadioOption(
                    label: 'Selon le classement (${controller.nombreEquipesQualifiees} équipes)',
                    selected: controller.modeQualification.value == QualificationMode.classement,
                    palette: palette,
                    onTap: () => controller.modeQualification.value = QualificationMode.classement,
                  ),
                  _RadioOption(
                    label: 'Toutes les équipes du championnat',
                    selected: controller.modeQualification.value == QualificationMode.toutes,
                    palette: palette,
                    onTap: () => controller.modeQualification.value = QualificationMode.toutes,
                  ),
                  const SizedBox(height: 12),

                  _FormatPhasesSelector(controller: controller, palette: palette, showDirect: true),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _SansChampionnatSection extends StatelessWidget {
  final CreateCompetitionController controller;
  final AppPalette palette;

  const _SansChampionnatSection({required this.controller, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phases de groupes ?', style: AppTextStyles.bodySecondary(context)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ChoiceChip(
                    label: 'Oui',
                    selected: controller.phasesDeGroupes.value,
                    palette: palette,
                    onTap: () => controller.phasesDeGroupes.value = true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoiceChip(
                    label: 'Non, direct',
                    selected: !controller.phasesDeGroupes.value,
                    palette: palette,
                    onTap: () => controller.phasesDeGroupes.value = false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (controller.phasesDeGroupes.value) _FormatPhasesSelector(controller: controller, palette: palette, showDirect: false),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
              child: Text(
                "Classement de départ initialisé par ordre d'inscription, mis à jour dès le premier match.",
                style: AppTextStyles.caption(context),
              ),
            ),
          ],
        ));
  }
}

class _FormatPhasesSelector extends StatelessWidget {
  final CreateCompetitionController controller;
  final AppPalette palette;
  final bool showDirect;

  const _FormatPhasesSelector({required this.controller, required this.palette, required this.showDirect});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Format des phases', style: AppTextStyles.bodySecondary(context)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ChoiceChip(
                    label: 'Poule unique',
                    selected: controller.formatPhases.value == PhaseFormat.pouleUnique,
                    palette: palette,
                    onTap: () => controller.formatPhases.value = PhaseFormat.pouleUnique,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ChoiceChip(
                    label: 'Plusieurs poules',
                    selected: controller.formatPhases.value == PhaseFormat.plusieursPoules,
                    palette: palette,
                    onTap: () => controller.formatPhases.value = PhaseFormat.plusieursPoules,
                  ),
                ),
                if (showDirect) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: _ChoiceChip(
                      label: 'Direct',
                      selected: controller.formatPhases.value == PhaseFormat.direct,
                      palette: palette,
                      onTap: () => controller.formatPhases.value = PhaseFormat.direct,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ));
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.selected, required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: selected ? AppColors.accent : palette.border, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: AppTextStyles.caption(context), textAlign: TextAlign.center),
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;

  const _RadioOption({required this.label, required this.selected, required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? AppColors.primary : palette.textMuted,
            ),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.body(context)),
          ],
        ),
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  final CreateCompetitionController controller;
  final AppPalette palette;

  const _RecapCard({required this.controller, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.nom.value, style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                '${controller.sport.value} · Championnat · ${controller.format.value == CompetitionFormat.pro ? "Pro" : "Amateur"}\n'
                '~${controller.nombreEquipesPrevu.value} équipes · ${controller.allerRetour.value ? "Aller-retour" : "Match unique"}',
                style: AppTextStyles.caption(context),
              ),
            ],
          ),
        ));
  }
}