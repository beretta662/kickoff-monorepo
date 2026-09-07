import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../create_competition_controller.dart';

class Step2Type extends StatelessWidget {
  const Step2Type({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCompetitionController>();
    final palette = AppPalette.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type de compétition', style: AppTextStyles.h3(context)),
          const SizedBox(height: 14),
          Obx(() => _TypeCard(
                icon: Icons.table_chart_outlined,
                title: 'Championnat',
                description: "Toutes les équipes s'affrontent, classement général sur la saison.",
                selected: controller.type.value == CompetitionType.championnat,
                palette: palette,
                onTap: () => controller.type.value = CompetitionType.championnat,
              )),
          const SizedBox(height: 10),
          Obx(() => _TypeCard(
                icon: Icons.emoji_events_outlined,
                title: 'Coupe',
                description: 'Phases de groupes et/ou élimination directe.',
                selected: controller.type.value == CompetitionType.coupe,
                palette: palette,
                onTap: () => controller.type.value = CompetitionType.coupe,
              )),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.palette,
    required this.onTap,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: selected ? AppColors.primary : palette.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.caption(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}