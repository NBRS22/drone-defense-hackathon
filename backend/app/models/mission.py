from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
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


class Mission(Base):
    __tablename__ = "missions"

    mission_id = Column(Integer, primary_key=True, index=True)
    poids = Column(Float, nullable=False)  # poids de la cargaison
    distance = Column(Float, nullable=False)  # distance de la mission en km
    risque = Column(Integer, nullable=False)  # niveau de risque (échelle de 1 à 5)
    type_cargaison = Column(String(255), nullable=True)  # type de cargaison
    statut = Column(String(50), default=StatutMission.EN_ATTENTE.value)
    date_debut = Column(DateTime, nullable=True)  # date de début de la mission
    date_fin = Column(DateTime, nullable=True)  # date de fin de la mission
    drone_id = Column(Integer, ForeignKey("drones.drone_id"), nullable=True)
    zone_id = Column(Integer, ForeignKey("zones_de_vol.zone_id"), nullable=True)
    
    # Coordonnées de départ (gardées pour compatibilité)
    latitude_depart = Column(Float, nullable=False)
    longitude_depart = Column(Float, nullable=False)
    
    # Coordonnées d'arrivée (gardées pour compatibilité)
    latitude_arrivee = Column(Float, nullable=False)
    longitude_arrivee = Column(Float, nullable=False)
    
    # Informations complémentaires (gardées pour compatibilité)
    description = Column(String(1000), nullable=True)
    destinataire = Column(String(255), nullable=True)
    telephone_contact = Column(String(20), nullable=True)
    
    # Timestamps
    date_creation = Column(DateTime, default=datetime.utcnow)
    
    # Relations
    drone = relationship("Drone", back_populates="missions")
    zone = relationship("ZoneDeVol", back_populates="missions")
    historique = relationship("HistoriqueMission", back_populates="mission")

