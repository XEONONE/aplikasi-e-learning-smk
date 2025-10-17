// lib/auth_gate.dart

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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // User sudah login, sekarang cek perannya
          return FutureBuilder<UserModel?>(
            future: AuthService().getUserData(snapshot.data!.uid),
            builder: (context, userModelSnapshot) {
              if (userModelSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userModelSnapshot.hasData && userModelSnapshot.data != null) {
                final userRole = userModelSnapshot.data!.role;
                if (userRole == 'guru') {
                  return const GuruDashboardScreen();
                } else {
                  return const SiswaDashboardScreen();
                }
              }
              // Jika data user tidak ditemukan, logout untuk mencegah error
              AuthService().signOut();
              return const LoginScreen();
            },
          );
        } else {
          // User belum login
          return const LoginScreen();
        }
      },
    );
  }
}