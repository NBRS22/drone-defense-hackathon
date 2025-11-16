from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime
from app.models.mission import TypeMateriel, Urgence


class MissionBase(BaseModel):
    type_materiel: TypeMateriel
    urgence: Urgence
    poids_kg: float = Field(..., gt=0, description="Poids en kilogrammes")
    latitude_depart: float = Field(..., ge=-90, le=90, description="Latitude de départ")
    longitude_depart: float = Field(..., ge=-180, le=180, description="Longitude de départ")
    latitude_arrivee: float = Field(..., ge=-90, le=90, description="Latitude d'arrivée")
    longitude_arrivee: float = Field(..., ge=-180, le=180, description="Longitude d'arrivée")
    description: Optional[str] = Field(None, max_length=1000)
    destinataire: Optional[str] = Field(None, max_length=255)
    telephone_contact: Optional[str] = Field(None, max_length=20)


class MissionCreate(MissionBase):
    pass


class MissionResponse(MissionBase):
    id: int
    statut: str
    drone_id: Optional[int] = None
    date_creation: datetime
    date_attribution: Optional[datetime] = None
    date_livraison: Optional[datetime] = None

    class Config:
        from_attributes = True


class MissionUpdate(BaseModel):
    statut: Optional[str] = None
    drone_id: Optional[int] = None
    date_attribution: Optional[datetime] = None
    date_livraison: Optional[datetime] = None

