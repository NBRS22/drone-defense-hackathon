import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mission.dart';

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
}

