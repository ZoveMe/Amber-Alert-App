class Alert {
  final String alertId;
  final String region;
  final String city;
  final double lat;
  final double lng;
  final String description;
  /// Allowed values: "high" | "medium" | "low"
  final String priority;
  final DateTime createdAt;

  const Alert({
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
      alertId: json['alertId'] as String? ?? '',
      region: json['region'] as String? ?? '',
      city: json['city'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      priority: (json['priority'] as String?)?.toLowerCase() ?? 'low',
      createdAt: DateTime.parse(json['createdAt'] as String),
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

  Alert copyWith({
    String? alertId,
    String? region,
    String? city,
    double? lat,
    double? lng,
    String? description,
    String? priority,
    DateTime? createdAt,
  }) {
    return Alert(
      alertId: alertId ?? this.alertId,
      region: region ?? this.region,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
