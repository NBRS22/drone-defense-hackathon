from pydantic import BaseModel, Field, validator
from typing import Optional
from app.models.drone import StatutDrone


class DroneBase(BaseModel):
    nom: str = Field(..., max_length=255, description="Nom du drone")
    poids_max: float = Field(..., gt=0, description="Capacité de charge en kg")
    autonomie_max: float = Field(..., gt=0, description="Autonomie maximale en km")
    vitesse_max: float = Field(..., gt=0, description="Vitesse maximale en km/h")
    niveau_securite: int = Field(..., ge=1, le=5, description="Niveau de sécurité (1-5)")
    zone_vol_autorisee: Optional[str] = Field(None, max_length=255, description="Zones où le drone peut voler")


class DroneCreate(DroneBase):
    statut: Optional[StatutDrone] = StatutDrone.DISPONIBLE


class DroneResponse(DroneBase):
    drone_id: int
    statut: str

    class Config:
        from_attributes = True


class DroneUpdate(BaseModel):
    nom: Optional[str] = Field(None, max_length=255)
    poids_max: Optional[float] = Field(None, gt=0)
    autonomie_max: Optional[float] = Field(None, gt=0)
    vitesse_max: Optional[float] = Field(None, gt=0)
    niveau_securite: Optional[int] = Field(None, ge=1, le=5)
    statut: Optional[StatutDrone] = None
    zone_vol_autorisee: Optional[str] = Field(None, max_length=255)