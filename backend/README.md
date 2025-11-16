# Backend - Drone Delivery API

API REST développée avec FastAPI pour la gestion de livraisons par drone en situation de crise.

## Installation

```bash
pip install -r requirements.txt
```

## Configuration

Copiez `.env.example` vers `.env` et configurez les variables d'environnement.

## Lancement

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

L'API sera accessible sur `http://localhost:8000`
La documentation interactive est disponible sur `http://localhost:8000/docs`

