// lib/screens/student_materi_list_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/materi_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentMateriListScreen extends StatelessWidget {
  const StudentMateriListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }

    // 1. Ambil data siswa
    return FutureBuilder<UserModel?>(
      future: AuthService().getUserData(currentUser.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          // DEBUG: Print jika data user tidak ditemukan
          print("DEBUG: Gagal memuat data user model.");
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final userKelas = userSnapshot.data!.kelas;
        // DEBUG: Print kelas siswa yang didapat
        print("==============================================");
        print("DEBUG: Mencari materi untuk kelas: '$userKelas'");
        print("==============================================");

        // 2. Ambil data materi berdasarkan kelas siswa
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
              // DEBUG: Print jika ada error dari Firestore
              print("!!! FIREBASE ERROR: ${snapshot.error}");
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
              // DEBUG: Print jika tidak ada dokumen yang ditemukan
              print(
                "DEBUG: Query berhasil, namun tidak ada dokumen materi yang cocok.",
              );
              return Center(
                child: Text('Belum ada materi untuk kelas $userKelas.'),
              );
            }

            // DEBUG: Print jumlah dokumen yang ditemukan
            print(
              "DEBUG: Query berhasil! Ditemukan ${snapshot.data!.docs.length} dokumen materi.",
            );

            // 3. Logika pengelompokan
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

            // 4. Tampilkan data
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: mapelKeys.length,
              itemBuilder: (context, index) {
                String mapel = mapelKeys[index];
                List<QueryDocumentSnapshot> materis = groupedMateri[mapel]!;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      mapel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    initiallyExpanded: true,
                    children: materis.map((materiDoc) {
                      var materiData = materiDoc.data() as Map<String, dynamic>;
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
