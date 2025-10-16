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

    // Gunakan FutureBuilder untuk mendapatkan data kelas siswa terlebih dahulu
    return FutureBuilder<UserModel?>(
      future: AuthService().getUserData(currentUser.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('Gagal memuat data kelas siswa.'));
        }

        final userKelas = userSnapshot.data!.kelas;

        // Setelah kelas didapatkan, gunakan StreamBuilder untuk memfilter materi
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('materi')
              .where('untukKelas', isEqualTo: userKelas)
              .orderBy('mataPelajaran') // ## KELOMPOKKAN BERDASARKAN MATA PELAJARAN ##
              .orderBy('diunggahPada', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('Belum ada materi untuk kelas $userKelas.'),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Terjadi error saat memuat materi.'),
              );
            }
            
            // ## LOGIKA PENGELOMPOKAN MATERI (FOLDER) ##
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
              itemCount: mapelKeys.length,
              itemBuilder: (context, index) {
                String mapel = mapelKeys[index];
                List<QueryDocumentSnapshot> materis = groupedMateri[mapel]!;

                // ExpansionTile bertindak sebagai "Folder"
                return ExpansionTile(
                  title: Text(mapel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  initiallyExpanded: true, // Folder langsung terbuka
                  children: materis.map((materiDoc) {
                     var materiData = materiDoc.data() as Map<String, dynamic>;
                     return MateriCard(
                      judul: materiData['judul'],
                      deskripsi: materiData['deskripsi'],
                      fileUrl: materiData['fileUrl'],
                    );
                  }).toList(),
                );
              },
            );
            // ## AKHIR LOGIKA PENGELOMPOKAN ##
          },
        );
      },
    );
  }
}