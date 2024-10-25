import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/menu.dart';
import 'package:flutter_application_1/pages/settings.dart';
import 'package:flutter_application_1/util/smart_device_box.dart';
import 'package:firebase_database/firebase_database.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final double horizontalPadding = 40;
  final double verticalPadding = 25;

  List mySmartDevices = [
    ["Lampu ", "lib/icon/lampu.png", false],
    ["Kipas/Pendingin", "lib/icon/kipas.png", false],
    ["Pemanas", "lib/icon/suhu.png", false],
    ["Pengatur PH", "lib/icon/PH.png", false],
  ];

  int currentIndex = 0;
  double suhu = 0.0;
  String kualitasAir = "Loading...";
  double ph = 0.0;

  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref('monitoring');

  @override
  void initState() {
    super.initState();
    _getMonitoringData();
  }

  Future<void> _getMonitoringData() async {
    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          suhu = double.parse(data['suhu'].toString());
          kualitasAir = data['kualitas_air'].toString();
          ph = double.parse(data['ph'].toString());
        });
      } else {
        print('Data tidak ditemukan!');
      }
    } catch (e) {
      print('Gagal mengambil data: $e');
    }
  }

  void powerSwitchChanged(bool value, int index) {
    setState(() {
      mySmartDevices[index][2] = value;
    });
  }

  Widget _getCurrentPage() {
    switch (currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return MenuPage();
      case 2:
        return SettingsPageUI();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildHomePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Selamat Datang di Smart Aquascape,"),
              Text(
                "kakak yanzy",
                style: TextStyle(fontSize: 40),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text("Alat Pintar Smart Aquascape"),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(10),
            children: List.generate(mySmartDevices.length, (index) {
              return SmartDeviceBox(
                smartDeviceName: mySmartDevices[index][0],
                iconPath: mySmartDevices[index][1],
                powerOn: mySmartDevices[index][2],
                onChanged: (value) => powerSwitchChanged(value, index),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blue,
        items: const [
          Icon(Icons.home),
          Icon(Icons.menu),
          Icon(Icons.settings),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: _getCurrentPage(),
        ),
      ),
    );
  }
}
