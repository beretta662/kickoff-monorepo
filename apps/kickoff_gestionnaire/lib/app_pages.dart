import 'package:get/get.dart';
import 'routes.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/competitions/create/create_competition_screen.dart';

final List<GetPage> appPages = [
  GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
  GetPage(name: AppRoutes.home, page: () => const MainNavigationScreen()),
  GetPage(name: AppRoutes.createCompetition, page: () => const CreateCompetitionScreen()),
];