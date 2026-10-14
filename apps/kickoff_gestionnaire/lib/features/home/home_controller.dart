import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

class CompetitionSummary {
  final String id;
  final String nom;
  final int nombreEquipes;
  final String? journeeActuelle;
  final String statut;

  CompetitionSummary({
    required this.id,
    required this.nom,
    required this.nombreEquipes,
    this.journeeActuelle,
    required this.statut,
  });

  factory CompetitionSummary.fromMap(Map<String, dynamic> map) {
    return CompetitionSummary(
      id: map['id'] as String,
      nom: map['nom'] as String,
      nombreEquipes: map['nombre_equipes'] as int? ?? 0,
      journeeActuelle: map['journee_actuelle'] as String?,
      statut: map['statut'] as String? ?? 'brouillon',
    );
  }
}

class MatchDuJour {
  final String id;
  final String equipeDomicile;
  final String equipeExterieur;
  final String heure;

  MatchDuJour({
    required this.id,
    required this.equipeDomicile,
    required this.equipeExterieur,
    required this.heure,
  });

  factory MatchDuJour.fromMap(Map<String, dynamic> map) {
    final dateHeure = DateTime.parse(map['date_heure'] as String).toLocal();
    final heure = '${dateHeure.hour.toString().padLeft(2, '0')}:${dateHeure.minute.toString().padLeft(2, '0')}';
    return MatchDuJour(
      id: map['id'] as String,
      equipeDomicile: map['equipe_domicile'] as String,
      equipeExterieur: map['equipe_exterieur'] as String,
      heure: heure,
    );
  }
}

class HomeController extends GetxController {
  final competitions = <CompetitionSummary>[].obs;
  final todaysMatches = <MatchDuJour>[].obs;
  final isLoading = true.obs;
  final loadFailed = false.obs;

  bool get hasCompetitions => competitions.isNotEmpty;
  bool get hasMatchesToday => todaysMatches.isNotEmpty;

  int get nombreCompetitionsActives => competitions.where((c) => c.statut == 'active').length;
  int get nombreTotalEquipes => competitions.fold(0, (total, c) => total + c.nombreEquipes);

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    loadFailed.value = false;
    try {
      await withRetry(_fetch);
    } catch (e) {
      loadFailed.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetch() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    // Session pas encore prête : on lève une erreur pour déclencher un
    // nouvel essai, plutôt que d'afficher à tort "aucune compétition".
    if (userId == null) throw Exception('Session indisponible');

    final competitionsResponse = await SupabaseService.client
        .from('competitions')
        .select()
        .eq('gestionnaire_id', userId);

    final liste = (competitionsResponse as List).map((row) => CompetitionSummary.fromMap(row)).toList();

    var matchsDuJour = <MatchDuJour>[];
    if (liste.isNotEmpty) {
      final competitionIds = liste.map((c) => c.id).toList();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final matchesResponse = await SupabaseService.client
          .from('matchs')
          .select()
          .inFilter('competition_id', competitionIds)
          .neq('statut', 'termine')
          .gte('date_heure', startOfDay.toIso8601String())
          .lt('date_heure', endOfDay.toIso8601String());

      matchsDuJour = (matchesResponse as List).map((row) => MatchDuJour.fromMap(row)).toList();
    }

    // On n'écrit dans les listes qu'une fois les deux requêtes réussies,
    // pour ne jamais afficher un état à moitié chargé.
    competitions.value = liste;
    todaysMatches.value = matchsDuJour;
  }
}