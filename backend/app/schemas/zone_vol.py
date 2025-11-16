from pydantic import BaseModel, Field, validator
from typing import Optional
from app.models.zone_vol import TypeZone


class ZoneDeVolBase(BaseModel):
    nom_zone: str = Field(..., max_length=255, description="Nom de la zone")
    type_zone: str = Field(..., max_length=255, description="Type de zone")
    risque: int = Field(..., ge=1, le=5, description="Niveau de risque (1-5)")
    restrictions: Optional[str] = Field(None, description="Restrictions spécifiques à la zone")


class ZoneDeVolCreate(ZoneDeVolBase):
    pass


class ZoneDeVolResponse(ZoneDeVolBase):
    zone_id: int

    class Config:
        from_attributes = True


class ZoneDeVolUpdate(BaseModel):
    nom_zone: Optional[str] = Field(None, max_length=255)
    type_zone: Optional[str] = Field(None, max_length=255)
    risque: Optional[int] = Field(None, ge=1, le=5)
    restrictions: Optional[str] = None