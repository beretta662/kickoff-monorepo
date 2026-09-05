import 'package:flutter/material.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'package:get/get.dart';
import 'app_pages.dart';
import 'routes.dart';

void main() {
  runApp(const KickoffApp());
}

class KickoffApp extends StatelessWidget {
  const KickoffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kickoff — Gestionnaire',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      getPages: appPages,
    );
  }
}