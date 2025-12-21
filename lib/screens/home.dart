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
  late PageController _pageController;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 1️⃣ Initial data
    _alertsFuture = ApiService.fetchAlerts();
    _pageController = PageController(initialPage: _currentIndex);


    // 2️⃣ Firebase listeners
    _initFirebaseListeners();

    // 3️⃣ Glow animation
    _initGlowAnimation();
  }

  // ---------------- FIREBASE ----------------

  void _initFirebaseListeners() {
    // 📩 App is OPEN
    FirebaseMessaging.onMessage.listen((message) {
      final d = message.data;
      if (d.isEmpty) return;

      final alert = Alert(
        alertId: d['alertId'],
        name: d['name'],
        region: d['region'],
        description: d['description'],
        priority: d['priority'],
        lat: double.tryParse(d['lat'] ?? '') ?? 0,
        lng: double.tryParse(d['lng'] ?? '') ?? 0,
        createdAt: DateTime.now(),
      );

      setState(() {
        _alertsFuture = _alertsFuture.then((list) => [...list, alert]);
      });
    });

    // 👉 User taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      setState(() => _currentIndex = 3); // MAP TAB
      _pageController.jumpToPage(3);
    });
  }


  // ---------------- ANIMATION ----------------

  void _initGlowAnimation() {
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0, end: 25).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }


  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  Future<void> _openAddMissing() async {
    final newAlert = await Navigator.push<Alert>(
      context,
      MaterialPageRoute(builder: (_) => const AddMissingPersonScreen()),
    );

    if (newAlert != null) {
      setState(() {
        _alertsFuture =
            _alertsFuture.then((list) => [...list, newAlert]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      _buildAlertsPage(),
      const SizedBox(),
      _buildMapPage(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (_, __) => Text(
            'Amber Alert Macedonia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF111111),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 2) {
            _openAddMissing();
          } else {
            _navigateTo(i);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Alerts'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 36),
            label: 'Report',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // ---------------- HOME ----------------
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
                child: Image.asset(
                  'assets/logo.png',
                  width: 160,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Real-time missing person alerts across North Macedonia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 32),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _featureCard(Icons.list, 'View Alerts', 1),
                _featureCard(Icons.person_add, 'Report Missing', 2),
                _featureCard(Icons.map, 'Open Map', 3),
                _featureCard(Icons.settings, 'Settings', 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, int index) {
    return GestureDetector(
      onTap: () {
        if (index == 2) {
          _openAddMissing();
        } else {
          _navigateTo(index);
        }
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.redAccent, size: 32),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // ---------------- ALERTS ----------------
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

  // ---------------- MAP ----------------
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
}
