import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/login_screen.dart'; // Memastikan impor ini ada
import 'package:aplikasi_e_learning_smk/screens/siswa_dashboard_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Jika status koneksi masih menunggu, tampilkan loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Jika ada data user (sudah login)
        if (snapshot.hasData) {
          // Ambil data detail user dari Firestore berdasarkan UID
          return FutureBuilder<UserModel?>(
            future: AuthService().getUserData(snapshot.data!.uid),
            builder: (context, userModelSnapshot) {
              // Jika data detail user masih loading
              if (userModelSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // Jika data detail user berhasil didapatkan
              if (userModelSnapshot.hasData && userModelSnapshot.data != null) {
                final userRole = userModelSnapshot.data!.role;
                // Arahkan ke dasbor berdasarkan peran
                if (userRole == 'guru') {
                  return const GuruDashboardScreen();
                } else {
                  return const SiswaDashboardScreen();
                }
              }
              // Jika data user tidak ditemukan di Firestore (kasus aneh),
              // logout pengguna untuk mencegah error dan arahkan ke login
              AuthService().signOut();
              return const LoginScreen();
            },
          );
        } else {
          // Jika tidak ada data user (belum login), tampilkan halaman login
          return const LoginScreen();
        }
      },
    );
  }
}