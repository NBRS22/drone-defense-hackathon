from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.zone_vol import ZoneDeVolCreate, ZoneDeVolResponse, ZoneDeVolUpdate
from app.models.zone_vol import ZoneDeVol

router = APIRouter(prefix="/api/zones", tags=["zones"])


@router.post("/", response_model=ZoneDeVolResponse, status_code=status.HTTP_201_CREATED)
def create_zone(zone: ZoneDeVolCreate, db: Session = Depends(get_db)):
    """
    Créer une nouvelle zone de vol
    """
    db_zone = ZoneDeVol(**zone.dict())
    db.add(db_zone)
    db.commit()
    db.refresh(db_zone)
    return db_zone


@router.get("/", response_model=List[ZoneDeVolResponse])
def get_zones(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Récupérer toutes les zones de vol
    """
    zones = db.query(ZoneDeVol).offset(skip).limit(limit).all()
    return zones


@router.get("/risque/{niveau_risque}", response_model=List[ZoneDeVolResponse])
def get_zones_by_risk(niveau_risque: int, db: Session = Depends(get_db)):
    """
    Récupérer les zones par niveau de risque
    """
    if niveau_risque < 1 or niveau_risque > 5:
        raise HTTPException(status_code=400, detail="Le niveau de risque doit être entre 1 et 5")
    
    zones = db.query(ZoneDeVol).filter(ZoneDeVol.risque == niveau_risque).all()
    return zones


@router.get("/{zone_id}", response_model=ZoneDeVolResponse)
def get_zone(zone_id: int, db: Session = Depends(get_db)):
    """
    Récupérer une zone spécifique par son ID
    """
    zone = db.query(ZoneDeVol).filter(ZoneDeVol.zone_id == zone_id).first()
    if zone is None:
        raise HTTPException(status_code=404, detail="Zone non trouvée")
    return zone


@router.patch("/{zone_id}", response_model=ZoneDeVolResponse)
def update_zone(
    zone_id: int,
    zone_update: ZoneDeVolUpdate,
    db: Session = Depends(get_db)
):
    """
    Mettre à jour une zone de vol
    """
    db_zone = db.query(ZoneDeVol).filter(ZoneDeVol.zone_id == zone_id).first()
    if db_zone is None:
        raise HTTPException(status_code=404, detail="Zone non trouvée")
    
    update_data = zone_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_zone, field, value)
    
    db.commit()
    db.refresh(db_zone)
    return db_zone


@router.delete("/{zone_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_zone(zone_id: int, db: Session = Depends(get_db)):
    """
    Supprimer une zone de vol
    """
    db_zone = db.query(ZoneDeVol).filter(ZoneDeVol.zone_id == zone_id).first()
    if db_zone is None:
        raise HTTPException(status_code=404, detail="Zone non trouvée")
    
    db.delete(db_zone)
    db.commit()
    return None