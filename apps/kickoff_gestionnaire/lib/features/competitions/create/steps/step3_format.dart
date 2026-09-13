import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../create_competition_controller.dart';

class Step3Format extends StatelessWidget {
  const Step3Format({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCompetitionController>();
    final palette = AppPalette.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Format de la compétition', style: AppTextStyles.h3(context)),
          const SizedBox(height: 14),

          Obx(() => _FormatCard(
                title: 'Amateur',
                description: 'Remplacements libres. Pas de feuille de composition.',
                badge: 'Recommandé',
                selected: controller.format.value == CompetitionFormat.amateur,
                palette: palette,
                onTap: () => controller.format.value = CompetitionFormat.amateur,
              )),
          const SizedBox(height: 10),
          Obx(() => _FormatCard(
                title: 'Pro',
                description: 'Remplacements limités. Un joueur sorti ne rentre plus.',
                selected: controller.format.value == CompetitionFormat.pro,
                palette: palette,
                onTap: () => controller.format.value = CompetitionFormat.pro,
              )),

          const SizedBox(height: 24),
          Text('Après un carton rouge', style: AppTextStyles.bodySecondary(context)),
          const SizedBox(height: 8),

          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.suspensionApresCartonRouge.value,
                onChanged: (v) => controller.suspensionApresCartonRouge.value = v,
                activeColor: AppColors.primary,
                title: Text('Suspension au(x) match(s) suivant(s)', style: AppTextStyles.body(context)),
                subtitle: Text('Le joueur ne pourra pas jouer', style: AppTextStyles.caption(context)),
              )),

          Obx(() {
            if (!controller.suspensionApresCartonRouge.value) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Row(
                children: [
                  Expanded(child: Text('Nombre de matchs suspendus', style: AppTextStyles.caption(context))),
                  _Stepper(
                    value: controller.nombreMatchsSuspension.value,
                    palette: palette,
                    onDecrement: () {
                      if (controller.nombreMatchsSuspension.value > 1) controller.nombreMatchsSuspension.value--;
                    },
                    onIncrement: () => controller.nombreMatchsSuspension.value++,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
            child: Text(
              "Si désactivé, le carton rouge exclut le joueur uniquement du match en cours, sans suspension pour la suite.",
              style: AppTextStyles.caption(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  final String title;
  final String description;
  final String? badge;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;

  const _FormatCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.palette,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.accent : palette.border, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600)),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(badge!, style: AppTextStyles.caption(context).copyWith(color: AppColors.primary)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(description, style: AppTextStyles.caption(context)),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final AppPalette palette;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _Stepper({required this.value, required this.palette, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepperButton(icon: Icons.remove, palette: palette, onTap: onDecrement),
        SizedBox(width: 28, child: Text('$value', textAlign: TextAlign.center, style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600))),
        _StepperButton(icon: Icons.add, palette: palette, onTap: onIncrement),
      ],
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