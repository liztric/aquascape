import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemNavigator

class SettingsPageUI extends StatefulWidget {
  @override
  _SettingsPageUIState createState() => _SettingsPageUIState();
}

class _SettingsPageUIState extends State<SettingsPageUI> {
  bool isDarkMode = false;
  bool isSystemMode = true;
  bool keepScreenOn = false;
  bool skipTilesView = false;
  bool valNotify1 = false;
  bool valNotify2 = false;
  bool valNotify3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SizedBox(height: 20),
          const SizedBox(height: 10),
          _buildInterfaceContainer(), // Menggabungkan semua opsi dalam satu kotak
          const SizedBox(height: 40),
          _buildNotificationContainer(), // Menggabungkan semua opsi notifikasi dalam satu kotak
          const SizedBox(height: 50),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20), // Sesuaikan radius sudut
              ),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor:
                      Colors.transparent, // Pastikan tombol tetap transparan
                ),
                onPressed: () {
                  _showExitConfirmationDialog(context);
                },
                child: const Text(
                  "KELUAR",
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Ubah warna teks jika perlu
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Menggabungkan semua opsi dalam satu kotak untuk Interface
  Widget _buildInterfaceContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8), // Margin antar kotak
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 10), // Padding dalam kotak
      child: Column(
        children: [
          // Memusatkan teks "Interface"
          Container(
            alignment: Alignment.center,
            child: const Text(
              "Interface",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 20, thickness: 1),
          _buildLanguageOption(), // Language option dalam kotak
          const Divider(height: 20, thickness: 1),
          _buildThemeOption(), // Theme option dalam kotak
          const Divider(height: 20, thickness: 1),
          _buildNotificationOption("Jaga layar selalu aktif", keepScreenOn,
              (newValue) {
            setState(() {
              keepScreenOn = newValue;
            });
          }), // Keep screen option dalam kotak menggunakan notifikasi
          _buildNotificationOption(
              "Lewati halaman yang menggangu", skipTilesView, (newValue) {
            setState(() {
              skipTilesView = newValue;
            });
          }), // Skip tiles option dalam kotak menggunakan notifikasi
        ],
      ),
    );
  }

  // Menggabungkan semua opsi notifikasi dalam satu kotak
  Widget _buildNotificationContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Latar belakang putih
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 10), // Padding dalam kotak
      child: Column(
        children: [
          const Text(
            "Notifications",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20, thickness: 1),
          _buildNotificationOption("Terlalu Panas", valNotify1, (newValue) {
            setState(() {
              valNotify1 = newValue;
            });
          }),
          _buildNotificationOption("Terlalu Dingin", valNotify2, (newValue) {
            setState(() {
              valNotify2 = newValue;
            });
          }),
          _buildNotificationOption("PH Air Kurang Baik", valNotify3,
              (newValue) {
            setState(() {
              valNotify3 = newValue;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildLanguageOption() {
    return ListTile(
      title: const Text("BAHASA"),
      subtitle: const Text("Bahasa Indonesia"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        _showLanguageDialog(context);
      },
    );
  }

  Widget _buildThemeOption() {
    return ListTile(
      title: const Text("TEMA"),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildThemeButton("Light", !isDarkMode && !isSystemMode, () {
            setState(() {
              isDarkMode = false;
              isSystemMode = false;
            });
          }),
          _buildThemeButton("Gelap", isDarkMode, () {
            setState(() {
              isDarkMode = true;
              isSystemMode = false;
            });
          }),
          _buildThemeButton("System", isSystemMode, () {
            setState(() {
              isSystemMode = true;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildThemeButton(
      String text, bool isSelected, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(text),
    );
  }

  Widget _buildNotificationOption(
      String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              activeColor: Colors.blue,
              trackColor: Colors.grey,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("English"),
              Text("Bahasa Indonesia"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Konfirmasi",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text(
                "Keluar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
