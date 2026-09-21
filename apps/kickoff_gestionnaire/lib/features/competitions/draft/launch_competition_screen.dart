import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'draft_competition_controller.dart';

class LaunchCompetitionScreen extends StatefulWidget {
  final DraftCompetitionController controller;
  const LaunchCompetitionScreen({super.key, required this.controller});

  @override
  State<LaunchCompetitionScreen> createState() => _LaunchCompetitionScreenState();
}

class _LaunchCompetitionScreenState extends State<LaunchCompetitionScreen> {
  DateTime _dateOuverture = DateTime.now().add(const Duration(days: 3));
  bool _unSeulMatchCeJour = true;
  bool _isLaunching = false;

  Future<void> _choisirDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _dateOuverture,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (result != null) setState(() => _dateOuverture = result);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final formatteur = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Lancer la compétition')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Dernière étape avant l'ouverture de la saison.", style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 20),

              Text("Date du match d'ouverture", style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _choisirDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(border: Border.all(color: palette.borderStrong), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18, color: palette.textMuted),
                      const SizedBox(width: 10),
                      Text(formatteur.format(_dateOuverture), style: AppTextStyles.body(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _unSeulMatchCeJour,
                onChanged: (v) => setState(() => _unSeulMatchCeJour = v),
                activeColor: AppColors.primary,
                title: Text('Un seul match ce jour-là ?', style: AppTextStyles.body(context)),
                subtitle: Text(
                  'Sinon, plusieurs matchs seront prévus selon vos horaires',
                  style: AppTextStyles.caption(context),
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'Le calendrier complet sera généré automatiquement à partir de cette date, selon vos horaires configurés.',
                  style: AppTextStyles.caption(context),
                ),
              ),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: _isLaunching
                    ? null
                    : () async {
                        setState(() => _isLaunching = true);
                        final success = await widget.controller.lancerCompetition(
                          dateOuverture: _dateOuverture,
                          unSeulMatchCeJour: _unSeulMatchCeJour,
                        );
                        if (success && mounted) {
                          Get.back();
                          Get.snackbar('Compétition lancée', 'Le calendrier a été généré.', snackPosition: SnackPosition.BOTTOM);
                        }
                        if (mounted) setState(() => _isLaunching = false);
                      },
                icon: _isLaunching
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.flag_outlined, size: 20),
                label: const Text('Confirmer et lancer'),
              ),
              const SizedBox(height: 6),
              Text('Action irréversible', style: AppTextStyles.caption(context), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}