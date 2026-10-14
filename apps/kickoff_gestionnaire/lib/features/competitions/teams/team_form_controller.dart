import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../draft/draft_competition_controller.dart';

class PlayerDraft {
  final String nom;
  final int? numero;
  final String? poste;

  PlayerDraft({required this.nom, this.numero, this.poste});
}

/// Contrat commun aux deux situations où on ajoute un joueur :
/// - équipe en cours de création (joueurs gardés en mémoire jusqu'à l'enregistrement)
/// - équipe déjà enregistrée (joueur inséré directement en base)
/// AddPlayerScreen ne connaît que ce contrat, pas le détail de chaque cas.
abstract class PlayerFormTarget {
  RxString get nomEquipe;
  String? verifierEffectifDisponible();
  String? verifierNumeroDisponible(int? numero);
  Future<bool> ajouterJoueur(PlayerDraft joueur);
}

class TeamFormController extends GetxController implements PlayerFormTarget {
  final String competitionId;
  final int effectifMax;
  TeamFormController({required this.competitionId, required this.effectifMax});

  final nom = ''.obs;
  final joueurs = <PlayerDraft>[].obs;
  final isSaving = false.obs;

  @override
  RxString get nomEquipe => nom;

  @override
  String? verifierNumeroDisponible(int? numero) {
    if (numero == null) return null;
    final dejaPris = joueurs.any((j) => j.numero == numero);
    if (dejaPris) return 'Le numéro $numero est déjà utilisé dans cette équipe.';
    return null;
  }

  @override
  String? verifierEffectifDisponible() {
    if (joueurs.length >= effectifMax) {
      return 'Effectif maximum atteint ($effectifMax joueurs).';
    }
    return null;
  }

  @override
  Future<bool> ajouterJoueur(PlayerDraft joueur) async {
    joueurs.add(joueur);
    return true;
  }

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

      return Equipe(id: equipeId, nom: nom.value.trim(), joueursCount: joueurs.length);
    } catch (e) {
      Get.snackbar('Erreur', "Impossible d'enregistrer l'équipe.", snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}