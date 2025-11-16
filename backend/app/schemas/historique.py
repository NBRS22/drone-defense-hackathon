from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class HistoriqueMissionBase(BaseModel):
    mission_id: int = Field(..., description="ID de la mission")
    drone_id: int = Field(..., description="ID du drone utilisé")
    performance: Optional[str] = Field(None, max_length=255, description="Performance de la mission")
    commentaires: Optional[str] = Field(None, description="Commentaires sur la mission")


class HistoriqueMissionCreate(HistoriqueMissionBase):
    pass


class HistoriqueMissionResponse(HistoriqueMissionBase):
    historique_id: int
    date: datetime

    class Config:
        from_attributes = True


class HistoriqueMissionUpdate(BaseModel):
    performance: Optional[str] = Field(None, max_length=255)
    commentaires: Optional[str] = None