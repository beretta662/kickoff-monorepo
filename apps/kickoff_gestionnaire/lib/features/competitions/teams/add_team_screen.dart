import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../../../shared/widgets/dashed_border_painter.dart';
import '../draft/draft_competition_controller.dart';
import 'team_form_controller.dart';
import 'add_player_screen.dart';

class AddTeamScreen extends StatefulWidget {
  final String competitionId;
  final int effectifMax;
  const AddTeamScreen({super.key, required this.competitionId, required this.effectifMax});

  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  late final TeamFormController _controller;
  final _nomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TeamFormController(competitionId: widget.competitionId, effectifMax: widget.effectifMax);
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle équipe')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    // TODO: sélection du logo — plus tard avec Supabase Storage
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CustomPaint(
                      painter: DashedBorderPainter(color: palette.borderStrong, radius: 32),
                      child: Center(child: Icon(Icons.add_photo_alternate_outlined, color: palette.textMuted, size: 26)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text("Nom de l'équipe", style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 6),
              TextField(
                controller: _nomController,
                onChanged: (v) => _controller.nom.value = v,
                decoration: const InputDecoration(hintText: 'Panthères FC'),
              ),
              const SizedBox(height: 20),

              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Effectif', style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600)),
                      Text('${_controller.joueurs.length} / ${widget.effectifMax} joueurs', style: AppTextStyles.caption(context)),
                    ],
                  )),
              const SizedBox(height: 8),

              Expanded(
                child: Obx(() => ListView.builder(
                      itemCount: _controller.joueurs.length,
                      itemBuilder: (context, index) {
                        final joueur = _controller.joueurs[index];
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
                            onPressed: () => _controller.retirerJoueur(index),
                          ),
                        );
                      },
                    )),
              ),

              InkWell(
                onTap: () => Get.to(() => AddPlayerScreen(controller: _controller)),
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
              const SizedBox(height: 10),

              Text(
                'Les joueurs peuvent être ajoutés plus tard, y compris après le lancement (transferts).',
                style: AppTextStyles.caption(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Obx(() => ElevatedButton(
                    onPressed: _controller.isSaving.value
                        ? null
                        : () async {
                            final equipe = await _controller.enregistrer();
                            if (equipe != null && context.mounted) Get.back(result: equipe);
                          },
                    child: _controller.isSaving.value
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Enregistrer l'équipe"),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}