import 'package:latlong2/latlong.dart';

class MkRegions {
  /// Official region names in Macedonian
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

  /// Converts API region names → Macedonian display names
  static String displayName(String region) {
    switch (region.toLowerCase()) {
      case "skopje":
      case "skopski":
        return "Скопски";

      case "pelagonija":
      case "pelagoniski":
        return "Пелагониски";

      case "polog":
        return "Полог";

      case "jugozapaden":
        return "Југозападен";

      case "jugoistocen":
        return "Југоисточен";

      case "vardarski":
        return "Вардарски";

      case "istocen":
      case "istočen":
        return "Источен";

      case "severoistocen":
        return "Североисточен";

      default:
        return region;
    }
  }

  /// Returns region center for map marker
  static LatLng? getCenter(String region) {
    final display = displayName(region);
    return centers[display];
  }
}
