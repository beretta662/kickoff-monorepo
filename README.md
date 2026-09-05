# Kickoff — monorepo

Deux applications Flutter séparées, publiées indépendamment, partageant
du code commun via un package local.

```
kickoff_monorepo/
  packages/
    kickoff_core/          Code partagé : thème, modèles, (bientôt) service Supabase
  apps/
    kickoff_gestionnaire/  App organisateurs — création et pilotage de compétitions
    kickoff_fans/          App spectateurs — suivi en direct (squelette pour l'instant)
```

## Pourquoi cette organisation plutôt qu'un seul projet avec deux `main.dart`

On aurait pu faire une seule app Flutter avec deux points d'entrée
(`main_gestionnaire.dart` / `main_fans.dart`, via des "flavors"). On ne l'a
pas fait pour deux raisons :

- Le cahier des charges prévoit deux **applications distinctes** (deux
  fiches sur le Play Store / App Store, deux publics différents) — pas
  une seule app avec un mode caché.
- Ça évite qu'une app spectateur, censée rester légère, embarque tout le
  code de gestion de compétition (formulaires de création, saisie en
  direct...) qu'elle n'utilisera jamais.

À la place, `kickoff_core` contient uniquement ce qui est réellement
partagé (thème graphique, modèles de données comme `Competition` ou
`Equipe`, et plus tard le client Supabase). Chaque app l'importe comme
n'importe quel package, via une dépendance de chemin local — pas besoin
de le publier sur pub.dev.

## Lancer chaque app en local

⚠️ `flutter create . --overwrite` écrase aussi `lib/main.dart` et
`pubspec.yaml` avec les valeurs par défaut de Flutter, pas seulement les
dossiers natifs (android/, ios/...). Pour ne pas perdre le code déjà
écrit, on génère les dossiers natifs **à part**, puis on ne copie que
ceux-là :

```bash
# App Gestionnaire
flutter create /tmp/tmp_gestionnaire --org com.kickoff --project-name kickoff_gestionnaire
cp -r /tmp/tmp_gestionnaire/android /tmp/tmp_gestionnaire/ios /tmp/tmp_gestionnaire/web apps/kickoff_gestionnaire/
rm -rf /tmp/tmp_gestionnaire
cd apps/kickoff_gestionnaire
flutter pub get
flutter run

# App Fans — même principe
flutter create /tmp/tmp_fans --org com.kickoff --project-name kickoff_fans
cp -r /tmp/tmp_fans/android /tmp/tmp_fans/ios /tmp/tmp_fans/web apps/kickoff_fans/
rm -rf /tmp/tmp_fans
cd apps/kickoff_fans
flutter pub get
flutter run
```

`kickoff_core` n'est jamais lancé directement — c'est une bibliothèque,
pas une app. `flutter pub get` dans chaque app va automatiquement aller
lire le code de `../../packages/kickoff_core` grâce à la dépendance de
chemin dans son `pubspec.yaml`.

## Si tu modifies le thème

Modifie uniquement les fichiers dans `packages/kickoff_core/lib/theme/`.
Les deux apps verront le changement au prochain `flutter pub get` (ou
même directement au hot reload si l'app tourne déjà).
