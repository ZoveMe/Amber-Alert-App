import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/alert.dart';

class ApiService {
  // TODO: change this to your real backend URL
  static const String baseUrl = 'https://example.com';

  static Future<List<Alert>> fetchAlerts() async {
    try {
      final uri = Uri.parse('$baseUrl/api/alerts');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final alerts = data.map((e) => Alert.fromJson(e)).toList();

        // cache in Hive
        final box = Hive.box('alertsCache');
        box.put('alerts', alerts.map((a) => a.toJson()).toList());

        return alerts;
      } else {
        // fallback to cache or static
        return _loadFromCacheOrSample();
      }
    } catch (_) {
      return _loadFromCacheOrSample();
    }
  }

  static List<Alert> _sampleAlerts() {
    return [
      Alert(
        alertId: "ALR-2025-001",
        region: "central",
        city: "Skopje",
        lat: 41.9965,
        lng: 21.4314,
        description: "Child missing near City Park",
        priority: "high",
        createdAt: DateTime.parse("2025-11-27T10:15:00Z"),
      ),
      Alert(
        alertId: "ALR-2025-002",
        region: "south",
        city: "Bitola",
        lat: 41.0328,
        lng: 21.3403,
        description: "Elderly person missing from hospital",
        priority: "high",
        createdAt: DateTime.parse("2025-11-26T08:30:00Z"),
      ),
      Alert(
        alertId: "ALR-2025-003",
        region: "north",
        city: "Tetovo",
        lat: 42.0086,
        lng: 20.9716,
        description: "Missing adult last seen at bus station",
        priority: "medium",
        createdAt: DateTime.parse("2025-11-25T17:45:00Z"),
      ),
      Alert(
        alertId: "ALR-2025-004",
        region: "west",
        city: "Ohrid",
        lat: 41.1172,
        lng: 20.8016,
        description: "Test alert for system check",
        priority: "low",
        createdAt: DateTime.parse("2025-11-24T12:00:00Z"),
      ),
    ];
  }

  static Future<List<Alert>> _loadFromCacheOrSample() async {
    final box = Hive.box('alertsCache');
    if (box.containsKey('alerts')) {
      final List list = box.get('alerts');
      return list
          .map((e) => Alert.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return _sampleAlerts();
  }
}
