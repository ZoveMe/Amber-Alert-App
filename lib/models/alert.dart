
class Alert {
  final String alertId;
  final String region;
  final String city;
  final double lat;
  final double lng;
  final String description;
  final String priority; // "high" | "medium" | "low"
  final DateTime createdAt;

  Alert({
    required this.alertId,
    required this.region,
    required this.city,
    required this.lat,
    required this.lng,
    required this.description,
    required this.priority,
    required this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      alertId: json['alertId'] ?? '',
      region: json['region'] ?? '',
      city: json['city'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'low',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertId': alertId,
      'region': region,
      'city': city,
      'lat': lat,
      'lng': lng,
      'description': description,
      'priority': priority,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
