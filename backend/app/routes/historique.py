from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.historique import HistoriqueMissionCreate, HistoriqueMissionResponse, HistoriqueMissionUpdate
from app.models.historique import HistoriqueMission

router = APIRouter(prefix="/api/historique", tags=["historique"])


@router.post("/", response_model=HistoriqueMissionResponse, status_code=status.HTTP_201_CREATED)
def create_historique(historique: HistoriqueMissionCreate, db: Session = Depends(get_db)):
    """
    Créer un nouvel enregistrement d'historique
    """
    db_historique = HistoriqueMission(**historique.dict())
    db.add(db_historique)
    db.commit()
    db.refresh(db_historique)
    return db_historique


@router.get("/", response_model=List[HistoriqueMissionResponse])
def get_historique(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Récupérer l'historique des missions
    """
    historique = db.query(HistoriqueMission).offset(skip).limit(limit).all()
    return historique


@router.get("/mission/{mission_id}", response_model=List[HistoriqueMissionResponse])
def get_historique_by_mission(mission_id: int, db: Session = Depends(get_db)):
    """
    Récupérer l'historique d'une mission spécifique
    """
    historique = db.query(HistoriqueMission).filter(HistoriqueMission.mission_id == mission_id).all()
    return historique


@router.get("/drone/{drone_id}", response_model=List[HistoriqueMissionResponse])
def get_historique_by_drone(drone_id: int, db: Session = Depends(get_db)):
    """
    Récupérer l'historique d'un drone spécifique
    """
    historique = db.query(HistoriqueMission).filter(HistoriqueMission.drone_id == drone_id).all()
    return historique


@router.get("/{historique_id}", response_model=HistoriqueMissionResponse)
def get_historique_entry(historique_id: int, db: Session = Depends(get_db)):
    """
    Récupérer un enregistrement d'historique spécifique
    """
    historique = db.query(HistoriqueMission).filter(HistoriqueMission.historique_id == historique_id).first()
    if historique is None:
        raise HTTPException(status_code=404, detail="Enregistrement d'historique non trouvé")
    return historique


@router.patch("/{historique_id}", response_model=HistoriqueMissionResponse)
def update_historique(
    historique_id: int,
    historique_update: HistoriqueMissionUpdate,
    db: Session = Depends(get_db)
):
    """
    Mettre à jour un enregistrement d'historique
    """
    db_historique = db.query(HistoriqueMission).filter(HistoriqueMission.historique_id == historique_id).first()
    if db_historique is None:
        raise HTTPException(status_code=404, detail="Enregistrement d'historique non trouvé")
    
    update_data = historique_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_historique, field, value)
    
    db.commit()
    db.refresh(db_historique)
    return db_historique


@router.delete("/{historique_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_historique(historique_id: int, db: Session = Depends(get_db)):
    """
    Supprimer un enregistrement d'historique
    """
    db_historique = db.query(HistoriqueMission).filter(HistoriqueMission.historique_id == historique_id).first()
    if db_historique is None:
        raise HTTPException(status_code=404, detail="Enregistrement d'historique non trouvé")
    
    db.delete(db_historique)
    db.commit()
    return None