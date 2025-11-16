from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime
from app.models.mission import TypeCargaison, StatutMission
import math


class MissionBase(BaseModel):
    poids: float = Field(..., gt=0, description="Poids de la cargaison en kg")
    risque: int = Field(..., ge=1, le=5, description="Niveau de risque (1-5)")
    type_cargaison: Optional[str] = Field(None, description="Type de cargaison")
    latitude_depart: float = Field(..., ge=-90, le=90, description="Latitude de départ")
    longitude_depart: float = Field(..., ge=-180, le=180, description="Longitude de départ")
    latitude_arrivee: float = Field(..., ge=-90, le=90, description="Latitude d'arrivée")
    longitude_arrivee: float = Field(..., ge=-180, le=180, description="Longitude d'arrivée")
    description: Optional[str] = Field(None, max_length=1000)
    destinataire: Optional[str] = Field(None, max_length=255)
    telephone_contact: Optional[str] = Field(None, max_length=20)
    zone_id: Optional[int] = Field(None, description="ID de la zone de vol")


def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calcule la distance entre deux points GPS en utilisant la formule de Haversine"""
    R = 6371  # Rayon de la Terre en km
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    a = (math.sin(delta_lat / 2) ** 2 + 
         math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c


class MissionCreate(MissionBase):
    pass


class MissionResponse(MissionBase):
    mission_id: int
    distance: float
    statut: str
    drone_id: Optional[int] = None
    date_debut: Optional[datetime] = None
    date_fin: Optional[datetime] = None
    date_creation: datetime

    class Config:
        from_attributes = True


class MissionUpdate(BaseModel):
    statut: Optional[StatutMission] = None
    drone_id: Optional[int] = None
    zone_id: Optional[int] = None
    date_debut: Optional[datetime] = None
    date_fin: Optional[datetime] = None

