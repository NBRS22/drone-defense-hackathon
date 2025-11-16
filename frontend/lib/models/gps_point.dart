class GpsPoint {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final GpsPointType type;

  const GpsPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.type,
  });
}

enum GpsPointType {
  hospital('Hôpital'),
  pharmacy('Pharmacie'),
  fireStation('Caserne de Pompiers'),
  policeStation('Commissariat'),
  airport('Aéroport'),
  warehouse('Entrepôt'),
  custom('Point Personnalisé');

  final String label;
  const GpsPointType(this.label);
}

class PredefinedGpsPoints {
  static const List<GpsPoint> points = [
    // Hôpitaux
    GpsPoint(
      id: 'hopital_cochin',
      name: 'Hôpital Cochin',
      description: 'Centre hospitalier universitaire',
      latitude: 48.8416,
      longitude: 2.3388,
      type: GpsPointType.hospital,
    ),
    GpsPoint(
      id: 'hopital_pitie',
      name: 'Hôpital Pitié-Salpêtrière',
      description: 'CHU Pitié-Salpêtrière',
      latitude: 48.8317,
      longitude: 2.3603,
      type: GpsPointType.hospital,
    ),
    GpsPoint(
      id: 'hopital_saint_louis',
      name: 'Hôpital Saint-Louis',
      description: 'Hôpital Saint-Louis',
      latitude: 48.8729,
      longitude: 2.3688,
      type: GpsPointType.hospital,
    ),
    
    // Pharmacies
    GpsPoint(
      id: 'pharmacie_champs_elysees',
      name: 'Pharmacie des Champs-Élysées',
      description: 'Pharmacie 24h/24',
      latitude: 48.8738,
      longitude: 2.2950,
      type: GpsPointType.pharmacy,
    ),
    GpsPoint(
      id: 'pharmacie_republique',
      name: 'Pharmacie République',
      description: 'Pharmacie de garde',
      latitude: 48.8676,
      longitude: 2.3632,
      type: GpsPointType.pharmacy,
    ),
    
    // Casernes de pompiers
    GpsPoint(
      id: 'pompiers_louvre',
      name: 'Caserne du Louvre',
      description: 'Brigade de sapeurs-pompiers',
      latitude: 48.8606,
      longitude: 2.3376,
      type: GpsPointType.fireStation,
    ),
    GpsPoint(
      id: 'pompiers_bastille',
      name: 'Caserne Bastille',
      description: 'Centre de secours',
      latitude: 48.8532,
      longitude: 2.3692,
      type: GpsPointType.fireStation,
    ),
    
    // Commissariats
    GpsPoint(
      id: 'police_chatelet',
      name: 'Commissariat Châtelet',
      description: 'Commissariat central',
      latitude: 48.8583,
      longitude: 2.3472,
      type: GpsPointType.policeStation,
    ),
    
    // Aéroports et zones logistiques
    GpsPoint(
      id: 'heliport_paris',
      name: 'Héliport de Paris',
      description: 'Base de départ drone',
      latitude: 48.8458,
      longitude: 2.2781,
      type: GpsPointType.airport,
    ),
    GpsPoint(
      id: 'entrepot_rungis',
      name: 'Entrepôt Médical Rungis',
      description: 'Stock matériel médical',
      latitude: 48.7589,
      longitude: 2.3522,
      type: GpsPointType.warehouse,
    ),
  ];

  static List<GpsPoint> getPointsByType(GpsPointType type) {
    return points.where((point) => point.type == type).toList();
  }

  static GpsPoint? getPointById(String id) {
    try {
      return points.firstWhere((point) => point.id == id);
    } catch (e) {
      return null;
    }
  }
}