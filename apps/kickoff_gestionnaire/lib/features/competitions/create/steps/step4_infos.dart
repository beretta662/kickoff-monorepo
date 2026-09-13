import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../create_competition_controller.dart';
import '../../../../shared/widgets/dashed_border_painter.dart';

class Step4Infos extends StatefulWidget {
  const Step4Infos({super.key});

  @override
  State<Step4Infos> createState() => _Step4InfosState();
}

class _Step4InfosState extends State<Step4Infos> {
  late final TextEditingController _nomController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CreateCompetitionController>();
    _nomController = TextEditingController(text: controller.nom.value);
  }

  @override
  void dispose() {
    _nomController.dispose();
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
          Text('Informations générales', style: AppTextStyles.h3(context)),
          const SizedBox(height: 16),

          Center(
            child: InkWell(
              onTap: () {
                // TODO: sélection d'image — plus tard avec Supabase Storage
              },
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: CustomPaint(
                  painter: DashedBorderPainter(color: palette.borderStrong, radius: 12),
                  child: Center(
                    child: Icon(Icons.add_photo_alternate_outlined, color: palette.textMuted, size: 26),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('Nom de la compétition', style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: 6),
          TextField(
            controller: _nomController,
            onChanged: (v) => controller.nom.value = v,
            decoration: const InputDecoration(hintText: 'Ligue Mfoundi 2026'),
          ),
          const SizedBox(height: 20),

          Text("Nombre d'équipes prévu", style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: 6),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StepperButton(
                      icon: Icons.remove,
                      palette: palette,
                      onTap: () {
                        if (controller.nombreEquipesPrevu.value > 2) controller.nombreEquipesPrevu.value--;
                      },
                    ),
                    Text('${controller.nombreEquipesPrevu.value}', style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600)),
                    _StepperButton(
                      icon: Icons.add,
                      palette: palette,
                      onTap: () => controller.nombreEquipesPrevu.value++,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          Text('Une estimation, modifiable jusqu\'au lancement.', style: AppTextStyles.caption(context)),
          const SizedBox(height: 16),

          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.allerRetour.value,
                onChanged: (v) => controller.allerRetour.value = v,
                activeColor: AppColors.primary,
                title: Text('Aller-retour', style: AppTextStyles.body(context)),
                subtitle: Text('Chaque équipe joue deux fois', style: AppTextStyles.caption(context)),
              )),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final AppPalette palette;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(border: Border.all(color: palette.borderStrong), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: palette.textSecondary),
      ),
    );
  }
}