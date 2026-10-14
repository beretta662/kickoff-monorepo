import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../../../shared/widgets/dashed_border_painter.dart';
import 'team_form_controller.dart';

class AddPlayerScreen extends StatefulWidget {
  final PlayerFormTarget controller;
  const AddPlayerScreen({super.key, required this.controller});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _nomController = TextEditingController();
  final _numeroController = TextEditingController();
  String? _poste;

  static const _postes = ['Gardien', 'Défenseur', 'Milieu', 'Attaquant'];

  @override
  void dispose() {
    _nomController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  /// Tente d'ajouter le joueur. Retourne true si ça a marché, false si
  /// le formulaire est invalide, l'effectif complet ou le numéro déjà
  /// pris (le message est alors déjà affiché).
  Future<bool> _ajouter() async {
    if (_nomController.text.trim().isEmpty) return false;

    final erreurEffectif = widget.controller.verifierEffectifDisponible();
    if (erreurEffectif != null) {
      Get.snackbar('Effectif complet', erreurEffectif, snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final numero = int.tryParse(_numeroController.text);
    final erreurNumero = widget.controller.verifierNumeroDisponible(numero);
    if (erreurNumero != null) {
      Get.snackbar('Numéro déjà pris', erreurNumero, snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return widget.controller.ajouterJoueur(
      PlayerDraft(nom: _nomController.text.trim(), numero: numero, poste: _poste),
    );
  }

  void _reinitialiser() {
    _nomController.clear();
    _numeroController.clear();
    setState(() => _poste = null);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un joueur')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() => Text(widget.controller.nomEquipe.value, style: AppTextStyles.caption(context))),
              const SizedBox(height: 16),

              Center(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CustomPaint(
                    painter: DashedBorderPainter(color: palette.borderStrong, radius: 28),
                    child: Center(child: Icon(Icons.camera_alt_outlined, color: palette.textMuted, size: 22)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(child: Text('Photo facultative', style: AppTextStyles.caption(context))),
              const SizedBox(height: 20),

              Text('Nom du joueur', style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 6),
              TextField(controller: _nomController, decoration: const InputDecoration(hintText: 'Owona Paul')),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Numéro', style: AppTextStyles.bodySecondary(context)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _numeroController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '7'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Poste', style: AppTextStyles.bodySecondary(context)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(border: Border.all(color: palette.borderStrong), borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              dropdownColor: palette.surface,
                              hint: Text('Choisir', style: AppTextStyles.caption(context)),
                              value: _poste,
                              items: _postes.map((p) => DropdownMenuItem(value: p, child: Text(p, style: AppTextStyles.body(context)))).toList(),
                              onChanged: (v) => setState(() => _poste = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Un joueur ajouté plus tard peut être rattaché à un carton ou un but déjà saisi.',
                style: AppTextStyles.caption(context),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () async {
                  final ajoute = await _ajouter();
                  if (ajoute && mounted) _reinitialiser();
                },
                child: const Text('Ajouter et continuer'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  if (_nomController.text.trim().isEmpty) {
                    Get.back();
                    return;
                  }
                  final ajoute = await _ajouter();
                  if (ajoute) Get.back();
                },
                child: const Text("Terminer l'ajout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}