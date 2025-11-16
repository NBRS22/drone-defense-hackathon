class ZoneDeVol {
  final int? zoneId;
  final String nomZone;
  final String typeZone;
  final int risque;
  final String? restrictions;

  ZoneDeVol({
    this.zoneId,
    required this.nomZone,
    required this.typeZone,
    required this.risque,
    this.restrictions,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom_zone': nomZone,
      'type_zone': typeZone,
      'risque': risque,
      if (restrictions != null) 'restrictions': restrictions,
    };
  }

  factory ZoneDeVol.fromJson(Map<String, dynamic> json) {
    return ZoneDeVol(
      zoneId: json['zone_id'],
      nomZone: json['nom_zone'],
      typeZone: json['type_zone'],
      risque: json['risque'],
      restrictions: json['restrictions'],
    );
  }
}

enum TypeZone {
  urbaine('urbaine', 'Urbaine'),
  rurale('rurale', 'Rurale'),
  industrielle('industrielle', 'Industrielle'),
  residentielle('residentielle', 'Résidentielle'),
  commerciale('commerciale', 'Commerciale'),
  militaire('militaire', 'Militaire'),
  hopital('hopital', 'Hôpital');

  final String value;
  final String label;
  const TypeZone(this.value, this.label);
}