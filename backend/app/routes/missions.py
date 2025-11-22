from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.mission import MissionCreate, MissionResponse, MissionUpdate
from app.models.mission import Mission
from datetime import datetime

router = APIRouter(prefix="/api/missions", tags=["missions"])


@router.post("/", response_model=MissionResponse, status_code=status.HTTP_201_CREATED)
def create_mission(mission: MissionCreate, db: Session = Depends(get_db)):
    """
    Créer une nouvelle mission
    """
    mission_data = mission.dict()
    
    # Ajouter des valeurs par défaut
    mission_data['drone_id'] = 'AUTO'  # Assignation automatique à implémenter
    if not mission_data.get('estimated_duration'):
        mission_data['estimated_duration'] = 30  # Durée par défaut
    
    db_mission = Mission(**mission_data)
    db.add(db_mission)
    db.commit()
    db.refresh(db_mission)
    
    return db_mission


@router.get("/", response_model=List[MissionResponse])
def get_missions(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Récupérer toutes les missions
    """
    missions = db.query(Mission).offset(skip).limit(limit).all()
    return missions


@router.get("/status/{status}", response_model=List[MissionResponse])
def get_missions_by_status(status: str, db: Session = Depends(get_db)):
    """
    Récupérer les missions par statut
    """
    missions = db.query(Mission).filter(Mission.status == status).all()
    return missions


@router.get("/category/{category}", response_model=List[MissionResponse])
def get_missions_by_category(category: str, db: Session = Depends(get_db)):
    """
    Récupérer les missions par catégorie
    """
    missions = db.query(Mission).filter(Mission.category == category).all()
    return missions


@router.get("/{mission_id}", response_model=MissionResponse)
def get_mission(mission_id: int, db: Session = Depends(get_db)):
    """
    Récupérer une mission spécifique par son ID
    """
    mission = db.query(Mission).filter(Mission.mission_id == mission_id).first()
    if mission is None:
        raise HTTPException(status_code=404, detail="Mission non trouvée")
    return mission


@router.patch("/{mission_id}", response_model=MissionResponse)
def update_mission(
    mission_id: int,
    mission_update: MissionUpdate,
    db: Session = Depends(get_db)
):
    """
    Mettre à jour une mission
    """
    db_mission = db.query(Mission).filter(Mission.mission_id == mission_id).first()
    if db_mission is None:
        raise HTTPException(status_code=404, detail="Mission non trouvée")
    
    update_data = mission_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_mission, field, value)
    
    db_mission.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(db_mission)
    return db_mission


@router.delete("/{mission_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_mission(mission_id: int, db: Session = Depends(get_db)):
    """
    Supprimer une mission
    """
    db_mission = db.query(Mission).filter(Mission.mission_id == mission_id).first()
    if db_mission is None:
        raise HTTPException(status_code=404, detail="Mission non trouvée")
    
    db.delete(db_mission)
    db.commit()
    return None

