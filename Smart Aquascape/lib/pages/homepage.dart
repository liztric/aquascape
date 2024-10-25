import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/menu.dart';
import 'package:flutter_application_1/pages/settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  int currentIndex = 0;
  List mySmartDevices = [
    ["Lampu", "lib/icon/lampu.png", false],
    ["Kipas/Pendingin", "lib/icon/kipas.png", false],
  ];

  @override
  void initState() {
    super.initState();
    print("Inisialisasi Firebase dan mendengarkan perubahan data...");
    _listenToRelayChanges();
  }

  void _listenToRelayChanges() {
    databaseRef.child('relays').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        print("Data diterima dari Firebase: $data"); // Debug log

        setState(() {
          mySmartDevices[0][2] = data['led'] ?? false;
          mySmartDevices[1][2] = data['fan'] ?? false;
        });
        print(
            "Status perangkat setelah update: ${mySmartDevices[0][0]}: ${mySmartDevices[0][2]}, ${mySmartDevices[1][0]}: ${mySmartDevices[1][2]}"); // Debug log
      } else {
        print("Data tidak ditemukan di Firebase."); // Debug log
      }
    });
  }

  void powerSwitchChanged(bool value, int index) {
    setState(() {
      mySmartDevices[index][2] = value;
    });

    String deviceKey;
    switch (index) {
      case 0:
        deviceKey = 'led';
        break;
      case 1:
        deviceKey = 'fan';
        break;
      default:
        print("Indeks perangkat tidak valid."); // Debug log
        return;
    }

    print("Mengirim perubahan ke Firebase: $deviceKey = $value"); // Debug log

    // Update status perangkat di Firebase
    databaseRef.child('relays').update({deviceKey: value}).then((_) {
      print("Data $deviceKey berhasil di-update di Firebase."); // Debug log
    }).catchError((error) {
      print("Gagal mengupdate data di Firebase: $error"); // Debug log
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.blue,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.menu, color: Colors.white),
          Icon(Icons.settings, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: _getCurrentPage(),
      ),
    );
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

  Widget _buildHomePage() {
    return Container(
      constraints: BoxConstraints.expand(),
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/background.jpg"), // Gambar background
      //     fit: BoxFit.cover, // Gambar akan menutupi seluruh layar
      //   ),
      // ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              SizedBox(height: 20),
              _buildWelcomeCard(),
              SizedBox(height: 20),
              Text(
                "Devices",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Pastikan teks terlihat di atas gambar
                ),
              ),
              SizedBox(height: 16),
              _buildDevicesGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Text(
      "Hi Hira",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Let's schedule your projects",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          // Image.asset(
          //   'assets/working_person.png',  // Make sure to add this image to your assets
          //   height: 80,
          // ),
        ],
      ),
    );
  }

  Widget _buildDevicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: mySmartDevices.length,
      itemBuilder: (context, index) {
        return SmartDeviceCard(
          deviceName: mySmartDevices[index][0],
          iconPath: mySmartDevices[index][1],
          isOn: mySmartDevices[index][2],
          onChanged: (value) => powerSwitchChanged(value, index),
        );
      },
    );
  }
}

class SmartDeviceCard extends StatelessWidget {
  final String deviceName;
  final String iconPath;
  final bool isOn;
  final Function(bool) onChanged;

  const SmartDeviceCard({
    Key? key,
    required this.deviceName,
    required this.iconPath,
    required this.isOn,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deviceName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Image.asset(
                  iconPath,
                  height: 24,
                  width: 24,
                  color: isOn ? Colors.blue : Colors.grey,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOn ? "On" : "Off",
                  style: TextStyle(
                    fontSize: 16,
                    color: isOn ? Colors.blue : Colors.grey,
                  ),
                ),
                CupertinoSwitch(
                  value: isOn,
                  onChanged: onChanged,
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
