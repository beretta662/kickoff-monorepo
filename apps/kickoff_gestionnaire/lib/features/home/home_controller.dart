import 'package:get/get.dart';

/// Modèle minimal, juste pour faire fonctionner l'écran d'accueil.
/// Sera remplacé par un vrai modèle partagé (dans kickoff_core) une
/// fois qu'on branchera Supabase.
class CompetitionSummary {
  final String nom;
  final int nombreEquipes;
  final String? journeeActuelle;

  CompetitionSummary({
    required this.nom,
    required this.nombreEquipes,
    this.journeeActuelle,
  });
}

class MatchDuJour {
  final String equipeDomicile;
  final String equipeExterieur;
  final String heure;

  MatchDuJour({
    required this.equipeDomicile,
    required this.equipeExterieur,
    required this.heure,
  });
}

class HomeController extends GetxController {
  // Données factices pour l'instant. Pour tester les 3 états de l'écran :
  // - Liste vide (competitions.value = []) → écran "aucune compétition"
  // - Compétitions présentes mais todaysMatches vide → "aucun match aujourd'hui"
  // - Les deux remplis → matchs du jour affichés
  final competitions = <CompetitionSummary>[
    CompetitionSummary(nom: 'Ligue Mfoundi 2026', nombreEquipes: 6, journeeActuelle: 'Journée 4 sur 10'),
  ].obs;

  final todaysMatches = <MatchDuJour>[
    MatchDuJour(equipeDomicile: 'Lions FC', equipeExterieur: 'Aigles Yaoundé', heure: '16:00'),
  ].obs;

  bool get hasCompetitions => competitions.isNotEmpty;
  bool get hasMatchesToday => todaysMatches.isNotEmpty;
}