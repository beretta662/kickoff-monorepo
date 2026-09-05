import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';

/// Point de départ de l'app Fans. On construira les vrais écrans
/// (accueil personnalisé, matchs en direct, recherche...) plus tard,
/// une fois l'app Gestionnaire bien avancée — voir README du monorepo.
void main() {
  runApp(const KickoffFansApp());
}

class KickoffFansApp extends StatelessWidget {
  const KickoffFansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kickoff',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // même thème que l'app Gestionnaire
      home: Scaffold(
        appBar: AppBar(title: const Text('Kickoff Fans')),
        body: Center(
          child: Text('Bientôt disponible', style: AppTextStyles.h2),
        ),
      ),
    );
  }
}
