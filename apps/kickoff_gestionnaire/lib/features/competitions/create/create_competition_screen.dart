import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'create_competition_controller.dart';
import 'steps/step1_sport.dart';
import 'steps/step2_type.dart';
import 'steps/step3_format.dart';
import 'steps/step4_infos.dart';
import 'steps/step5_horaires.dart';
import 'steps/step6_finalisation.dart';
import '../../../shared/widgets/coming_soon_screen.dart';
import '../../../routes.dart';

class CreateCompetitionScreen extends StatelessWidget {
  const CreateCompetitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateCompetitionController());
    final palette = AppPalette.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() => Text(
                    'Étape ${controller.currentStep.value + 1} sur ${CreateCompetitionController.totalSteps}',
                    style: AppTextStyles.caption(context),
                  )),
              const SizedBox(height: 6),
              Obx(() => ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      minHeight: 4,
                      backgroundColor: palette.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() => _buildStepContent(controller.currentStep.value)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (controller.currentStep.value == 0) {
                          Get.back();
                        } else {
                          controller.goBack();
                        }
                      },
                      child: const Text('Retour'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.canGoNext
                                  ? () async {
                                      if (controller.currentStep.value == 0 && controller.sport.value != 'Football') {
                                        Get.to(() => ComingSoonScreen(featureName: controller.sport.value!));
                                        return;
                                      }

                                      if (controller.currentStep.value == CreateCompetitionController.totalSteps - 1) {
                                        final id = await controller.submit();
                                        if (id != null) {
                                          Get.offAllNamed(AppRoutes.home);
                                          Get.snackbar(
                                            'Compétition créée',
                                            'Elle apparaît maintenant en brouillon dans "Mes compétitions".',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        } else if (controller.submitError.value != null) {
                                          Get.snackbar('Erreur', controller.submitError.value!, snackPosition: SnackPosition.BOTTOM);
                                        }
                                        return;
                                      }

                                      controller.goNext();
                                    }
                                  : null,
                          child: controller.isSubmitting.value
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(controller.currentStep.value == CreateCompetitionController.totalSteps - 1
                                  ? 'Créer la compétition'
                                  : 'Continuer'),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const Step1Sport();
      case 1:
        return const Step2Type();
      case 2:
        return const Step3Format();
      case 3:
        return const Step4Infos();
      case 4:
        return const Step5Horaires();
      case 5:
        return const Step6Finalisation();
      default:
        return const Center(child: Text('Étape à venir'));
    }
  }
}