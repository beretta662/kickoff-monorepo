import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../create_competition_controller.dart';

class Step1Sport extends StatelessWidget {
  const Step1Sport({super.key});

  static const _sports = [
    {'label': 'Football', 'icon': Icons.sports_soccer},
    {'label': 'Basketball', 'icon': Icons.sports_basketball},
    {'label': 'Handball', 'icon': Icons.sports_handball},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateCompetitionController>();
    final palette = AppPalette.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choisissez le sport', style: AppTextStyles.h3(context)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.3,
            children: [
              ..._sports.map((s) => Obx(() {
                    final selected = controller.sport.value == s['label'];
                    return _SportCard(
                      label: s['label'] as String,
                      icon: s['icon'] as IconData,
                      selected: selected,
                      palette: palette,
                      onTap: () => controller.sport.value = s['label'] as String,
                    );
                  })),
              Obx(() {
                final isAutre = controller.sport.value != null &&
                    !_sports.any((s) => s['label'] == controller.sport.value);
                return _SportCard(
                  label: isAutre ? controller.sport.value! : 'Autre',
                  icon: Icons.add,
                  selected: isAutre,
                  palette: palette,
                  dashed: true,
                  onTap: () => _showCustomSportDialog(context, controller),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  void _showCustomSportDialog(BuildContext context, CreateCompetitionController controller) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Autre sport'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Ex. Volleyball'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.sport.value = textController.text.trim();
              }
              Get.back();
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool dashed;
  final AppPalette palette;
  final VoidCallback onTap;

  const _SportCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.palette,
    required this.onTap,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.accent : palette.border;
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: selected ? AppColors.primary : palette.textSecondary, size: 30),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: dashed
          ? CustomPaint(
              painter: _DashedBorderPainter(color: borderColor),
              child: Container(alignment: Alignment.center, child: content),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: selected ? 2 : 1),
              ),
              child: content,
            ),
    );
  }
}

/// Dessine une bordure en pointillés autour d'un rectangle arrondi.
/// Pas de package externe pour ça — juste un tracé de trait découpé
/// en petits segments (5px de trait, 4px de vide).
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}