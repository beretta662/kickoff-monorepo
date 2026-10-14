import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

class EquipeClassement {
  final String nom;
  int joues = 0;
  int victoires = 0;
  int nuls = 0;
  int defaites = 0;
  int butsPour = 0;
  int butsContre = 0;

  EquipeClassement(this.nom);

  int get differenceButs => butsPour - butsContre;
  int get points => victoires * 3 + nuls;
}

class StandingsController extends GetxController {
  final String competitionId;
  StandingsController({required this.competitionId});

  final classement = <EquipeClassement>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final equipesResponse = await SupabaseService.client
          .from('equipes')
          .select('nom')
          .eq('competition_id', competitionId);

      final table = <String, EquipeClassement>{
        for (final e in (equipesResponse as List)) (e['nom'] as String): EquipeClassement(e['nom'] as String),
      };

      final matchsResponse = await SupabaseService.client
          .from('matchs')
          .select()
          .eq('competition_id', competitionId)
          .eq('statut', 'termine');

      for (final m in (matchsResponse as List)) {
        final domicile = m['equipe_domicile'] as String;
        final exterieur = m['equipe_exterieur'] as String;
        final scoreDomicile = m['score_domicile'] as int? ?? 0;
        final scoreExterieur = m['score_exterieur'] as int? ?? 0;

        final eqDomicile = table.putIfAbsent(domicile, () => EquipeClassement(domicile));
        final eqExterieur = table.putIfAbsent(exterieur, () => EquipeClassement(exterieur));

        eqDomicile.joues++;
        eqExterieur.joues++;
        eqDomicile.butsPour += scoreDomicile;
        eqDomicile.butsContre += scoreExterieur;
        eqExterieur.butsPour += scoreExterieur;
        eqExterieur.butsContre += scoreDomicile;

        if (scoreDomicile > scoreExterieur) {
          eqDomicile.victoires++;
          eqExterieur.defaites++;
        } else if (scoreDomicile < scoreExterieur) {
          eqExterieur.victoires++;
          eqDomicile.defaites++;
        } else {
          eqDomicile.nuls++;
          eqExterieur.nuls++;
        }
      }

      final liste = table.values.toList();
      liste.sort((a, b) {
        if (b.points != a.points) return b.points.compareTo(a.points);
        if (b.differenceButs != a.differenceButs) return b.differenceButs.compareTo(a.differenceButs);
        if (b.butsPour != a.butsPour) return b.butsPour.compareTo(a.butsPour);
        return a.nom.compareTo(b.nom);
      });

      classement.value = liste;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger le classement.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}