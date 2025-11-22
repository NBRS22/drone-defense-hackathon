import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mission.dart';
import '../models/drone.dart';
import '../models/zone_vol.dart';
import '../models/historique.dart';

class ApiService {
  // Détection automatique de l'URL selon la plateforme
  static String get baseUrl {
    if (kIsWeb) {
      // Web (Chrome) : utiliser localhost
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      // Android Emulator : utiliser 10.0.2.2
      // Pour un appareil physique Android, modifiez ci-dessous avec votre IP locale
      // Exemple : return 'http://192.168.0.26:8000';
      return 'http://10.0.2.2:8000';
    } else if (Platform.isWindows) {
      // Desktop Windows : utiliser localhost
      return 'http://localhost:8000';
    } else {
      // Par défaut (devrait être Windows ou Web)
      return 'http://localhost:8000';
    }
  }
  
  // Pour un appareil physique Android, modifiez la ligne Platform.isAndroid ci-dessus
  // avec votre IP locale (ex: 192.168.0.26)

  // === MISSIONS ===
  Future<Mission> createMission(Mission mission) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/missions/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(mission.toJson()),
      );

      if (response.statusCode == 201) {
        return Mission.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Erreur lors de la création de la mission: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<List<Mission>> getMissions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/missions/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Mission.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des missions: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<Mission> getMission(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/missions/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Mission.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Erreur lors de la récupération de la mission: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<List<Mission>> getMissionsByStatus(String statut) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/missions/statut/$statut'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Mission.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des missions: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  // === DRONES ===
  Future<List<Drone>> getDrones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drones/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Drone.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des drones: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<List<Drone>> getAvailableDrones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/drones/disponibles'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Drone.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des drones disponibles: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<Drone> createDrone(Drone drone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/drones/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(drone.toJson()),
      );

      if (response.statusCode == 201) {
        return Drone.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Erreur lors de la création du drone: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  // === ZONES DE VOL ===
  Future<List<ZoneDeVol>> getZones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/zones/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ZoneDeVol.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération des zones: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<ZoneDeVol> createZone(ZoneDeVol zone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/zones/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(zone.toJson()),
      );

      if (response.statusCode == 201) {
        return ZoneDeVol.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Erreur lors de la création de la zone: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  // === HISTORIQUE ===
  Future<List<HistoriqueMission>> getHistorique() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/historique/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => HistoriqueMission.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération de l\'historique: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<Mission> updateMission(int id, Mission mission) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/missions/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(mission.toJson()),
      );

      if (response.statusCode == 200) {
        return Mission.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Erreur lors de la mise à jour de la mission: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<void> deleteMission(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/missions/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Erreur lors de la suppression de la mission: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }

  Future<List<HistoriqueMission>> getHistoriqueByDrone(int droneId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/historique/drone/$droneId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => HistoriqueMission.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur lors de la récupération de l\'historique: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion au serveur: $e');
    }
  }
}

