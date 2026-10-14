import 'dart:async';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

class LiveMatchController extends GetxController {
  final String matchId;
  LiveMatchController({required this.matchId});

  final equipeDomicile = ''.obs;
  final equipeExterieur = ''.obs;
  final scoreDomicile = 0.obs;
  final scoreExterieur = 0.obs;
  final statut = 'a_venir'.obs;
  final isLoading = true.obs;
  final minutesEcoulees = 0.obs;

  DateTime? _demarreA;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final response = await SupabaseService.client.from('matchs').select().eq('id', matchId).single();

      equipeDomicile.value = response['equipe_domicile'] as String;
      equipeExterieur.value = response['equipe_exterieur'] as String;
      scoreDomicile.value = response['score_domicile'] as int? ?? 0;
      scoreExterieur.value = response['score_exterieur'] as int? ?? 0;
      statut.value = response['statut'] as String? ?? 'a_venir';

      final demarreAValue = response['demarre_a'] as String?;
      _demarreA = demarreAValue != null ? DateTime.parse(demarreAValue).toLocal() : null;

      if (statut.value == 'a_venir') {
        await demarrerMatch();
      } else if (statut.value == 'en_cours') {
        _startTimer();
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger le match.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> demarrerMatch() async {
    final maintenant = DateTime.now();
    try {
      await SupabaseService.client.from('matchs').update({
        'statut': 'en_cours',
        'demarre_a': maintenant.toIso8601String(),
      }).eq('id', matchId);
      statut.value = 'en_cours';
      _demarreA = maintenant;
      _startTimer();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de démarrer le match.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _startTimer() {
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _updateElapsed());
  }

  void _updateElapsed() {
    if (_demarreA == null) return;
    minutesEcoulees.value = DateTime.now().difference(_demarreA!).inMinutes;
  }

  Future<void> ajouterButPourDomicile() => _ajouterBut(domicile: true);
  Future<void> ajouterButPourExterieur() => _ajouterBut(domicile: false);

  Future<void> _ajouterBut({required bool domicile}) async {
    if (domicile) {
      scoreDomicile.value++;
    } else {
      scoreExterieur.value++;
    }
    try {
      await SupabaseService.client.from('matchs').update({
        'score_domicile': scoreDomicile.value,
        'score_exterieur': scoreExterieur.value,
      }).eq('id', matchId);
    } catch (e) {
      if (domicile) {
        scoreDomicile.value--;
      } else {
        scoreExterieur.value--;
      }
      Get.snackbar('Erreur', "Le but n'a pas pu être enregistré.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<bool> terminerMatch() async {
    try {
      final response = await SupabaseService.client
          .from('matchs')
          .update({'statut': 'termine'})
          .eq('id', matchId)
          .select();
      if ((response as List).isEmpty) {
        Get.snackbar('Erreur', 'Impossible de terminer le match.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      statut.value = 'termine';
      _timer?.cancel();
      return true;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de terminer le match.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}