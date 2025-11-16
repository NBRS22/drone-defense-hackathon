from sqlalchemy import Column, Integer, String, Float, DateTime, Text, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime
import enum


class TypeCargaison(str, enum.Enum):
    POCHE_SANG = "poche_sang"
    DEFIBRILLATEUR = "defibrillateur"
    MEDICAMENT = "medicament"
    PIECE_MECANIQUE = "piece_mecanique"
    FRAGILE = "fragile"
    PERISSABLE = "perissable"
    AUTRE = "autre"


class StatutMission(str, enum.Enum):
    EN_ATTENTE = "en_attente"
    EN_COURS = "en_cours"
    TERMINEE = "terminee"
    ANNULEE = "annulee"
    ECHEC = "echec"


class HistoriqueMission(Base):
    __tablename__ = "historique_missions"

    historique_id = Column(Integer, primary_key=True, index=True)
    mission_id = Column(Integer, ForeignKey("missions.mission_id"), nullable=False)
    drone_id = Column(Integer, ForeignKey("drones.drone_id"), nullable=False)
    date = Column(DateTime, default=datetime.utcnow)
    performance = Column(String(255), nullable=True)  # performance de la mission (réussie, retard, échec)
    commentaires = Column(Text, nullable=True)  # commentaires sur la mission

    # Relations
    mission = relationship("Mission", back_populates="historique")
    drone = relationship("Drone", back_populates="historique_missions")