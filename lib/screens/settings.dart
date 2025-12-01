import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _geoEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushEnabled = prefs.getBool('pushEnabled') ?? true;
      _geoEnabled = prefs.getBool('geoEnabled') ?? false;
    });
  }

  Future<void> _setPush(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushEnabled', value);
    setState(() => _pushEnabled = value);

    // Here you could subscribe/unsubscribe from FCM topics
  }

  Future<void> _setGeo(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('geoEnabled', value);
    setState(() => _geoEnabled = value);

    // Here you would enable/disable geofencing logic
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive Amber Alert push notifications'),
          value: _pushEnabled,
          onChanged: _setPush,
        ),
        SwitchListTile(
          title: const Text('Location-based Alerts (30 km)'),
          subtitle: const Text('Notify only for alerts near your location'),
          value: _geoEnabled,
          onChanged: _setGeo,
        ),
        const ListTile(
          title: Text('App Version'),
          subtitle: Text('1.0.0'),
        ),
      ],
    );
  }
}
