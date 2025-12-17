import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/alert.dart';
import '../services/api_service.dart';
import 'alerts.dart';
import 'map.dart';
import 'settings.dart';
import 'add_missing_person.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  int _currentIndex = 0;
  late Future<List<Alert>> _alertsFuture;

  // Glow animation
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _alertsFuture = ApiService.fetchAlerts();

    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      setState(() => _currentIndex = 1);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 25.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final pages = [
      _buildHomePage(),
      _buildAlertsPage(),
      _buildMapPage(),
      const SettingsScreen(),
      const AddMissingPersonScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (_, __) => Text(
            "Amber Alert Macedonia",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                  blurRadius: _glowAnimation.value,
                  color: Colors.redAccent.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ),
      ),

      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),

        backgroundColor: const Color(0xFF111111),
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white70,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Alerts"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  // -------------------------------
  // ALERTS PAGE
  // -------------------------------
  Widget _buildAlertsPage() {
    return FutureBuilder<List<Alert>>(
      future: _alertsFuture,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return AlertsScreen(alerts: snapshot.data!);
      },
    );
  }

  // -------------------------------
  // MAP PAGE
  // -------------------------------
  Widget _buildMapPage() {
    return FutureBuilder<List<Alert>>(
      future: _alertsFuture,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return MapScreen(alerts: snapshot.data!);
      },
    );
  }

  // -------------------------------
  // HOME PAGE UI
  // -------------------------------
  Widget _buildHomePage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xFF1A1A1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // LOGO WITH GLOW
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.8),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: _glowAnimation.value / 2,
                    ),
                  ],
                ),
                child: Image.asset('assets/logo.png', width: 160),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Real-time missing person alerts across North Macedonia.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 32),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _featureCard(Icons.list, "View Alerts", 1),
                _featureCard(Icons.map, "Open Map", 2),
                _featureCard(Icons.settings, "Settings", 3),
                _featureCard(Icons.person_add, "Report Missing", 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // FEATURE CARD BUTTON
  // -------------------------------
  Widget _featureCard(IconData icon, String title, int index) {
    return GestureDetector(
      onTap: () async {
        if (index == 4) {
          final newAlert = await Navigator.push<Alert>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMissingPersonScreen(),
            ),
          );

          if (newAlert != null) {
            setState(() {
              _alertsFuture = _alertsFuture.then(
                    (list) => [...list, newAlert],
              );
            });
          }
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(255, 82, 82, 0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.redAccent, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }


}
