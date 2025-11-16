from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
import os
from dotenv import load_dotenv

load_dotenv()

# Create the base class for all models
Base = declarative_base()

# URL de la base de données (SQLite pour le développement)
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./drone_delivery.db")

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def init_db():
    """Initialise la base de données"""
    # Import all models to make sure they are registered with Base
    from app.models import Mission, Drone, ZoneDeVol, HistoriqueMission
    
    # Create all tables
    Base.metadata.create_all(bind=engine)


def get_db():
    """Dépendance pour obtenir une session de base de données"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

