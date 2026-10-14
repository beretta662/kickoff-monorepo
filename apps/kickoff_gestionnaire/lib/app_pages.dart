import 'package:get/get.dart';
import 'routes.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/competitions/create/create_competition_screen.dart';
import 'features/competitions/draft/draft_competition_screen.dart';
import 'features/competitions/calendar/calendar_screen.dart';
import 'features/live_match/live_match_screen.dart';
import 'features/competitions/standings/standings_screen.dart';

final List<GetPage> appPages = [
  GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
  GetPage(name: AppRoutes.home, page: () => const MainNavigationScreen()),
  GetPage(name: AppRoutes.createCompetition, page: () => const CreateCompetitionScreen()),
  GetPage(
    name: AppRoutes.competitionDraft,
    page: () => DraftCompetitionScreen(competitionId: Get.parameters['id']!),
  ),
  GetPage(
    name: AppRoutes.calendar,
    page: () => CalendarScreen(competitionId: Get.parameters['id']!),
  ),
  GetPage(
    name: AppRoutes.liveMatch,
    page: () => LiveMatchScreen(matchId: Get.parameters['id']!),
  ),
  GetPage(
    name: AppRoutes.standings,
    page: () => StandingsScreen(competitionId: Get.parameters['id']!),
  ),
];