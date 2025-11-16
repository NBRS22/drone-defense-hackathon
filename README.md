# Drone Delivery - Livraison en situation de crise

Application complète pour la gestion de livraisons par drone en situation de crise. Le système permet de livrer du matériel critique (poche de sang, défibrillateur, pièces mécaniques, médicaments...) de manière fiable et rapide.

## Structure du projet

```
.
├── backend/           # API REST Python (FastAPI)
│   ├── app/
│   │   ├── models/    # Modèles de données SQLAlchemy
│   │   ├── schemas/   # Schémas Pydantic pour validation
│   │   ├── routes/    # Routes API
│   │   └── main.py    # Point d'entrée FastAPI
│   └── requirements.txt
│
└── frontend/          # Application Flutter (Web Chrome, Android, Windows Desktop)
    ├── lib/
    │   ├── models/    # Modèles de données Dart
    │   ├── pages/     # Pages de l'application
    │   ├── services/  # Services API
    │   └── main.dart  # Point d'entrée Flutter
    └── pubspec.yaml
```

## Technologies utilisées

### Backend
- **FastAPI** : Framework web moderne et rapide pour Python
- **SQLAlchemy** : ORM pour la gestion de base de données
- **Pydantic** : Validation des données
- **Uvicorn** : Serveur ASGI

### Frontend
- **Flutter** : Framework multiplateforme (Web Chrome, Android, Windows Desktop)
- **Material Design 3** : Design moderne et intuitif

## Installation et lancement

### Backend

1. Installer les dépendances :
```bash
cd backend
pip install -r requirements.txt
```

2. Configurer l'environnement (optionnel) :
```bash
cp .env.example .env
```

3. Lancer le serveur :
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

L'API sera accessible sur `http://localhost:8000`
Documentation interactive : `http://localhost:8000/docs`

### Frontend

1. Installer les dépendances :
```bash
cd frontend
flutter pub get
```

2. Lancer l'application :
```bash
# Web (Chrome)
flutter run -d chrome

# Android (émulateur ou appareil connecté)
flutter run

# Windows Desktop
flutter run -d windows
```

**Note** : L'URL de l'API est détectée automatiquement :
- Web (Chrome) : `http://localhost:8000`
- Android Emulator : `http://10.0.2.2:8000`
- Windows Desktop : `http://localhost:8000`
- Appareil physique Android : Modifiez `lib/services/api_service.dart` avec votre IP locale

## Fonctionnalités actuelles

### Page d'ajout de mission

Interface complète permettant de :
- Sélectionner le type de matériel (Poche de sang, Défibrillateur, Médicament, Pièce mécanique, Autre)
- Définir le niveau d'urgence (Critique, Élevée, Normale)
- Spécifier le poids du matériel
- Définir les coordonnées de départ et d'arrivée
- Ajouter des informations complémentaires (destinataire, téléphone, description)
- Valider et créer la mission via l'API

## API Endpoints

- `POST /api/missions/` : Créer une nouvelle mission
- `GET /api/missions/` : Récupérer toutes les missions
- `GET /api/missions/{id}` : Récupérer une mission spécifique
- `PATCH /api/missions/{id}` : Mettre à jour une mission
- `DELETE /api/missions/{id}` : Supprimer une mission

## Évolutions prévues

- Attribution automatique du drone selon le poids, la distance et le niveau de risque
- Protocole de vol autonome avec simulation
- Visualisation des missions sur carte
- Gestion des drones disponibles
- Système d'authentification et sécurisation des données
- Interface de suivi en temps réel

## Défis du challenge

- ✅ **Évolutivité logicielle** : Architecture modulaire et extensible
- ✅ **Expérience utilisateur** : Interface claire et intuitive
- 🔄 **Pertinence logistique** : À implémenter (attribution automatique du drone)
- 🔄 **Capacité de montée en charge** : À optimiser (gestion des demandes en parallèle)
- 🔄 **Sécurisation des données** : À implémenter (authentification, chiffrement)

