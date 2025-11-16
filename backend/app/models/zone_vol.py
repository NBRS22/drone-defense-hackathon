from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.orm import relationship
from app.database import Base
import enum


class TypeZone(str, enum.Enum):
    URBAINE = "urbaine"
    RURALE = "rurale"
    INDUSTRIELLE = "industrielle"
    RESIDENTIELLE = "residentielle"
    COMMERCIALE = "commerciale"
    MILITAIRE = "militaire"
    HOPITAL = "hopital"


class ZoneDeVol(Base):
    __tablename__ = "zones_de_vol"

    zone_id = Column(Integer, primary_key=True, index=True)
    nom_zone = Column(String(255), nullable=False)  # nom de la zone (ex: Zone A, Zone B)
    type_zone = Column(String(255), nullable=False)  # type de zone
    risque = Column(Integer, nullable=False)  # niveau de risque dans cette zone (échelle de 1 à 5)
    restrictions = Column(Text, nullable=True)  # détails sur les restrictions spécifiques à la zone

    # Relations
    missions = relationship("Mission", back_populates="zone")