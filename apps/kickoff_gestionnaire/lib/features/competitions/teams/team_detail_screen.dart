import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../../../shared/widgets/dashed_border_painter.dart';
import 'add_player_screen.dart';
import 'team_detail_controller.dart';

class TeamDetailScreen extends StatelessWidget {
  final String equipeId;
  final String equipeNom;
  final int effectifMax;
  final int nombreTitulaires;
  final void Function(int count) onCountChanged;

  const TeamDetailScreen({
    super.key,
    required this.equipeId,
    required this.equipeNom,
    required this.effectifMax,
    required this.nombreTitulaires,
    required this.onCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      TeamDetailController(
        equipeId: equipeId,
        equipeNom: equipeNom,
        effectifMax: effectifMax,
        nombreTitulaires: nombreTitulaires,
        onCountChanged: onCountChanged,
      ),
      tag: equipeId,
    );
    final palette = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(equipeNom)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final complete = controller.joueurs.length >= nombreTitulaires;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Effectif', style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600)),
                    Text('${controller.joueurs.length} / $effectifMax joueurs', style: AppTextStyles.caption(context)),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(
                        complete ? Icons.check_circle_outline : Icons.cancel_outlined,
                        size: 22,
                        color: complete ? AppColors.success : AppColors.danger,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          complete
                              ? 'Effectif suffisant pour le lancement ($nombreTitulaires titulaires minimum).'
                              : 'Il manque ${nombreTitulaires - controller.joueurs.length} joueur(s) pour atteindre les $nombreTitulaires titulaires requis.',
                          style: AppTextStyles.caption(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: controller.joueurs.isEmpty
                      ? Center(child: Text('Aucun joueur pour l\'instant.', style: AppTextStyles.caption(context)))
                      : ListView.builder(
                          itemCount: controller.joueurs.length,
                          itemBuilder: (context, index) {
                            final joueur = controller.joueurs[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: palette.background,
                                child: Text(joueur.numero?.toString() ?? '?', style: AppTextStyles.caption(context)),
                              ),
                              title: Text(joueur.nom, style: AppTextStyles.body(context)),
                              subtitle: joueur.poste != null ? Text(joueur.poste!, style: AppTextStyles.caption(context)) : null,
                              trailing: IconButton(
                                icon: Icon(Icons.close, size: 20, color: palette.textMuted),
                                onPressed: () => _confirmerRetrait(context, controller, joueur),
                              ),
                            );
                          },
                        ),
                ),

                InkWell(
                  onTap: () => Get.to(() => AddPlayerScreen(controller: controller)),
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
                          Text('Ajouter un joueur', style: AppTextStyles.caption(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _confirmerRetrait(BuildContext context, TeamDetailController controller, JoueurExistant joueur) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Retirer ce joueur ?'),
        content: Text('${joueur.nom} sera retiré de l\'effectif.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              controller.retirerJoueur(joueur.id);
              Get.back();
            },
            child: const Text('Retirer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}