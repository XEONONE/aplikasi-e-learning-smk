import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita tidak perlu AppBar di sini karena sudah ada di dasbor utama
      body: FutureBuilder<UserModel?>(
        future: _authService.getUserData(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat data pengguna.'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  user.nama, // Menampilkan nama siswa
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ringkasan Anda:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Contoh Kartu Ringkasan
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.blue),
                    title: const Text('Tugas Mendatang'),
                    subtitle: const Text('Tidak ada tugas yang akan datang.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Nanti bisa diarahkan langsung ke tab tugas
                    },
                  ),
                ),
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.book, color: Colors.green),
                    title: const Text('Materi Baru'),
                    subtitle: const Text('Belum ada materi baru.'),
                    trailing: const Icon(Icons.chevron_right),
                     onTap: () {
                      // Nanti bisa diarahkan langsung ke tab materi
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}