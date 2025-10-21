import 'package:aplikasi_e_learning_smk/models/user_model.dart'; // Model baru kita
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/loading_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/login_screen.dart'; // UI Login baru kita
import 'package:aplikasi_e_learning_smk/screens/siswa_dashboard_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart'; // Service baru kita
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/Provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // User sedang login (Firebase Auth state)
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          // Jika tidak ada user, tampilkan LoginScreen
          if (user == null) {
            return const LoginScreen(); // Arahkan ke LoginScreen yang sudah di-revamp
          }

          // Jika ada user, ambil data detailnya dari Firestore
          return FutureBuilder<UserModel?>(
            future: authService.getUserData(user.uid), // Gunakan fungsi dari auth_service
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen(); // Tampilkan loading selagi ambil data
              }

              if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
                // Jika gagal ambil data (mungkin user dihapus?), logout dan ke login
                // Anda bisa tambahkan logging error di sini
                // Future.microtask(() => authService.signOut()); // Hati-hati jika ini menyebabkan loop
                return const LoginScreen();
              }

              final userModel = userSnapshot.data!;

              // Arahkan berdasarkan role dari UserModel
              if (userModel.role == 'guru') {
                return GuruDashboardScreen(userModel: userModel, destinationPage: 0);
              } else if (userModel.role == 'siswa') {
                return SiswaDashboardScreen(userModel: userModel, destinationPage: 0);
              } else {
                // Jika role tidak dikenal, kembali ke login
                return const LoginScreen();
              }
            },
          );
        } else {
          // Sedang loading auth state
          return const LoadingScreen();
        }
      },
    );
  }
}
