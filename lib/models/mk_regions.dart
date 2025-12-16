import 'package:latlong2/latlong.dart';

class MkRegions {
  /// Official Macedonian region names (UI / dropdown)
  static const List<String> all = [
    "Скопски",
    "Пелагониски",
    "Полог",
    "Југозападен",
    "Југоисточен",
    "Вардарски",
    "Источен",
    "Североисточен",
  ];

  /// Canonical routing keys (Latin, lowercase, RabbitMQ-safe)
  static const Map<String, String> routing = {
    "Скопски": "skopje",
    "Пелагониски": "pelagoniski",
    "Полог": "polog",
    "Југозападен": "southwest",
    "Југоисточен": "southeast",
    "Вардарски": "vardar",
    "Источен": "east",
    "Североисточен": "northeast",
  };

  /// Region center coordinates for map markers
  static const Map<String, LatLng> centers = {
    "Скопски": LatLng(42.00, 21.43),
    "Пелагониски": LatLng(41.03, 21.34),
    "Полог": LatLng(41.95, 20.91),
    "Југозападен": LatLng(41.22, 20.85),
    "Југоисточен": LatLng(41.42, 22.61),
    "Вардарски": LatLng(41.43, 21.74),
    "Источен": LatLng(41.66, 22.45),
    "Североисточен": LatLng(42.15, 22.30),
  };

  /// Convert routing / API value → Macedonian display name
  static String toDisplay(String value) {
    return routing.entries
        .firstWhere(
          (e) => e.value == value.toLowerCase(),
      orElse: () => const MapEntry("", ""),
    )
        .key
        .isNotEmpty
        ? routing.entries
        .firstWhere((e) => e.value == value.toLowerCase())
        .key
        : value;
  }

  /// Get routing-safe region code (used for RabbitMQ)
  static String toRouting(String displayName) {
    return routing[displayName] ?? displayName.toLowerCase();
  }

  /// Get region center for map markers
  static LatLng? getCenter(String displayName) {
    return centers[displayName];
  }
}
