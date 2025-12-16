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
          title: const Text('Push Notifications',style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),),
          subtitle: const Text('Receive Amber Alert push notifications',style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),),
          value: _pushEnabled,
          onChanged: _setPush,
          activeColor: Colors.redAccent,
          tileColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
        ),
        SwitchListTile(
          title: const Text('Location-based Alerts (30 km)',   style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),),
          subtitle: const Text('Notify only for alerts near your location',  style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),),
          value: _geoEnabled,
          onChanged: _setGeo,
          activeColor: Colors.redAccent,
          tileColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
        ),
        ListTile(
          title: const Text('App Version',style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),),
          subtitle: const Text('1.0.0',style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),),

        ),
      ],
    );
  }
}
