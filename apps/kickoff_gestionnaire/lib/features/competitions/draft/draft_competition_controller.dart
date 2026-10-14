import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

class Equipe {
  final String id;
  final String nom;
  final int joueursCount;

  Equipe({required this.id, required this.nom, this.joueursCount = 0});

  factory Equipe.fromMap(Map<String, dynamic> map) {
    final joueursAgg = map['joueurs'] as List?;
    final count = (joueursAgg != null && joueursAgg.isNotEmpty) ? joueursAgg.first['count'] as int? ?? 0 : 0;
    return Equipe(id: map['id'] as String, nom: map['nom'] as String, joueursCount: count);
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
  final nombreTitulaires = 11.obs;
  final effectifMax = 18.obs;
  final equipes = <Equipe>[].obs;
  final isLoading = true.obs;

  bool _allerRetour = true;
  List<String> _joursDeMatch = [];
  String _heureDebut = '14:00';
  String _heureFin = '18:00';
  int _dureePeriode = 30;
  int _nombrePeriodes = 2;
  int _pause = 10;
  int _battement = 10;

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
      nombreTitulaires.value = competitionResponse['nombre_titulaires'] as int? ?? 11;
      effectifMax.value = competitionResponse['effectif_max'] as int? ?? 18;

      _allerRetour = competitionResponse['aller_retour'] as bool? ?? true;
      _joursDeMatch = List<String>.from(competitionResponse['jours_de_match'] as List? ?? []);
      _heureDebut = competitionResponse['heure_debut'] as String? ?? '14:00';
      _heureFin = competitionResponse['heure_fin'] as String? ?? '18:00';
      _dureePeriode = competitionResponse['duree_periode'] as int? ?? 30;
      _nombrePeriodes = competitionResponse['nombre_periodes'] as int? ?? 2;
      _pause = competitionResponse['pause'] as int? ?? 10;
      _battement = competitionResponse['battement'] as int? ?? 10;

      await _loadEquipes();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger la compétition.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadEquipes() async {
    final equipesResponse = await SupabaseService.client
        .from('equipes')
        .select('*, joueurs(count)')
        .eq('competition_id', competitionId)
        .order('created_at');

    equipes.value = (equipesResponse as List).map((e) => Equipe.fromMap(e)).toList();
  }

  Future<void> changerNombreEquipesPrevu(int nouveauNombre) async {
    final ancienneValeur = nombreEquipesPrevu.value;
    nombreEquipesPrevu.value = nouveauNombre;
    final response = await SupabaseService.client
        .from('competitions')
        .update({'nombre_equipes': nouveauNombre})
        .eq('id', competitionId)
        .select();
    if ((response as List).isEmpty) {
      nombreEquipesPrevu.value = ancienneValeur;
      Get.snackbar('Erreur', "La modification n'a pas été enregistrée.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Supprime une équipe (et ses joueurs) du brouillon. Uniquement
  /// possible tant que la compétition n'est pas lancée.
  Future<void> supprimerEquipe(String equipeId) async {
    try {
      await SupabaseService.client.from('joueurs').delete().eq('equipe_id', equipeId);
      await SupabaseService.client.from('equipes').delete().eq('id', equipeId);
      equipes.removeWhere((e) => e.id == equipeId);
    } catch (e) {
      Get.snackbar('Erreur', "Impossible de supprimer l'équipe.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  int _minutesDepuisMinuit(String heure) {
    final parts = heure.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  DateTime _prochainJour(DateTime depuis, String jourAbrege) {
    const jours = {'Lun': 1, 'Mar': 2, 'Mer': 3, 'Jeu': 4, 'Ven': 5, 'Sam': 6, 'Dim': 7};
    final cible = jours[jourAbrege] ?? depuis.weekday;
    var date = depuis;
    while (date.weekday != cible) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<bool> lancerCompetition({required DateTime dateOuverture, required bool unSeulMatchCeJour}) async {
    if (equipes.length < 2) {
      Get.snackbar('Impossible de lancer', 'Il faut au moins 2 équipes.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final equipesIncompletes = equipes.where((e) => e.joueursCount < nombreTitulaires.value).toList();
    if (equipesIncompletes.isNotEmpty) {
      final noms = equipesIncompletes.map((e) => e.nom).join(', ');
      Get.snackbar(
        'Effectifs incomplets',
        '$noms n\'ont pas encore ${nombreTitulaires.value} joueurs minimum.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (statut.value == 'active') {
      Get.snackbar('Déjà lancée', 'Cette compétition est déjà active.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    try {
      final matchsExistants = await SupabaseService.client
          .from('matchs')
          .select('id')
          .eq('competition_id', competitionId)
          .limit(1);

      if ((matchsExistants as List).isNotEmpty) {
        Get.snackbar('Calendrier déjà généré', 'Cette compétition a déjà un calendrier.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      final journees = RoundRobinScheduler.generate(equipes.length, allerRetour: _allerRetour);
      final dureeMatch = _dureePeriode * _nombrePeriodes + _pause;
      final creneauMinutes = dureeMatch + _battement;
      final debutMinutes = _minutesDepuisMinuit(_heureDebut);
      final finMinutes = _minutesDepuisMinuit(_heureFin);
      final matchsParJournee = unSeulMatchCeJour
          ? 1
          : ((finMinutes - debutMinutes) / creneauMinutes).floor().clamp(1, 999);

      final joursDisponibles = _joursDeMatch.isNotEmpty ? _joursDeMatch : ['Sam'];
      var dateCourante = dateOuverture;
      var indexJourDisponible = 0;
      final matchsAInserer = <Map<String, dynamic>>[];

      for (final journee in journees) {
        dateCourante = _prochainJour(dateCourante, joursDisponibles[indexJourDisponible % joursDisponibles.length]);
        indexJourDisponible++;

        var creneauIndex = 0;
        for (final (indexDomicile, indexExterieur) in journee) {
          final jourDecale = dateCourante.add(Duration(days: creneauIndex ~/ matchsParJournee));
          final positionDansLeJour = creneauIndex % matchsParJournee;
          final minutesDuMatch = debutMinutes + positionDansLeJour * creneauMinutes;

          final heureMatch = DateTime(
            jourDecale.year,
            jourDecale.month,
            jourDecale.day,
            minutesDuMatch ~/ 60,
            minutesDuMatch % 60,
          );

          matchsAInserer.add({
            'competition_id': competitionId,
            'equipe_domicile': equipes[indexDomicile].nom,
            'equipe_exterieur': equipes[indexExterieur].nom,
            'date_heure': heureMatch.toIso8601String(),
            'statut': 'a_venir',
          });

          creneauIndex++;
        }

        dateCourante = dateCourante.add(const Duration(days: 7));
      }

      if (matchsAInserer.isNotEmpty) {
        await SupabaseService.client.from('matchs').insert(matchsAInserer);
      }

      final response = await SupabaseService.client
          .from('competitions')
          .update({'statut': 'active'})
          .eq('id', competitionId)
          .select();

      if ((response as List).isEmpty) {
        Get.snackbar('Erreur', "La compétition n'a pas pu être lancée.", snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      statut.value = 'active';
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur génération calendrier : $e');
      Get.snackbar('Erreur', 'Impossible de générer le calendrier.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}