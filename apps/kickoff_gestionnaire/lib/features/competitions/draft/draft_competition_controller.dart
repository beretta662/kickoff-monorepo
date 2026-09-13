import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

class Equipe {
  final String id;
  final String nom;

  Equipe({required this.id, required this.nom});

  factory Equipe.fromMap(Map<String, dynamic> map) {
    return Equipe(id: map['id'] as String, nom: map['nom'] as String);
  }
}

class DraftCompetitionController extends GetxController {
  final String competitionId;
  DraftCompetitionController({required this.competitionId});

  final nom = ''.obs;
  final sport = ''.obs;
  final type = ''.obs;
  final format = ''.obs;
  final statut = 'brouillon'.obs;
  final nombreEquipesPrevu = 0.obs;
  final equipes = <Equipe>[].obs;
  final isLoading = true.obs;

  /// "Football · Championnat · Amateur" — reconstruit à partir des
  /// valeurs stockées en base (en minuscules côté données).
  String get sousTitre {
    final typeLabel = type.value == 'championnat' ? 'Championnat' : 'Coupe';
    final formatLabel = format.value == 'pro' ? 'Pro' : 'Amateur';
    return '${sport.value} · $typeLabel · $formatLabel';
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final competitionResponse = await SupabaseService.client
          .from('competitions')
          .select()
          .eq('id', competitionId)
          .single();

      nom.value = competitionResponse['nom'] as String;
      sport.value = competitionResponse['sport'] as String? ?? '';
      type.value = competitionResponse['type'] as String? ?? 'championnat';
      format.value = competitionResponse['format'] as String? ?? 'amateur';
      statut.value = competitionResponse['statut'] as String? ?? 'brouillon';
      nombreEquipesPrevu.value = competitionResponse['nombre_equipes'] as int? ?? 0;

      final equipesResponse = await SupabaseService.client
          .from('equipes')
          .select()
          .eq('competition_id', competitionId)
          .order('created_at');

      equipes.value = (equipesResponse as List).map((e) => Equipe.fromMap(e)).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger la compétition.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changerNombreEquipesPrevu(int nouveauNombre) async {
    nombreEquipesPrevu.value = nouveauNombre;
    await SupabaseService.client
        .from('competitions')
        .update({'nombre_equipes': nouveauNombre})
        .eq('id', competitionId);
  }

  Future<bool> lancerCompetition() async {
    if (equipes.length < 2) {
      Get.snackbar('Impossible de lancer', 'Il faut au moins 2 équipes.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    try {
      await SupabaseService.client
          .from('competitions')
          .update({'statut': 'active'})
          .eq('id', competitionId);
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de lancer la compétition.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}