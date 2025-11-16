from sqlalchemy import Column, Integer, String, Float, DateTime, Enum as SQLEnum
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
import enum

Base = declarative_base()


class TypeMateriel(str, enum.Enum):
    POCHE_SANG = "poche_sang"
    DEFIBRILLATEUR = "defibrillateur"
    MEDICAMENT = "medicament"
    PIECE_MECANIQUE = "piece_mecanique"
    AUTRE = "autre"


class Urgence(str, enum.Enum):
    CRITIQUE = "critique"
    ELEVEE = "elevee"
    NORMALE = "normale"


class Mission(Base):
    __tablename__ = "missions"

    id = Column(Integer, primary_key=True, index=True)
    type_materiel = Column(SQLEnum(TypeMateriel), nullable=False)
    urgence = Column(SQLEnum(Urgence), nullable=False)
    poids_kg = Column(Float, nullable=False)
    
    # Coordonnées de départ
    latitude_depart = Column(Float, nullable=False)
    longitude_depart = Column(Float, nullable=False)
    
    # Coordonnées d'arrivée
    latitude_arrivee = Column(Float, nullable=False)
    longitude_arrivee = Column(Float, nullable=False)
    
    # Informations complémentaires
    description = Column(String(1000), nullable=True)
    destinataire = Column(String(255), nullable=True)
    telephone_contact = Column(String(20), nullable=True)
    
    # État de la mission
    statut = Column(String(50), default="en_attente")
    drone_id = Column(Integer, nullable=True)
    
    # Timestamps
    date_creation = Column(DateTime, default=datetime.utcnow)
    date_attribution = Column(DateTime, nullable=True)
    date_livraison = Column(DateTime, nullable=True)

