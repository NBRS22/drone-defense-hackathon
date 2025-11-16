class Drone {
  final int? droneId;
  final String nom;
  final double poidsMax;
  final double autonomieMax;
  final double vitesseMax;
  final int niveauSecurite;
  final String statut;
  final String? zoneVolAutorisee;

  Drone({
    this.droneId,
    required this.nom,
    required this.poidsMax,
    required this.autonomieMax,
    required this.vitesseMax,
    required this.niveauSecurite,
    required this.statut,
    this.zoneVolAutorisee,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'poids_max': poidsMax,
      'autonomie_max': autonomieMax,
      'vitesse_max': vitesseMax,
      'niveau_securite': niveauSecurite,
      'statut': statut,
      if (zoneVolAutorisee != null) 'zone_vol_autorisee': zoneVolAutorisee,
    };
  }

  factory Drone.fromJson(Map<String, dynamic> json) {
    return Drone(
      droneId: json['drone_id'],
      nom: json['nom'],
      poidsMax: (json['poids_max'] as num).toDouble(),
      autonomieMax: (json['autonomie_max'] as num).toDouble(),
      vitesseMax: (json['vitesse_max'] as num).toDouble(),
      niveauSecurite: json['niveau_securite'],
      statut: json['statut'],
      zoneVolAutorisee: json['zone_vol_autorisee'],
    );
  }
}

enum StatutDrone {
  disponible('disponible', 'Disponible'),
  enMission('en_mission', 'En mission'),
  enMaintenance('en_maintenance', 'En maintenance'),
  horsService('hors_service', 'Hors service');

  final String value;
  final String label;
  const StatutDrone(this.value, this.label);
}