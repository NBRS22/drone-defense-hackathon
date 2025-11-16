# Frontend - Drone Delivery App

Application Flutter pour la gestion de livraisons par drone en situation de crise.

## Fonctionnalités

- Interface pour créer de nouvelles missions de livraison
- Support multiplateforme : Web (Chrome), Android, Windows Desktop
- Design moderne et intuitif

## Prérequis

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Pour Android : Android Studio (optionnel, pour émulateur)
- Pour Windows Desktop : Visual Studio 2022 avec "Développement Desktop en C++" (optionnel)

## Installation

```bash
flutter pub get
```

## Configuration

Avant de lancer l'application, assurez-vous que le backend est démarré sur `http://localhost:8000`.

L'URL de l'API est détectée automatiquement selon la plateforme :
- **Web (Chrome)** : `http://localhost:8000` ✅
- **Android Emulator** : `http://10.0.2.2:8000` ✅
- **Windows Desktop** : `http://localhost:8000` ✅
- **Appareil physique Android** : Modifiez `lib/services/api_service.dart` avec votre IP locale

## Lancement

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android
```bash
# Avec émulateur ou appareil connecté
flutter run
```

### Windows Desktop
```bash
flutter run -d windows
```

## Configuration de l'API pour appareil physique Android

Si vous testez sur un appareil Android physique :

1. Trouvez votre IP locale :
   ```powershell
   ipconfig | findstr "IPv4"
   ```

2. Modifiez `lib/services/api_service.dart` :
   ```dart
   } else if (Platform.isAndroid) {
     return 'http://192.168.0.26:8000'; // Votre IP locale
   }
   ```

3. Assurez-vous que le backend est démarré avec `--host 0.0.0.0` :
   ```powershell
   cd backend
   .\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

## Structure du projet

```
lib/
├── main.dart              # Point d'entrée de l'application
├── models/                # Modèles de données
│   └── mission.dart
├── pages/                 # Pages de l'application
│   └── add_mission_page.dart
└── services/              # Services API
    └── api_service.dart
```

