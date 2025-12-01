import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';
import '../models/alert.dart';

class MapScreen extends StatefulWidget {
  final List<Alert> alerts;
  const MapScreen({super.key, required this.alerts});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final GeoJsonParser _geoJsonParser = GeoJsonParser();
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBorder();
  }

  Future<void> _loadBorder() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/macedonia_border.geojson');
    _geoJsonParser.parseGeoJsonAsString(data);
    setState(() => _loading = false);
  }

  Color _markerColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE74C3C); // red
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  void _zoomIn() =>
      _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 0.5);

  void _zoomOut() =>
      _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 0.5);

  @override
  Widget build(BuildContext context) {
    final markers = widget.alerts.map((alert) {
      final color = _markerColor(alert.priority);
      return Marker(
        point: LatLng(alert.lat, alert.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showAlertDetails(alert, color),
          child: Icon(Icons.location_pin, color: color, size: 36),
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
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
              userAgentPackageName: 'amber.alert.macedonia',
            ),
            if (!_loading)
              PolygonLayer(
                polygons: _geoJsonParser.polygons
                    .map((p) => Polygon(
                  points: p.points,
                  color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                  borderColor: Colors.orangeAccent,
                  borderStrokeWidth: 2,
                ))
                    .toList(),
              ),
            MarkerLayer(markers: markers),
          ],
        ),
        Positioned(
          right: 10,
          bottom: 100,
          child: Column(
            children: [
              _zoomButton(Icons.add, _zoomIn),
              const SizedBox(height: 8),
              _zoomButton(Icons.remove, _zoomOut),
            ],
          ),
        ),
      ]
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      heroTag: icon.codePoint,
      mini: true,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      child: Icon(icon, color: Colors.black87),
    );
  }

  void _showAlertDetails(Alert alert, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${alert.city}, ${alert.region.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(alert.description),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.priority_high, color: color),
              const SizedBox(width: 4),
              Text('Priority: ${alert.priority}'),
            ]),
            const SizedBox(height: 4),
            Text('Posted: ${alert.createdAt.toLocal()}'),
          ],
        ),
      ),
    );
  }
}
