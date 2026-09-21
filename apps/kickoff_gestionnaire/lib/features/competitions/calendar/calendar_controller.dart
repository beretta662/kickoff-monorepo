import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

class MatchCalendrier {
  final String id;
  final String equipeDomicile;
  final String equipeExterieur;
  final DateTime dateHeure;
  final String statut;

  MatchCalendrier({
    required this.id,
    required this.equipeDomicile,
    required this.equipeExterieur,
    required this.dateHeure,
    required this.statut,
  });

  factory MatchCalendrier.fromMap(Map<String, dynamic> map) {
    return MatchCalendrier(
      id: map['id'] as String,
      equipeDomicile: map['equipe_domicile'] as String,
      equipeExterieur: map['equipe_exterieur'] as String,
      dateHeure: DateTime.parse(map['date_heure'] as String).toLocal(),
      statut: map['statut'] as String,
    );
  }
}

class CalendarController extends GetxController {
  final String competitionId;
  CalendarController({required this.competitionId});

  final matchs = <MatchCalendrier>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final response = await SupabaseService.client
          .from('matchs')
          .select()
          .eq('competition_id', competitionId)
          .order('date_heure');

      matchs.value = (response as List).map((m) => MatchCalendrier.fromMap(m)).toList();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger le calendrier.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Regroupe les matchs par date (jour), pour l'affichage en sections
  /// comme sur la maquette ("Journée 4 — Sam 27 sept.").
  Map<DateTime, List<MatchCalendrier>> get matchsParJour {
    final groupes = <DateTime, List<MatchCalendrier>>{};
    for (final match in matchs) {
      final jour = DateTime(match.dateHeure.year, match.dateHeure.month, match.dateHeure.day);
      groupes.putIfAbsent(jour, () => []).add(match);
    }
    return groupes;
  }
}