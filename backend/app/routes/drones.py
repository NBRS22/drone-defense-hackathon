from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.schemas.drone import DroneCreate, DroneResponse, DroneUpdate
from app.models.drone import Drone
from datetime import datetime

router = APIRouter(prefix="/api/drones", tags=["drones"])


@router.post("/", response_model=DroneResponse, status_code=status.HTTP_201_CREATED)
def create_drone(drone: DroneCreate, db: Session = Depends(get_db)):
    """
    Créer un nouveau drone
    """
    db_drone = Drone(**drone.dict())
    db.add(db_drone)
    db.commit()
    db.refresh(db_drone)
    return db_drone


@router.get("/", response_model=List[DroneResponse])
def get_drones(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Récupérer tous les drones
    """
    drones = db.query(Drone).offset(skip).limit(limit).all()
    return drones


@router.get("/disponibles", response_model=List[DroneResponse])
def get_available_drones(db: Session = Depends(get_db)):
    """
    Récupérer tous les drones disponibles
    """
    drones = db.query(Drone).filter(Drone.statut == "disponible").all()
    return drones


@router.get("/{drone_id}", response_model=DroneResponse)
def get_drone(drone_id: int, db: Session = Depends(get_db)):
    """
    Récupérer un drone spécifique par son ID
    """
    drone = db.query(Drone).filter(Drone.drone_id == drone_id).first()
    if drone is None:
        raise HTTPException(status_code=404, detail="Drone non trouvé")
    return drone


@router.patch("/{drone_id}", response_model=DroneResponse)
def update_drone(
    drone_id: int,
    drone_update: DroneUpdate,
    db: Session = Depends(get_db)
):
    """
    Mettre à jour un drone
    """
    db_drone = db.query(Drone).filter(Drone.drone_id == drone_id).first()
    if db_drone is None:
        raise HTTPException(status_code=404, detail="Drone non trouvé")
    
    update_data = drone_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_drone, field, value)
    
    db.commit()
    db.refresh(db_drone)
    return db_drone


@router.delete("/{drone_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_drone(drone_id: int, db: Session = Depends(get_db)):
    """
    Supprimer un drone
    """
    db_drone = db.query(Drone).filter(Drone.drone_id == drone_id).first()
    if db_drone is None:
        raise HTTPException(status_code=404, detail="Drone non trouvé")
    
    db.delete(db_drone)
    db.commit()
    return None