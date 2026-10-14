import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../../shared/widgets/coming_soon_screen.dart';
import 'live_match_controller.dart';

class LiveMatchScreen extends StatelessWidget {
  final String matchId;
  const LiveMatchScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveMatchController(matchId: matchId), tag: matchId);
    final palette = AppPalette.of(context);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final domicileGagne = controller.scoreDomicile.value >= controller.scoreExterieur.value;
        final exterieurGagne = controller.scoreExterieur.value >= controller.scoreDomicile.value;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('En direct', style: AppTextStyles.body(context).copyWith(color: AppColors.success)),
                        const Spacer(),
                        Text("${controller.minutesEcoulees.value}'", style: AppTextStyles.bodySecondary(context)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(controller.equipeDomicile.value, style: AppTextStyles.body(context), textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(
                                '${controller.scoreDomicile.value}',
                                style: AppTextStyles.score(context).copyWith(color: domicileGagne ? AppColors.success : AppColors.danger),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text('—', style: AppTextStyles.bodySecondary(context)),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(controller.equipeExterieur.value, style: AppTextStyles.body(context), textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(
                                '${controller.scoreExterieur.value}',
                                style: AppTextStyles.score(context).copyWith(color: exterieurGagne ? AppColors.success : AppColors.danger),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.4,
                      children: [
                        _ActionButton(
                          icon: Icons.sports_soccer,
                          label: 'But',
                          palette: palette,
                          onTap: () => _choisirEquipePourBut(context, controller),
                        ),
                        _ActionButton(
                          icon: Icons.swap_horiz,
                          label: 'Passe',
                          palette: palette,
                          onTap: () => Get.to(() => const ComingSoonScreen(featureName: 'Passe décisive')),
                        ),
                        _ActionButton(
                          icon: Icons.crop_portrait,
                          label: 'Carton',
                          palette: palette,
                          onTap: () => Get.to(() => const ComingSoonScreen(featureName: 'Cartons')),
                        ),
                        _ActionButton(
                          icon: Icons.watch_later_outlined,
                          label: 'Mi-temps',
                          palette: palette,
                          onTap: () => Get.to(() => const ComingSoonScreen(featureName: 'Mi-temps')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text('Fil du match', style: AppTextStyles.bodySecondary(context)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          controller.scoreDomicile.value == 0 && controller.scoreExterieur.value == 0
                              ? 'Le match vient de commencer.'
                              : 'Détail des événements à venir.',
                          style: AppTextStyles.caption(context),
                        ),
                      ),
                    ),

                    OutlinedButton(
                      onPressed: () => _confirmerFinDeMatch(context, controller),
                      child: Text('Terminer le match', style: AppTextStyles.button.copyWith(color: AppColors.danger)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _choisirEquipePourBut(BuildContext context, LiveMatchController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('But marqué par'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(controller.equipeDomicile.value), onTap: () {
              controller.ajouterButPourDomicile();
              Get.back();
            }),
            ListTile(title: Text(controller.equipeExterieur.value), onTap: () {
              controller.ajouterButPourExterieur();
              Get.back();
            }),
          ],
        ),
      ),
    );
  }

  void _confirmerFinDeMatch(BuildContext context, LiveMatchController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Terminer le match ?'),
        content: const Text('Le score sera figé. Cette action ne peut pas être annulée.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final success = await controller.terminerMatch();
              if (success) {
                Get.back();
                Get.back(result: true);
              }
            },
            child: const Text('Terminer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppPalette palette;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.caption(context)),
          ],
        ),
      ),
    );
  }
}