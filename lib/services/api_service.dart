import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/alert.dart';

class ApiService {
  // Placeholder backend (not used yet)
  static const String baseUrl = 'https://example.com';

  /// 🔴 WILL SEND TO RABBITMQ (next step)
  static Future<void> publishAlert(Alert alert) async {
    // For now just log – we will replace this with RabbitMQ HTTP API
    print('Publishing alert: ${alert.toJson()}');
  }

  /// 🔵 Fetch alerts (HTTP → cache → sample)
  static Future<List<Alert>> fetchAlerts() async {
    try {
      final uri = Uri.parse('$baseUrl/api/alerts');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final alerts = data.map((e) => Alert.fromJson(e)).toList();

        // Cache in Hive
        final box = Hive.box('alertsCache');
        box.put('alerts', alerts.map((a) => a.toJson()).toList());

        return alerts;
      } else {
        return _loadFromCacheOrSample();
      }
    } catch (_) {
      return _loadFromCacheOrSample();
    }
  }

  /// 🧪 Sample data (offline fallback)
  static List<Alert> _sampleAlerts() {
    return [
      Alert(
        alertId: "ALR-2025-001",
        region: "skopje",
        name: "Unknown child",
        lat: 41.9965,
        lng: 21.4314,
        description: "Child missing near City Park",
        priority: "high",
        createdAt: DateTime.parse("2025-11-27T10:15:00Z"),

      ),
    ];
  }

  /// 💾 Cache fallback
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
