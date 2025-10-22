import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi locale Indonesia untuk format tanggal
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Learning App',
      // ++ TEMA GELAP DIUBAH DI SINI ++
      theme: ThemeData.dark().copyWith(
        // Warna background utama
        scaffoldBackgroundColor: const Color(
          0xFF121212,
        ), // Abu-abu sangat gelap
        // Warna card
        cardColor: const Color(0xFF1E1E1E), // Abu-abu sedikit lebih terang
        // Atur warna BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E), // Background
          selectedItemColor: Colors.blueAccent, // Warna ikon/label terpilih
          unselectedItemColor: Colors.grey, // Warna ikon/label tidak terpilih
          type: BottomNavigationBarType.fixed, // Selalu tampilkan label
        ),
        // Atur warna AppBar (jika ada yang masih pakai)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0, // Hilangkan bayangan
        ),
        // Atur warna FAB
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        // Kustomisasi warna lain jika perlu
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.blueAccent,
          surface: const Color(0xFF1E1E1E), // Warna background
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
      ),
      // -- AKHIR PERUBAHAN THEME --
      home: const AuthGate(),
    );
  }
}
