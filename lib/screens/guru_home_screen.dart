import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GuruHomeScreen extends StatefulWidget {
  const GuruHomeScreen({super.key});

  @override
  State<GuruHomeScreen> createState() => _GuruHomeScreenState();
}

class _GuruHomeScreenState extends State<GuruHomeScreen> {
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: _authService.getUserData(currentUser!.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData) {
            return const Center(child: Text('Gagal memuat data guru.'));
          }

          final user = userSnapshot.data!;

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
                  user.nama,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ringkasan Aktivitas:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Kartu Ringkasan Jumlah Materi
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('materi').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.book, color: Colors.indigo),
                        title: const Text('Total Materi Diunggah'),
                        trailing: Text(
                          count.toString(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),

                // Kartu Ringkasan Jumlah Tugas
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('tugas').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.assignment, color: Colors.orange),
                        title: const Text('Total Tugas Dibuat'),
                        trailing: Text(
                          count.toString(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}