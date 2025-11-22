from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime
from app.models.mission import MissionCategory, StatutMission, Priority, Risk


class MissionBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255, description="Titre de la mission")
    category: MissionCategory = Field(..., description="Catégorie de mission")
    priority: Priority = Field(..., description="Niveau de priorité")
    risk: Optional[Risk] = Field(None, description="Niveau de risque")
    location: str = Field(..., min_length=1, max_length=255, description="Localisation principale")
    description: Optional[str] = Field(None, max_length=1000, description="Description détaillée")
    estimated_duration: Optional[int] = Field(None, gt=0, description="Durée estimée en minutes")
    weight: Optional[float] = Field(None, gt=0, description="Poids en kg")
    start_date: Optional[datetime] = Field(None, description="Date de début planifiée")
    departure: Optional[str] = Field(None, max_length=255, description="Point de départ")
    arrival: Optional[str] = Field(None, max_length=255, description="Point d'arrivée")


class MissionCreate(MissionBase):
    pass


class MissionResponse(MissionBase):
    mission_id: int
    drone_id: Optional[str] = None
    status: StatutMission
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class MissionUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    category: Optional[MissionCategory] = None
    priority: Optional[Priority] = None
    risk: Optional[Risk] = None
    status: Optional[StatutMission] = None
    drone_id: Optional[str] = None
    location: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=1000)
    estimated_duration: Optional[int] = Field(None, gt=0)
    weight: Optional[float] = Field(None, gt=0)
    start_date: Optional[datetime] = None
    departure: Optional[str] = Field(None, max_length=255)
    arrival: Optional[str] = Field(None, max_length=255)

