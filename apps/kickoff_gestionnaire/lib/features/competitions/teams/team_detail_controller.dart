import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'team_form_controller.dart';

class JoueurExistant {
  final String id;
  final String nom;
  final int? numero;
  final String? poste;

  JoueurExistant({required this.id, required this.nom, this.numero, this.poste});

  factory JoueurExistant.fromMap(Map<String, dynamic> map) {
    return JoueurExistant(
      id: map['id'] as String,
      nom: map['nom'] as String,
      numero: map['numero'] as int?,
      poste: map['poste'] as String?,
    );
  }
}

/// Gère une équipe déjà enregistrée : les joueurs sont lus et écrits
/// directement en base. `onCountChanged` prévient l'écran brouillon à
/// chaque changement, pour que la coche/croix de l'équipe se mette à jour.
class TeamDetailController extends GetxController implements PlayerFormTarget {
  final String equipeId;
  final String equipeNom;
  final int effectifMax;
  final int nombreTitulaires;
  final void Function(int count) onCountChanged;

  TeamDetailController({
    required this.equipeId,
    required this.equipeNom,
    required this.effectifMax,
    required this.nombreTitulaires,
    required this.onCountChanged,
  });

  final nom = ''.obs;
  final joueurs = <JoueurExistant>[].obs;
  final isLoading = true.obs;

  @override
  RxString get nomEquipe => nom;

  @override
  void onInit() {
    super.onInit();
    nom.value = equipeNom;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final response = await SupabaseService.client
          .from('joueurs')
          .select()
          .eq('equipe_id', equipeId)
          .order('created_at');

      joueurs.value = (response as List).map((j) => JoueurExistant.fromMap(j)).toList();
      onCountChanged(joueurs.length);
    } catch (e) {
      Get.snackbar('Erreur', "Impossible de charger l'effectif.", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  String? verifierEffectifDisponible() {
    if (joueurs.length >= effectifMax) {
      return 'Effectif maximum atteint ($effectifMax joueurs).';
    }
    return null;
  }

  @override
  String? verifierNumeroDisponible(int? numero) {
    if (numero == null) return null;
    final dejaPris = joueurs.any((j) => j.numero == numero);
    if (dejaPris) return 'Le numéro $numero est déjà utilisé dans cette équipe.';
    return null;
  }

  @override
  Future<bool> ajouterJoueur(PlayerDraft joueur) async {
    try {
      final response = await SupabaseService.client
          .from('joueurs')
          .insert({
            'equipe_id': equipeId,
            'nom': joueur.nom,
            'numero': joueur.numero,
            'poste': joueur.poste,
          })
          .select()
          .single();

      joueurs.add(JoueurExistant.fromMap(response));
      onCountChanged(joueurs.length);
      return true;
    } catch (e) {
      Get.snackbar('Erreur', "Impossible d'ajouter le joueur.", snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> retirerJoueur(String joueurId) async {
    try {
      final response = await SupabaseService.client
          .from('joueurs')
          .delete()
          .eq('id', joueurId)
          .select();

      if ((response as List).isEmpty) {
        Get.snackbar('Erreur', "Le joueur n'a pas pu être retiré.", snackPosition: SnackPosition.BOTTOM);
        return;
      }

      joueurs.removeWhere((j) => j.id == joueurId);
      onCountChanged(joueurs.length);
    } catch (e) {
      Get.snackbar('Erreur', "Impossible de retirer le joueur.", snackPosition: SnackPosition.BOTTOM);
    }
  }
}