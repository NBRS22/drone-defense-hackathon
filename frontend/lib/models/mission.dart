import 'package:flutter/material.dart';

enum TypeCargaison {
  pocheSang('poche_sang', 'Poche de sang'),
  defibrillateur('defibrillateur', 'Défibrillateur'),
  medicament('medicament', 'Médicament'),
  pieceMecanique('piece_mecanique', 'Pièce mécanique'),
  fragile('fragile', 'Fragile'),
  perissable('perissable', 'Périssable'),
  autre('autre', 'Autre');

  final String value;
  final String label;
  const TypeCargaison(this.value, this.label);
}

enum StatutMission {
  enAttente('en_attente', 'En attente', Colors.orange),
  enCours('en_cours', 'En cours', Colors.blue),
  terminee('terminee', 'Terminée', Colors.green),
  annulee('annulee', 'Annulée', Colors.red),
  echec('echec', 'Échec', Colors.red);

  final String value;
  final String label;
  final Color color;
  const StatutMission(this.value, this.label, this.color);
}

class Mission {
  final int? missionId;
  final double poids;
  final double? distance;
  final int risque;
  final String? typeCargaison;
  final String statut;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final int? droneId;
  final int? zoneId;
  final double latitudeDepart;
  final double longitudeDepart;
  final double latitudeArrivee;
  final double longitudeArrivee;
  final String? description;
  final String? destinataire;
  final String? telephoneContact;
  final DateTime? dateCreation;

  Mission({
    this.missionId,
    required this.poids,
    this.distance,
    required this.risque,
    this.typeCargaison,
    required this.statut,
    this.dateDebut,
    this.dateFin,
    this.droneId,
    this.zoneId,
    required this.latitudeDepart,
    required this.longitudeDepart,
    required this.latitudeArrivee,
    required this.longitudeArrivee,
    this.description,
    this.destinataire,
    this.telephoneContact,
    this.dateCreation,
  });

  Map<String, dynamic> toJson() {
    return {
      'poids': poids,
      'risque': risque,
      'latitude_depart': latitudeDepart,
      'longitude_depart': longitudeDepart,
      'latitude_arrivee': latitudeArrivee,
      'longitude_arrivee': longitudeArrivee,
      if (typeCargaison != null) 'type_cargaison': typeCargaison,
      if (description != null) 'description': description,
      if (destinataire != null) 'destinataire': destinataire,
      if (telephoneContact != null) 'telephone_contact': telephoneContact,
      if (zoneId != null) 'zone_id': zoneId,
    };
  }

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      missionId: json['mission_id'],
      poids: (json['poids'] as num).toDouble(),
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      risque: json['risque'],
      typeCargaison: json['type_cargaison'],
      statut: json['statut'],
      dateDebut: json['date_debut'] != null ? DateTime.parse(json['date_debut']) : null,
      dateFin: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
      droneId: json['drone_id'],
      zoneId: json['zone_id'],
      latitudeDepart: (json['latitude_depart'] as num).toDouble(),
      longitudeDepart: (json['longitude_depart'] as num).toDouble(),
      latitudeArrivee: (json['latitude_arrivee'] as num).toDouble(),
      longitudeArrivee: (json['longitude_arrivee'] as num).toDouble(),
      description: json['description'],
      destinataire: json['destinataire'],
      telephoneContact: json['telephone_contact'],
      dateCreation: json['date_creation'] != null ? DateTime.parse(json['date_creation']) : null,
    );
  }
}

