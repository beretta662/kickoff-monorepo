import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'create_competition_controller.dart';
import 'steps/step1_sport.dart';
import 'steps/step2_type.dart';
import '../../../shared/widgets/coming_soon_screen.dart';

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
                          onPressed: controller.canGoNext
                              ? () {
                                  if (controller.currentStep.value == 0 && controller.sport.value != 'Football') {
                                    Get.to(() => ComingSoonScreen(featureName: controller.sport.value!));
                                    return;
                                  }
                                  controller.goNext();
                                }
                              : null,
                          child: Text(controller.currentStep.value == CreateCompetitionController.totalSteps - 1
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
      default:
        return const Center(child: Text('Étape à venir'));
    }
  }
}