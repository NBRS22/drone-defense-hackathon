from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime
import enum


class MissionCategory(str, enum.Enum):
    SOINS = "soins"
    MECANIQUE = "mecanique"
    RECONNAISSANCE = "reconnaissance"
    LIVRAISON = "livraison"


class StatutMission(str, enum.Enum):
    PENDING = "pending"
    IN_PROGRESS = "in-progress"
    COMPLETED = "completed"
    FAILED = "failed"


class Priority(str, enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class Risk(str, enum.Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class Mission(Base):
    __tablename__ = "missions"

    mission_id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)  # titre de la mission
    category = Column(String(50), nullable=False)  # catégorie de mission
    drone_id = Column(String(50), nullable=True)  # ID du drone assigné
    priority = Column(String(50), nullable=False)  # niveau de priorité
    status = Column(String(50), default=StatutMission.PENDING.value)
    risk = Column(String(50), nullable=True)  # niveau de risque
    location = Column(String(255), nullable=False)  # localisation principale
    description = Column(String(1000), nullable=True)  # description de la mission
    estimated_duration = Column(Integer, nullable=True)  # durée estimée en minutes
    weight = Column(Float, nullable=True)  # poids en kg
    start_date = Column(DateTime, nullable=True)  # date de début planifiée
    departure = Column(String(255), nullable=True)  # point de départ
    arrival = Column(String(255), nullable=True)  # point d'arrivée
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations (conservées pour compatibilité)
    zone = relationship("ZoneDeVol", back_populates="missions", foreign_keys="Mission.zone_id")
    historique = relationship("HistoriqueMission", back_populates="mission")

