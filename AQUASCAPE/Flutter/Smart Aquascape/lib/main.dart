import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'pages/homepage.dart'; // Import halaman homepage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tampilkan layar loading saat inisialisasi Firebase
  runApp(const MyAppLoader());

  try {
    // Menambahkan log sebelum inisialisasi
    print('Inisialisasi Firebase dimulai...');

    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBaFoEs5Lj2SsEviB860tOSYKkhqsId-fo',
        appId: '1:376058203228:android:408e3c4904cfec1488ea99',
        messagingSenderId: '376058203228',
        projectId: 'aquascape-ffef6',
        databaseURL:
            'https://aquascape-ffef6-default-rtdb.asia-southeast1.firebasedatabase.app',
        storageBucket: 'aquascape-ffef6.appspot.com',
      ),
    );

    // Jika berhasil, jalankan aplikasi utama
    print('Firebase berhasil diinisialisasi.');
    runApp(const MyApp());
  } catch (e) {
    // Jika gagal, tampilkan layar error dan log kesalahan
    print('Gagal menginisialisasi Firebase: $e');
    runApp(MyAppNotConnected(errorMessage: e.toString()));
  }
}

// Layar Loading saat inisialisasi Firebase
class MyAppLoader extends StatelessWidget {
  const MyAppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            'assets/loading.json',
            width: 200,
            height: 200,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

// Aplikasi Utama langsung menuju Homepage
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquascape Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const Homepage(), // Langsung ke homepage
    );
  }
}

// Halaman ketika Firebase gagal terhubung
class MyAppNotConnected extends StatelessWidget {
  final String errorMessage;

  const MyAppNotConnected({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Connection Error'),
        ),
        body: Center(
          child: Text(
            'Gagal menginisialisasi Firebase: $errorMessage',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}