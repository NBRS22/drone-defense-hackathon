from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app import database
from app.routes import missions

# Initialiser la base de données
database.init_db()

app = FastAPI(
    title="Drone Delivery API",
    description="API pour la gestion de livraisons par drone en situation de crise",
    version="1.0.0"
)

# Configuration CORS pour permettre les requêtes depuis Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifier les origines autorisées
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inclure les routes
app.include_router(missions.router)


@app.get("/")
def root():
    return {
        "message": "API Drone Delivery",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
def health_check():
    return {"status": "healthy"}

