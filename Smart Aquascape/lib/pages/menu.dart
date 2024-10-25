import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Variabel untuk menampung data dari Firebase
  double temperature = 0.0;
  double ph = 0.0;

  // Referensi ke Realtime Database Firebase
  final DatabaseReference databaseRef = FirebaseDatabase.instance
      .ref('sensors'); // Mengubah referensi ke 'sensors'

  @override
  void initState() {
    super.initState();
    _getSensorData(); // Panggil data saat halaman dibuka
  }

  // Fungsi untuk mengambil data dari Firebase
  Future<void> _getSensorData() async {
    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;

        // Mengakses data dari objek 'sensors'
        setState(() {
          temperature = double.tryParse(data['temperature'].toString()) ?? 0.0;
          ph = double.tryParse(data['ph'].toString()) ?? 0.0;
        });
      } else {
        print('Data tidak ditemukan!');
      }
    } catch (e) {
      print('Gagal mengambil data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Aquascape'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50], // Background dengan warna lembut
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoCard('Suhu', '$temperature °C', Icons.thermostat),
              const SizedBox(height: 16),
              _buildInfoCard('pH', '$ph', Icons.science),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _getSensorData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Refresh Data',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan informasi dalam Card
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
