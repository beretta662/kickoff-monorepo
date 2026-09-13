import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../draft/draft_competition_controller.dart';

class PlayerDraft {
  final String nom;
  final int? numero;
  final String? poste;

  PlayerDraft({required this.nom, this.numero, this.poste});
}

class TeamFormController extends GetxController {
  final String competitionId;
  TeamFormController({required this.competitionId});

  final nom = ''.obs;
  final joueurs = <PlayerDraft>[].obs;
  final isSaving = false.obs;

  /// Retourne un message d'erreur si ce numéro est déjà pris par un
  /// autre joueur de l'équipe en cours de création, null sinon.
  /// Un joueur sans numéro (null) ne provoque jamais de conflit.
  String? verifierNumeroDisponible(int? numero) {
    if (numero == null) return null;
    final dejaPris = joueurs.any((j) => j.numero == numero);
    if (dejaPris) return 'Le numéro $numero est déjà utilisé dans cette équipe.';
    return null;
  }

  void ajouterJoueur(PlayerDraft joueur) => joueurs.add(joueur);
  void retirerJoueur(int index) => joueurs.removeAt(index);

    Future<Equipe?> enregistrer() async {
    if (nom.value.trim().isEmpty) {
      Get.snackbar('Nom requis', "Donnez un nom à l'équipe.", snackPosition: SnackPosition.BOTTOM);
      return null;
    }

    isSaving.value = true;
    try {
      final existantes = await SupabaseService.client
          .from('equipes')
          .select('id')
          .eq('competition_id', competitionId)
          .ilike('nom', nom.value.trim());

      if ((existantes as List).isNotEmpty) {
        Get.snackbar('Nom déjà pris', 'Une équipe "${nom.value.trim()}" existe déjà dans cette compétition.', snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      final equipeResponse = await SupabaseService.client
          .from('equipes')
          .insert({'competition_id': competitionId, 'nom': nom.value.trim()})
          .select()
          .single();
      final equipeId = equipeResponse['id'] as String;

      if (joueurs.isNotEmpty) {
        await SupabaseService.client.from('joueurs').insert(
              joueurs
                  .map((j) => {
                        'equipe_id': equipeId,
                        'nom': j.nom,
                        'numero': j.numero,
                        'poste': j.poste,
                      })
                  .toList(),
            );
      }

      return Equipe.fromMap(equipeResponse);
    } catch (e) {
      Get.snackbar('Erreur', "Impossible d'enregistrer l'équipe.", snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}