/// Génère un calendrier de championnat par la méthode du cercle
/// (round-robin), garantissant que chaque équipe rencontre toutes les
/// autres une fois (ou deux, en aller-retour), sans répétition
/// consécutive anormale.
///
/// Retourne une liste de journées, chaque journée étant une liste de
/// paires [équipeDomicile, équipeExterieur] (index dans la liste
/// d'équipes fournie).
class RoundRobinScheduler {
  /// Si le nombre d'équipes est impair, une équipe "fantôme" (index -1)
  /// est ajoutée : l'équipe qui lui est associée dans une journée donnée
  /// est au repos ce jour-là (pas de match généré pour elle).
  static List<List<(int, int)>> generate(int nombreEquipes, {required bool allerRetour}) {
    if (nombreEquipes < 2) return [];

    final estImpair = nombreEquipes.isOdd;
    final n = estImpair ? nombreEquipes + 1 : nombreEquipes;
    final equipes = List<int>.generate(n, (i) => i);

    final journees = <List<(int, int)>>[];

    for (var journee = 0; journee < n - 1; journee++) {
      final rencontres = <(int, int)>[];
      for (var i = 0; i < n ~/ 2; i++) {
        final domicile = equipes[i];
        final exterieur = equipes[n - 1 - i];
        // -1 (l'équipe fantôme) = repos ce jour-là pour l'autre équipe.
        if (!estImpair || (domicile != nombreEquipes && exterieur != nombreEquipes)) {
          // Alterne domicile/extérieur d'une journée à l'autre pour
          // équilibrer, sauf pour la première paire qui reste fixe
          // (pivot de la méthode du cercle).
          if (journee.isOdd && i != 0) {
            rencontres.add((exterieur, domicile));
          } else {
            rencontres.add((domicile, exterieur));
          }
        }
      }
      journees.add(rencontres);

      // Rotation : tout le monde tourne d'un cran sauf le premier élément.
      final dernier = equipes.removeLast();
      equipes.insert(1, dernier);
    }

    if (allerRetour) {
      final journeesRetour = journees.map((j) => j.map((match) => (match.$2, match.$1)).toList()).toList();
      journees.addAll(journeesRetour);
    }

    return journees;
  }
}