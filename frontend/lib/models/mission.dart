import 'package:flutter/material.dart';

enum MissionCategory {
  pochesSang('poches-sang', 'Poches de Sang', Color(0xFFDC2626), Icons.bloodtype),
  defibrillateur('defibrillateur', 'Défibrillateur', Color(0xFF2563EB), Icons.electric_bolt),
  piecesMecaniques('pieces-mecaniques', 'Pièces Mécaniques', Color(0xFF7C3AED), Icons.precision_manufacturing),
  medicaments('medicaments', 'Médicaments', Color(0xFF059669), Icons.medication),
  munitions('munitions', 'Munitions', Color(0xFF7C2D12), Icons.gps_fixed),
  nourriture('nourriture', 'Nourriture', Color(0xFFEA580C), Icons.restaurant),
  autres('autres', 'Autres', Color(0xFF6B7280), Icons.category);

  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const MissionCategory(this.value, this.label, this.color, this.icon);
}

enum Priority {
  low('low', 'Basse', Color(0xFF10B981)),
  medium('medium', 'Moyenne', Color(0xFF3B82F6)),
  high('high', 'Haute', Color(0xFFF97316)),
  critical('critical', 'Critique', Color(0xFFEF4444));

  final String value;
  final String label;
  final Color color;
  const Priority(this.value, this.label, this.color);
}

enum Risk {
  low('low', 'Faible', Color(0xFF10B981)),
  medium('medium', 'Moyen', Color(0xFFEAB308)),
  high('high', 'Élevé', Color(0xFFF97316)),
  critical('critical', 'Critique', Color(0xFFEF4444));

  final String value;
  final String label;
  final Color color;
  const Risk(this.value, this.label, this.color);
}

enum MissionStatus {
  pending('pending', 'En attente', Color(0xFFEAB308), Icons.pending_actions_rounded),
  inProgress('in-progress', 'En cours', Color(0xFF3B82F6), Icons.flight_rounded),
  completed('completed', 'Terminée', Color(0xFF10B981), Icons.check_circle_rounded),
  cancelled('cancelled', 'Annulée', Color(0xFF6B7280), Icons.cancel_rounded),
  failed('failed', 'Échouée', Color(0xFFEF4444), Icons.error_rounded);

  final String value;
  final String label;
  final Color color;
  final IconData iconData;
  const MissionStatus(this.value, this.label, this.color, this.iconData);
  
  IconData get icon => iconData;
}

class Mission {
  final int? missionId;
  final String title;
  final MissionCategory category;
  final String? droneId;
  final Priority priority;
  final MissionStatus status;
  final Risk risk;
  final String location;
  final String? description;
  final int? estimatedDuration;
  final double? weight;
  final DateTime? startDate;
  final String departure;
  final String arrival;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Mission({
    this.missionId,
    required this.title,
    required this.category,
    this.droneId,
    required this.priority,
    required this.status,
    required this.risk,
    required this.location,
    this.description,
    this.estimatedDuration,
    this.weight,
    this.startDate,
    required this.departure,
    required this.arrival,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category.value,
      'priority': priority.value,
      'risk': risk?.value,
      'location': location,
      if (description != null) 'description': description,
      if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
      if (weight != null) 'weight': weight,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (departure != null) 'departure': departure,
      if (arrival != null) 'arrival': arrival,
    };
  }

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      missionId: json['mission_id'],
      title: json['title'],
      category: MissionCategory.values.firstWhere(
        (c) => c.value == json['category'],
        orElse: () => MissionCategory.pochesSang,
      ),
      droneId: json['drone_id'],
      priority: Priority.values.firstWhere(
        (p) => p.value == json['priority'],
        orElse: () => Priority.medium,
      ),
      status: MissionStatus.values.firstWhere(
        (s) => s.value == json['status'],
        orElse: () => MissionStatus.pending,
      ),
      risk: json['risk'] != null
          ? Risk.values.firstWhere(
              (r) => r.value == json['risk'],
              orElse: () => Risk.low,
            )
          : Risk.low,
      location: json['location'],
      description: json['description'],
      estimatedDuration: json['estimated_duration'],
      weight: json['weight']?.toDouble(),
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      departure: json['departure'],
      arrival: json['arrival'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Mission copyWith({
    int? missionId,
    String? title,
    MissionCategory? category,
    String? droneId,
    Priority? priority,
    MissionStatus? status,
    Risk? risk,
    String? location,
    String? description,
    int? estimatedDuration,
    double? weight,
    DateTime? startDate,
    String? departure,
    String? arrival,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Mission(
      missionId: missionId ?? this.missionId,
      title: title ?? this.title,
      category: category ?? this.category,
      droneId: droneId ?? this.droneId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      risk: risk ?? this.risk,
      location: location ?? this.location,
      description: description ?? this.description,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      weight: weight ?? this.weight,
      startDate: startDate ?? this.startDate,
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

