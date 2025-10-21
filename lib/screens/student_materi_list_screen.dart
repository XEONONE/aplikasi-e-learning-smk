// lib/screens/student_materi_list_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/materi_card.dart'; // Pastikan ini di-import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentMateriListScreen extends StatefulWidget {
  const StudentMateriListScreen({super.key});

  @override
  State<StudentMateriListScreen> createState() => _StudentMateriListScreenState();
}

class _StudentMateriListScreenState extends State<StudentMateriListScreen> {
  late Future<UserModel?> _userFuture;
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _userFuture = _authService.getUserData(currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }
    // Dapatkan tema saat ini
    final theme = Theme.of(context);

    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final userKelas = userSnapshot.data!.kelas;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('materi')
              .where('untukKelas', isEqualTo: userKelas)
              .orderBy('mataPelajaran')
              .orderBy('diunggahPada', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Terjadi error saat memuat data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('Belum ada materi untuk kelas $userKelas.'),
              );
            }

            var groupedMateri = <String, List<QueryDocumentSnapshot>>{};
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              String mapel = data['mataPelajaran'] ?? 'Lainnya';
              if (groupedMateri[mapel] == null) {
                groupedMateri[mapel] = [];
              }
              groupedMateri[mapel]!.add(doc);
            }

            List<String> mapelKeys = groupedMateri.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: mapelKeys.length,
              itemBuilder: (context, index) {
                String mapel = mapelKeys[index];
                List<QueryDocumentSnapshot> materis = groupedMateri[mapel]!;

                return Card(
                  // ## INI CARD UNTUK MATA PELAJARAN (GROUP) ##
                  color: theme.cardColor,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  child: ExpansionTile(
                    // Warna ikon dan teks untuk ExpansionTile
                    iconColor: Colors.white70,
                    collapsedIconColor: Colors.white70,
                    textColor: Colors.white,
                    collapsedTextColor: Colors.white,
                    title: Text(
                      mapel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    initiallyExpanded: true,
                    // ## DAFTAR MATERI CARD SEBAGAI CHILDREN ##
                    children: materis.map((materiDoc) {
                      var materiData = materiDoc.data() as Map<String, dynamic>;
                      // Panggil MateriCard yang sudah diperbaiki
                      return MateriCard(
                        judul: materiData['judul'],
                        deskripsi: materiData['deskripsi'],
                        fileUrl: materiData['fileUrl'],
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}