from sqlalchemy import Column, Integer, String, Float, Text
from sqlalchemy.orm import relationship
from app.database import Base
import enum


class StatutDrone(str, enum.Enum):
    DISPONIBLE = "disponible"
    EN_MISSION = "en_mission"
    EN_MAINTENANCE = "en_maintenance"
    HORS_SERVICE = "hors_service"


class Drone(Base):
    __tablename__ = "drones"

    drone_id = Column(Integer, primary_key=True, index=True)
    nom = Column(String(255), nullable=False)
    poids_max = Column(Float, nullable=False)  # capacité de charge en kg
    autonomie_max = Column(Float, nullable=False)  # en km
    vitesse_max = Column(Float, nullable=False)  # en km/h
    niveau_securite = Column(Integer, nullable=False)  # niveau de sécurité (échelle de 1 à 5)
    statut = Column(String(50), default=StatutDrone.DISPONIBLE.value)
    zone_vol_autorisee = Column(String(255), nullable=True)  # zones où le drone peut voler

    # Relations
    missions = relationship("Mission", back_populates="drone")
    historique_missions = relationship("HistoriqueMission", back_populates="drone")