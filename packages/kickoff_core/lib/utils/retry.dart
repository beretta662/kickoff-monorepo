/// Relance une opération asynchrone en cas d'échec, avec une courte
/// pause croissante entre les tentatives. Utile pour les échecs
/// passagers (réseau, jeton de session en cours de rafraîchissement)
/// qui disparaissent d'eux-mêmes une seconde plus tard.
Future<T> withRetry<T>(
  Future<T> Function() action, {
  int attempts = 3,
  Duration delay = const Duration(milliseconds: 600),
}) async {
  var essai = 0;
  while (true) {
    try {
      return await action();
    } catch (e) {
      essai++;
      // Visible dans la console du navigateur (F12) pour diagnostiquer.
      // ignore: avoid_print
      print('Tentative $essai/$attempts échouée : $e');
      if (essai >= attempts) rethrow;
      await Future.delayed(delay * essai);
    }
  }
}