class HistoriqueMission {
  final int? historiqueId;
  final int missionId;
  final int droneId;
  final DateTime date;
  final String? performance;
  final String? commentaires;

  HistoriqueMission({
    this.historiqueId,
    required this.missionId,
    required this.droneId,
    required this.date,
    this.performance,
    this.commentaires,
  });

  Map<String, dynamic> toJson() {
    return {
      'mission_id': missionId,
      'drone_id': droneId,
      'date': date.toIso8601String(),
      if (performance != null) 'performance': performance,
      if (commentaires != null) 'commentaires': commentaires,
    };
  }

  factory HistoriqueMission.fromJson(Map<String, dynamic> json) {
    return HistoriqueMission(
      historiqueId: json['historique_id'],
      missionId: json['mission_id'],
      droneId: json['drone_id'],
      date: DateTime.parse(json['date']),
      performance: json['performance'],
      commentaires: json['commentaires'],
    );
  }
}