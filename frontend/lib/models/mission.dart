import 'package:flutter/material.dart';

enum TypeMateriel {
  pocheSang('poche_sang', 'Poche de sang'),
  defibrillateur('defibrillateur', 'Défibrillateur'),
  medicament('medicament', 'Médicament'),
  pieceMecanique('piece_mecanique', 'Pièce mécanique'),
  autre('autre', 'Autre');

  final String value;
  final String label;
  const TypeMateriel(this.value, this.label);
}

enum Urgence {
  critique('critique', 'Critique', Colors.red),
  elevee('elevee', 'Élevée', Colors.orange),
  normale('normale', 'Normale', Colors.green);

  final String value;
  final String label;
  final Color color;
  const Urgence(this.value, this.label, this.color);
}

class Mission {
  final int? id;
  final TypeMateriel typeMateriel;
  final Urgence urgence;
  final double poidsKg;
  final double latitudeDepart;
  final double longitudeDepart;
  final double latitudeArrivee;
  final double longitudeArrivee;
  final String? description;
  final String? destinataire;
  final String? telephoneContact;
  final String? statut;
  final int? droneId;

  Mission({
    this.id,
    required this.typeMateriel,
    required this.urgence,
    required this.poidsKg,
    required this.latitudeDepart,
    required this.longitudeDepart,
    required this.latitudeArrivee,
    required this.longitudeArrivee,
    this.description,
    this.destinataire,
    this.telephoneContact,
    this.statut,
    this.droneId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type_materiel': typeMateriel.value,
      'urgence': urgence.value,
      'poids_kg': poidsKg,
      'latitude_depart': latitudeDepart,
      'longitude_depart': longitudeDepart,
      'latitude_arrivee': latitudeArrivee,
      'longitude_arrivee': longitudeArrivee,
      if (description != null) 'description': description,
      if (destinataire != null) 'destinataire': destinataire,
      if (telephoneContact != null) 'telephone_contact': telephoneContact,
    };
  }

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      typeMateriel: TypeMateriel.values.firstWhere(
        (e) => e.value == json['type_materiel'],
        orElse: () => TypeMateriel.autre,
      ),
      urgence: Urgence.values.firstWhere(
        (e) => e.value == json['urgence'],
        orElse: () => Urgence.normale,
      ),
      poidsKg: (json['poids_kg'] as num).toDouble(),
      latitudeDepart: (json['latitude_depart'] as num).toDouble(),
      longitudeDepart: (json['longitude_depart'] as num).toDouble(),
      latitudeArrivee: (json['latitude_arrivee'] as num).toDouble(),
      longitudeArrivee: (json['longitude_arrivee'] as num).toDouble(),
      description: json['description'],
      destinataire: json['destinataire'],
      telephoneContact: json['telephone_contact'],
      statut: json['statut'],
      droneId: json['drone_id'],
    );
  }
}

