/// Toutes les routes nommées de l'application, à un seul endroit.
///
/// But : ne jamais écrire `Get.toNamed('/login')` avec une chaîne en dur
/// dans un écran — une faute de frappe sur une route ne serait détectée
/// qu'au moment du clic, pas à la compilation. On écrit toujours
/// `Get.toNamed(AppRoutes.login)` à la place.
///
/// Les GetPage correspondantes seront ajoutées au fur et à mesure que
/// les écrans seront construits (voir app_pages.dart, pas encore créé).
abstract class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const competitions = '/competitions';
  static const createCompetition = '/competitions/create';
  static const competitionDraft = '/competitions/draft';
  static const shares = '/shares';
  static const profile = '/profile';
}
