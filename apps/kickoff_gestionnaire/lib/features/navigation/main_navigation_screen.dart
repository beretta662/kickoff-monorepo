import 'package:flutter/material.dart';
import 'package:kickoff_core/kickoff_core.dart';
import '../home/home_screen.dart';
import '../competitions/list/competitions_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    CompetitionsScreen(),
    _PlaceholderScreen(title: 'Partages'),
    _PlaceholderScreen(title: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: palette.surface,
        indicatorColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: palette.textMuted),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined, color: palette.textMuted),
            selectedIcon: const Icon(Icons.emoji_events, color: AppColors.primary),
            label: 'Compétitions',
          ),
          NavigationDestination(
            icon: Icon(Icons.share_outlined, color: palette.textMuted),
            selectedIcon: const Icon(Icons.share, color: AppColors.primary),
            label: 'Partages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: palette.textMuted),
            selectedIcon: const Icon(Icons.person, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title — bientôt disponible', style: AppTextStyles.bodySecondary(context)));
  }
}