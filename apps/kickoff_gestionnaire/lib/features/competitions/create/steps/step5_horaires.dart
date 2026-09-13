import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../create_competition_controller.dart';

class Step5Horaires extends StatefulWidget {
  const Step5Horaires({super.key});

  @override
  State<Step5Horaires> createState() => _Step5HorairesState();
}

class _Step5HorairesState extends State<Step5Horaires> {
  static const _jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  late final TextEditingController _debutController;
  late final TextEditingController _finController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CreateCompetitionController>();
    _debutController = TextEditingController(text: controller.heureDebut.value);
    _finController = TextEditingController(text: controller.heureFin.value);
  }

  @override
  void dispose() {
    _debutController.dispose();
    _finController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCompetitionController>();
    final palette = AppPalette.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horaires et durée des matchs', style: AppTextStyles.h3(context)),
          const SizedBox(height: 16),

          Text('Jours de match', style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: _jours.map((jour) {
                  final selected = controller.joursDeMatch.contains(jour);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () {
                          if (selected) {
                            controller.joursDeMatch.remove(jour);
                          } else {
                            controller.joursDeMatch.add(jour);
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : null,
                            border: selected ? null : Border.all(color: palette.border),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            jour[0],
                            style: AppTextStyles.caption(context).copyWith(
                              color: selected ? Colors.white : palette.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 20),

          Text('Plage horaire', style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _debutController,
                  textAlign: TextAlign.center,
                  onChanged: (v) => controller.heureDebut.value = v,
                  decoration: const InputDecoration(hintText: '14:00'),
                ),
              ),
              const SizedBox(width: 8),
              const Text('à'),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _finController,
                  textAlign: TextAlign.center,
                  onChanged: (v) => controller.heureFin.value = v,
                  decoration: const InputDecoration(hintText: '18:00'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text("Durée d'une période", style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [30, 40, 45].map((minutes) {
                  final selected = controller.dureePeriode.value == minutes;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        onTap: () => controller.dureePeriode.value = minutes,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: selected ? AppColors.accent : palette.border, width: selected ? 2 : 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$minutes min', style: AppTextStyles.caption(context)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _MiniStepper(label: 'Périodes', valueGetter: () => Get.find<CreateCompetitionController>().nombrePeriodes.value, onDecrement: () {
                final c = Get.find<CreateCompetitionController>();
                if (c.nombrePeriodes.value > 1) c.nombrePeriodes.value--;
              }, onIncrement: () => Get.find<CreateCompetitionController>().nombrePeriodes.value++, palette: palette)),
              const SizedBox(width: 8),
              Expanded(child: _MiniStepper(label: 'Pause', suffix: 'min', valueGetter: () => Get.find<CreateCompetitionController>().pause.value, onDecrement: () {
                final c = Get.find<CreateCompetitionController>();
                if (c.pause.value > 0) c.pause.value -= 5;
              }, onIncrement: () => Get.find<CreateCompetitionController>().pause.value += 5, palette: palette)),
              const SizedBox(width: 8),
              Expanded(child: _MiniStepper(label: 'Battement', suffix: 'min', valueGetter: () => Get.find<CreateCompetitionController>().battement.value, onDecrement: () {
                final c = Get.find<CreateCompetitionController>();
                if (c.battement.value > 0) c.battement.value -= 5;
              }, onIncrement: () => Get.find<CreateCompetitionController>().battement.value += 5, palette: palette)),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Durée par match : ${controller.dureeMatchMinutes} min',
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '≈ ${controller.matchsPossibles} matchs possibles entre ${controller.heureDebut.value} et ${controller.heureFin.value}',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Petit bloc "label + valeur + boutons -/+", utilisé 3 fois dans cet
/// écran (périodes, pause, battement). `valueGetter` est relu à chaque
/// frappe via Obx dans le parent qui l'englobe — voir usage ci-dessus.
class _MiniStepper extends StatelessWidget {
  final String label;
  final String? suffix;
  final int Function() valueGetter;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final AppPalette palette;

  const _MiniStepper({
    required this.label,
    required this.valueGetter,
    required this.onDecrement,
    required this.onIncrement,
    required this.palette,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption(context)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: palette.borderStrong), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(onTap: onDecrement, child: Icon(Icons.remove, size: 14, color: palette.textSecondary)),
                  Text(suffix != null ? '${valueGetter()} $suffix' : '${valueGetter()}', style: AppTextStyles.caption(context)),
                  InkWell(onTap: onIncrement, child: Icon(Icons.add, size: 14, color: palette.textSecondary)),
                ],
              ),
            ),
          ],
        ));
  }
}