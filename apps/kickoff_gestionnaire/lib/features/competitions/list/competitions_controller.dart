import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

class CompetitionListItem {
  final String id;
  final String nom;
  final String sport;
  final String type;
  final String format;
  final String statut;
  final int nombreEquipesPrevu;
  final int nombreEquipesActuel;

  CompetitionListItem({
    required this.id,
    required this.nom,
    required this.sport,
    required this.type,
    required this.format,
    required this.statut,
    required this.nombreEquipesPrevu,
    required this.nombreEquipesActuel,
  });

  factory CompetitionListItem.fromMap(Map<String, dynamic> map) {
    // PostgREST renvoie les agrégats liés sous forme de liste avec un
    // objet {count: N} — ex. [{"count": 3}] — d'où cette extraction.
    final equipesAgg = map['equipes'] as List?;
    final count = (equipesAgg != null && equipesAgg.isNotEmpty) ? equipesAgg.first['count'] as int? ?? 0 : 0;

    return CompetitionListItem(
      id: map['id'] as String,
      nom: map['nom'] as String,
      sport: map['sport'] as String? ?? '',
      type: map['type'] as String? ?? 'championnat',
      format: map['format'] as String? ?? 'amateur',
      statut: map['statut'] as String? ?? 'brouillon',
      nombreEquipesPrevu: map['nombre_equipes'] as int? ?? 0,
      nombreEquipesActuel: count,
    );
  }
}

class CompetitionsController extends GetxController {
  final competitions = <CompetitionListItem>[].obs;
  final isLoading = true.obs;
  final loadFailed = false.obs;
  final expandedId = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCompetitions();
  }

  Future<void> loadCompetitions() async {
    isLoading.value = true;
    loadFailed.value = false;
    try {
      final response = await withRetry(() async {
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId == null) throw Exception('Session indisponible');

        return await SupabaseService.client
            .from('competitions')
            .select('*, equipes(count)')
            .eq('gestionnaire_id', userId)
            .order('created_at', ascending: false);
      });

      competitions.value = (response as List).map((c) => CompetitionListItem.fromMap(c)).toList();
    } catch (e) {
      loadFailed.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleExpanded(String id) {
    expandedId.value = expandedId.value == id ? null : id;
  }
}