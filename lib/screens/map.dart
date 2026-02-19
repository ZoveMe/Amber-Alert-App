import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/alert.dart';
import '../models/mk_regions.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  final List<Alert> alerts;
  const MapScreen({super.key, required this.alerts});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  List<Polygon> _regionPolygons = [];
  List<Marker> _regionCenters = []; // person icons
  List<String> _regionNames = [];

  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRegions();
  }

  /// Load GeoJSON → create polygons + centroid markers
  Future<void> _loadRegions() async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/macedonia_regions.geojson');

    final map = jsonDecode(jsonString);
    final features = map["features"] as List;

    List<Polygon> polygons = [];
    List<Marker> centers = [];
    List<String> names = [];

    for (final feature in features) {
      final props = feature["properties"];
      final name = props?["name"] ?? "Unknown Region";
      names.add(name);

      final geometry = feature["geometry"];
      final coords = geometry["coordinates"][0] as List;

      // Convert to LatLng points
      final points = coords
          .map((c) => LatLng(
        (c[1] as num).toDouble(),
        (c[0] as num).toDouble(),
      ))
          .toList();

      polygons.add(
        Polygon(
          points: points,
          borderColor: Colors.orangeAccent,
          borderStrokeWidth: 2,
          color: const Color(0xFFFFB300).withOpacity(0.25),
        ),
      );

      // --- Calculate centroid ---
      double lat = 0, lng = 0;
      for (final p in points) {
        lat += p.latitude;
        lng += p.longitude;
      }
      lat /= points.length;
      lng /= points.length;

      // Region center marker (person icon)
      centers.add(
        Marker(
          width: 45,
          height: 45,
          point: LatLng(lat, lng),
          child: GestureDetector(
            onTap: () => _showRegionAlerts(name),
            child: const Icon(
              Icons.person_pin_circle,
              size: 40,
              color: Colors.blueAccent,
            ),
          ),
        ),
      );
    }

    setState(() {
      _regionPolygons = polygons;
      _regionCenters = centers;
      _regionNames = names;
      _loading = false;
    });
  }

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertMarkers = widget.alerts.map((alert) {
      return Marker(
        width: 40,
        height: 40,
        point: LatLng(alert.lat, alert.lng),
        child: GestureDetector(
          onTap: () => _showAlertDetails(alert),
          child: Icon(
            Icons.location_on,
            size: 36,
            color: _priorityColor(alert.priority),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
      FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(41.6, 21.7),
        initialZoom: 7,
        maxZoom: 18,
      ),
      children: [
        // OSM background
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.amber.alert.macedonia',

        ),

        // REMOVE POLYGONS (NO ORANGE RECTANGLES)

        // Region center person icons
        if (!_loading) MarkerLayer(markers: _regionCenters),

        // Alerts (red/orange/green pins)
        MarkerLayer(markers: alertMarkers),
      ],
    ),

    ],
    );
  }

  // ------------------------ UI HANDLERS -------------------------

  /// Show alerts for that region
  void _showRegionAlerts(String regionName) {
    final normalized = MkRegions.toDisplay(regionName);


    final regionAlerts = widget.alerts
        .where((a) => MkRegions.toDisplay(a.region ?? "") == normalized)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: regionAlerts.isEmpty
            ? Text("No active alerts in $normalized",
            style: const TextStyle(color: Colors.white70, fontSize: 16))
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$normalized Region Alerts",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...regionAlerts.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "${a.name} — ${a.description}",
                style: const TextStyle(color: Colors.white70),
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Show a single alert popup
  void _showAlertDetails(Alert alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${alert.name}, ${MkRegions.toDisplay(alert.region ?? '')}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(alert.description,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.priority_high, color: _priorityColor(alert.priority)),
                const SizedBox(width: 8),
                Text("Priority: ${alert.priority}",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Posted: ${alert.createdAt.toLocal()}",
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
