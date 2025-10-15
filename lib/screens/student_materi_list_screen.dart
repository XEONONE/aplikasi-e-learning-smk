import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/materi_card.dart';
// --- PERBAIKAN DI SINI ---
import 'package:cloud_firestore/cloud_firestore.dart';
// --- AKHIR PERBAIKAN ---
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
              .where(
                'untukKelas',
                isEqualTo: userKelas,
              ) // FILTER DITERAPKAN DI SINI
              .orderBy('diunggahPada', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Pesan ini akan muncul di Debug Console untuk membantu Anda
              print("--- DEBUG INFO ---");
              print(
                "Nilai 'kelas' dari data siswa saat ini adalah: '$userKelas'",
              );
              print(
                "Pastikan nilai di atas SAMA PERSIS dengan field 'untukKelas' di koleksi 'materi' Anda di Firestore.",
              );
              print("--------------------");

              return Center(
                child: Text('Belum ada materi untuk kelas $userKelas.'),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Terjadi error saat memuat materi.'),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var materiData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return MateriCard(
                  judul: materiData['judul'],
                  deskripsi: materiData['deskripsi'],
                  fileUrl: materiData['fileUrl'],
                );
              },
            );
          },
        );
      },
    );
  }
}
