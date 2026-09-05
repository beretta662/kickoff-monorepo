import 'package:get/get.dart';
import 'routes.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/home/home_screen.dart';

/// Associe chaque route nommée (voir routes.dart) à l'écran qui doit
/// s'afficher. Nouvelle page construite = une ligne à ajouter ici.
final List<GetPage> appPages = [
  GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
  GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
];