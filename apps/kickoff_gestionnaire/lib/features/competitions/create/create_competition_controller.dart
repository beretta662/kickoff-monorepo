import 'package:get/get.dart';

enum CompetitionType { championnat, coupe }
enum CompetitionFormat { amateur, pro }

/// Garde tout l'état des 6 étapes de création, pour qu'on puisse
/// naviguer entre les étapes sans rien perdre. Rempli au fil des
/// écrans, envoyé à Supabase seulement à la toute fin (étape 6).
class CreateCompetitionController extends GetxController {
  final currentStep = 0.obs; // 0 à 5 (6 étapes)
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
  final dureePeriode = 30.obs; // minutes
  final nombrePeriodes = 2.obs;
  final pause = 10.obs; // minutes
  final battement = 10.obs; // minutes

  // Étape 6 (championnat)
  final alimenteCoupeFuture = false.obs;
  final nombreEquipesQualifiees = 4.obs;

  double get progress => (currentStep.value + 1) / totalSteps;

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
}