# ClearData App

Application mobile Flutter de surveillance de la qualité de l'air en France, consommant les données d'une base relationnelle de ~3 millions de relevés réels issus de données INSEE.

## Contexte du projet

ClearData App est le client mobile du projet **ClearData**, réalisé dans le cadre de la formation **CESI**. Elle s'appuie sur l'API du site web [cleardata-site.vercel.app](https://cleardata-site.vercel.app) pour afficher, sur mobile, les mêmes données de qualité de l'air que la plateforme web.

## Stack technique

- **[Flutter](https://flutter.dev/)** / **Dart**
- **HTTP** ([package `http`](https://pub.dev/packages/http)) — consommation de l'API REST du site ClearData, aucune connexion directe à une base de données
- **fl_chart** — graphiques et courbes de tendances
- **flutter_map** / **latlong2** — carte interactive
- **cached_network_image**, **shimmer** — chargement et affichage optimisés
- **google_fonts** — typographie

## Fonctionnalités principales

L'application reprend les 5 sections du site web dans une navigation par onglets :

- **Accueil** — vue d'ensemble : nombre d'agences, de capteurs, de relevés, derniers relevés enregistrés
- **Carte** — carte interactive de France avec les concentrations de gaz par ville, filtrable par gaz et par date
- **Graphiques** — évolution temporelle des concentrations, comparaisons inter-régions, répartition par gaz
- **Requêtes** — les 12 requêtes SQL du cahier des charges, exécutées en direct sur la base et affichées avec leurs résultats
- **Recherche** — recherche d'une ville avec ses dernières concentrations relevées, tous gaz confondus

## Chiffres clés

| Donnée | Volume |
|---|---|
| Relevés de concentration | ~3 000 000 |
| Capteurs déployés | 244 000 |
| Agences régionales | 101 |
| Gaz surveillés | 7 (CO2, CH4, N2O, O3, HFC, SF6, NH3) |

## API

L'application ne contient aucune logique de base de données : toutes les données sont récupérées via l'API du site web ClearData, hébergée sur Vercel et connectée à TiDB Cloud :

```
https://cleardata-site.vercel.app
```

Voir [`lib/services/api_service.dart`](lib/services/api_service.dart) pour le détail des endpoints consommés (`/api/stats`, `/api/carte`, `/api/graphiques`, `/api/requetes`, `/api/search`).

## Installation et lancement en local

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x (Dart >=3.0.0)
- Un émulateur Android/iOS, ou un appareil physique connecté

### Étapes

1. **Cloner le dépôt**

   ```bash
   git clone https://github.com/Raphael-344/cleardata-app.git
   cd cleardata-app
   ```

2. **Installer les dépendances**

   ```bash
   flutter pub get
   ```

3. **Lancer l'application**

   ```bash
   flutter run
   ```

Aucune configuration supplémentaire n'est nécessaire : l'application pointe directement vers l'API de production du site ClearData.
