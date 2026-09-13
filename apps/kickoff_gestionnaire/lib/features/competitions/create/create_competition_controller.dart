import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

enum CompetitionType { championnat, coupe }
enum CompetitionFormat { amateur, pro }
enum QualificationMode { classement, toutes }
enum PhaseFormat { pouleUnique, plusieursPoules, direct }

class CreateCompetitionController extends GetxController {
  final currentStep = 0.obs;
  static const int totalSteps = 6;

  // Étape 1
  final sport = RxnString();

  // Étape 2
  final Rxn<CompetitionType> type = Rxn<CompetitionType>();

  // Étape 3
  final Rxn<CompetitionFormat> format = Rxn<CompetitionFormat>();
  final suspensionApresCartonRouge = false.obs;
  final nombreMatchsSuspension = 1.obs;

  // Étape 4
  final nom = ''.obs;
  final nombreEquipesPrevu = 6.obs;
  final allerRetour = true.obs;

  // Étape 5
  final joursDeMatch = <String>{'Sam', 'Dim'}.obs;
  final heureDebut = '14:00'.obs;
  final heureFin = '18:00'.obs;
  final dureePeriode = 30.obs;
  final nombrePeriodes = 2.obs;
  final pause = 10.obs;
  final battement = 10.obs;

  // Étape 6 — branche championnat
  final alimenteCoupeFuture = false.obs;
  final nombreEquipesEliminees = 2.obs;

  int get nombreEquipesQualifiees =>
      (nombreEquipesPrevu.value - nombreEquipesEliminees.value).clamp(0, nombreEquipesPrevu.value);

  // Étape 6 — branche coupe
  final associerChampionnat = false.obs;
  final championnatReference = RxnString();
  final Rxn<QualificationMode> modeQualification = Rxn<QualificationMode>();
  final phasesDeGroupes = true.obs;
  final Rxn<PhaseFormat> formatPhases = Rxn<PhaseFormat>();

  // Soumission finale
  final isSubmitting = false.obs;
  final submitError = RxnString();

  double get progress => (currentStep.value + 1) / totalSteps;

  int get dureeMatchMinutes => dureePeriode.value * nombrePeriodes.value + pause.value;

  int get matchsPossibles {
    final debut = _parseHeure(heureDebut.value);
    final fin = _parseHeure(heureFin.value);
    if (debut == null || fin == null || fin <= debut) return 0;
    final plageMinutes = fin - debut;
    final creneauMinutes = dureeMatchMinutes + battement.value;
    if (creneauMinutes <= 0) return 0;
    return (plageMinutes / creneauMinutes).floor();
  }

  int? _parseHeure(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  bool get canGoNext {
    switch (currentStep.value) {
      case 0:
        return sport.value != null;
      case 1:
        return type.value != null;
      case 2:
        return format.value != null;
      case 3:
        return nom.value.trim().isNotEmpty;
      case 4:
        return joursDeMatch.isNotEmpty;
      default:
        return true;
    }
  }

  void goNext() {
    if (currentStep.value < totalSteps - 1) currentStep.value++;
  }

  void goBack() {
    if (currentStep.value > 0) currentStep.value--;
  }

  /// Envoie la compétition à Supabase. Retourne l'id créé si succès,
  /// null sinon (voir submitError pour le message à afficher).
    Future<String?> submit() async {
    submitError.value = null;
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      submitError.value = 'Session expirée, reconnecte-toi.';
      return null;
    }

    isSubmitting.value = true;
    try {
      final existants = await SupabaseService.client
          .from('competitions')
          .select('id')
          .eq('gestionnaire_id', userId)
          .ilike('nom', nom.value.trim());

      if ((existants as List).isNotEmpty) {
        submitError.value = 'Vous avez déjà une compétition nommée "${nom.value.trim()}".';
        return null;
      }

      final data = <String, dynamic>{
        'gestionnaire_id': userId,
        'nom': nom.value.trim(),
        'nombre_equipes': nombreEquipesPrevu.value,
        'statut': 'brouillon',
        'sport': sport.value,
        'type': type.value == CompetitionType.championnat ? 'championnat' : 'coupe',
        'format': format.value == CompetitionFormat.pro ? 'pro' : 'amateur',
        'suspension_carton_rouge': suspensionApresCartonRouge.value,
        'nombre_matchs_suspension': nombreMatchsSuspension.value,
        'aller_retour': allerRetour.value,
        'jours_de_match': joursDeMatch.toList(),
        'heure_debut': heureDebut.value,
        'heure_fin': heureFin.value,
        'duree_periode': dureePeriode.value,
        'nombre_periodes': nombrePeriodes.value,
        'pause': pause.value,
        'battement': battement.value,
      };

      if (type.value == CompetitionType.championnat) {
        data['alimente_coupe_future'] = alimenteCoupeFuture.value;
        data['nombre_equipes_eliminees'] = alimenteCoupeFuture.value ? nombreEquipesEliminees.value : 0;
      } else {
        // TODO: une fois la liste des championnats branchée sur Supabase,
        // résoudre championnatReference (nom) vers un vrai id existant
        // plutôt que de laisser championnat_reference_id vide.
        data['mode_qualification'] = associerChampionnat.value
            ? (modeQualification.value == QualificationMode.toutes ? 'toutes' : 'classement')
            : null;
        data['phases_de_groupes'] = associerChampionnat.value ? true : phasesDeGroupes.value;
        data['format_phases'] = formatPhases.value == null
            ? null
            : formatPhases.value == PhaseFormat.pouleUnique
                ? 'poule_unique'
                : formatPhases.value == PhaseFormat.plusieursPoules
                    ? 'plusieurs_poules'
                    : 'direct';
      }

      final response = await SupabaseService.client.from('competitions').insert(data).select().single();
      return response['id'] as String;
    } catch (e) {
      submitError.value = 'Impossible de créer la compétition. Réessaie.';
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}