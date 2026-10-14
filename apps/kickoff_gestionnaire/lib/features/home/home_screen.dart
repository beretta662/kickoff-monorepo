import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../../routes.dart';
import '../../shared/widgets/load_error_view.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final username = SupabaseService.client.auth.currentUser?.userMetadata?['username'] as String? ?? 'Gestionnaire';

    return SafeArea(
      child: Column(
        children: [
          Obx(() {
            final greeting = !controller.hasCompetitions
                ? 'Bienvenue'
                : (DateTime.now().hour < 18 ? 'Bonjour' : 'Bonsoir');
            return _HomeHeader(greeting: greeting, username: username);
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.loadFailed.value) {
                return LoadErrorView(onRetry: controller.loadData);
              }
              if (!controller.hasCompetitions) {
                return const _EmptyState();
              }
              if (!controller.hasMatchesToday) {
                return _NoMatchTodayState(controller: controller);
              }
              return _MatchesTodayState(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String greeting;
  final String username;

  const _HomeHeader({required this.greeting, required this.username});

  String get _initials {
    final parts = username.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts[0][0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/images/icon_mark.png', width: 28, height: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: AppTextStyles.caption(context).copyWith(color: AppColors.primaryLight)),
                  Text(username, style: AppTextStyles.h3(context).copyWith(color: Colors.white)),
                ],
              ),
            ],
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.accent,
            child: Text(_initials, style: AppTextStyles.caption(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: palette.background, shape: BoxShape.circle),
            child: Icon(Icons.emoji_events_outlined, color: palette.textMuted, size: 30),
          ),
          const SizedBox(height: 16),
          Text('Aucune compétition pour l\'instant', style: AppTextStyles.h3(context), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            'Créez votre première compétition pour commencer.',
            style: AppTextStyles.bodySecondary(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.createCompetition),
            child: const Text('Créer une compétition'),
          ),
        ],
      ),
    );
  }
}

class _NoMatchTodayState extends StatelessWidget {
  final HomeController controller;
  const _NoMatchTodayState({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Aujourd\'hui', style: AppTextStyles.bodySecondary(context)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: palette.borderStrong),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.event_busy_outlined, color: palette.textMuted),
              const SizedBox(height: 8),
              Text('Aucun match aujourd\'hui', style: AppTextStyles.body(context)),
              const SizedBox(height: 2),
              Text('Consultez le calendrier pour voir le prochain match.', style: AppTextStyles.caption(context)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Mes compétitions', style: AppTextStyles.bodySecondary(context)),
        const SizedBox(height: 8),
        ...controller.competitions.map((c) => Card(
              child: ListTile(
                title: Text(c.nom, style: AppTextStyles.body(context)),
                subtitle: Text('${c.nombreEquipes} équipes · ${c.journeeActuelle ?? ""}', style: AppTextStyles.caption(context)),
                trailing: Icon(Icons.chevron_right, size: 18, color: palette.textMuted),
                onTap: () {
                  if (c.statut == 'active') {
                    Get.toNamed('${AppRoutes.calendar}?id=${c.id}');
                  } else {
                    Get.toNamed('${AppRoutes.competitionDraft}?id=${c.id}');
                  }
                },
              ),
            )),
      ],
    );
  }
}

class _MatchesTodayState extends StatelessWidget {
  final HomeController controller;
  const _MatchesTodayState({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Matchs du jour', style: AppTextStyles.bodySecondary(context)),
        const SizedBox(height: 8),
        ...controller.todaysMatches.map((m) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.heure, style: AppTextStyles.caption(context)),
                    const SizedBox(height: 6),
                    Text('${m.equipeDomicile} — ${m.equipeExterieur}', style: AppTextStyles.body(context)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await Get.toNamed('${AppRoutes.liveMatch}?id=${m.id}');
                        controller.loadData();
                      },
                      child: const Text('Démarrer le match'),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _StatCard(value: '${controller.nombreCompetitionsActives}', label: 'Actives', palette: palette)),
            const SizedBox(width: 8),
            Expanded(child: _StatCard(value: '${controller.nombreTotalEquipes}', label: 'Équipes', palette: palette)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final AppPalette palette;
  const _StatCard({required this.value, required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: palette.background, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h3(context)),
          Text(label, style: AppTextStyles.caption(context)),
        ],
      ),
    );
  }
}