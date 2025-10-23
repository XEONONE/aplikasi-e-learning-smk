import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/login_screen.dart';
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
        print("AuthGate: Connection state: ${snapshot.connectionState}");
        print("AuthGate: Has data: ${snapshot.hasData}");
        if (snapshot.hasData) {
          print("AuthGate: User UID: ${snapshot.data!.uid}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("AuthGate: Stream error: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.hasData) {
          // User sudah login, cek peran
          return FutureBuilder<UserModel?>(
            future: AuthService().getUserData(snapshot.data!.uid),
            builder: (context, userModelSnapshot) {
              print(
                "AuthGate: UserModel future state: ${userModelSnapshot.connectionState}",
              );
              print(
                "AuthGate: UserModel has data: ${userModelSnapshot.hasData}",
              );

              if (userModelSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userModelSnapshot.hasError) {
                print("AuthGate: UserModel error: ${userModelSnapshot.error}");
                AuthService().signOut();
                return LoginScreen();
              }

              if (userModelSnapshot.hasData && userModelSnapshot.data != null) {
                final userRole = userModelSnapshot.data!.role;
                print("AuthGate: User role: $userRole");
                if (userRole == 'guru') {
                  return const GuruDashboardScreen();
                } else {
                  return const SiswaDashboardScreen();
                }
              }

              // Data user tidak ditemukan, paksa logout
              print("AuthGate: User data not found, signing out");
              AuthService().signOut();
              return LoginScreen();
            },
          );
        } else {
          // User belum login
          print("AuthGate: No user data, showing login screen");
          return LoginScreen();
        }
      },
    );
  }
}
