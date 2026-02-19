import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SwitchListTile(
          title: const Text(
            'Push Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Receive Amber Alert push notifications',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          value: _pushEnabled,
          onChanged: _setPush,
          activeColor: Colors.redAccent,
          tileColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
        ),

        const SizedBox(height: 12),

        SwitchListTile(
          title: const Text(
            'Location-based Alerts (30 km)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Notify only for alerts near your location',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          value: _geoEnabled,
          onChanged: _setGeo,
          activeColor: Colors.redAccent,
          tileColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
        ),

        const SizedBox(height: 20),

        if (user != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Logged in as",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email ?? "Unknown",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        ListTile(
          title: const Text(
            'App Version',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            '1.0.0',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

}