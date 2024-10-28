import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  double temperature = 0.0;
  double ph = 0.0;
  bool isLoading = true;

  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref('sensors');

  @override
  void initState() {
    super.initState();
    _getSensorData();
  }

  Future<void> _getSensorData() async {
    // Mendengarkan perubahan data secara real-time
    databaseRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      print('Snapshot exists: ${snapshot.exists}');
      print('Snapshot value: ${snapshot.value}');

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

        setState(() {
          temperature =
              double.tryParse(data['temperature']?.toString() ?? '0') ?? 0.0;
          ph = double.tryParse(data['ph']?.toString() ?? '0') ?? 0.0;
          isLoading = false; // Menandakan bahwa data sudah berhasil dimuat
        });
      } else {
        print('Data tidak ditemukan!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Dashboard Monitoring',
            style: TextStyle(color: Colors.black)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDashboardRow(),
                  const SizedBox(height: 40),
                  // Tombol refresh dihapus
                ],
              ),
            ),
    );
  }

  Widget _buildDashboardRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDashboardItem(
          title: 'Temperature',
          value: '$temperature°C',
          icon: Icons.thermostat_rounded,
          color: Colors.orangeAccent,
        ),
        _buildDashboardItem(
          title: 'pH Level',
          value: '$ph',
          icon: Icons.science_outlined,
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _buildDashboardItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
