import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _pass = '';
  String _tokenNumber = '';

  void _register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _showNotification('Registrasi berhasil');

      // Setelah registrasi berhasil, arahkan pengguna kembali ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _showNotification(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0, // Menentukan posisi vertikal
        left: MediaQuery.of(context).size.width * 0.1, // Margin kiri
        right: MediaQuery.of(context).size.width * 0.1, // Margin kanan
        child: Material(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Menghapus notifikasi setelah 2 detik
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          // Background transparan
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/icon/bgmew.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          // Konten form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Memperpendek tinggi kotak
                    children: [
                      // Email
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _pass = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Nomor Token
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nomor Token Alat',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 5),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor Token tidak boleh kosong';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _tokenNumber = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Tombol Register
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _register,
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tombol Navigasi ke Login
                      TextButton(
                        onPressed: () {
                          // Navigasi ke halaman login
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Sudah punya akun? Login di sini',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
