import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/upload_materi_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/materi_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GuruMateriListScreen extends StatelessWidget {
  const GuruMateriListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text('Silakan login ulang.'));

    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: AuthService().getUserData(currentUser.uid),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final guruKelas = userSnapshot.data!.mengajarKelas;
          if (guruKelas == null || guruKelas.isEmpty) {
            return const Center(child: Text('Anda belum terdaftar mengajar di kelas manapun.'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materi')
                .where('untukKelas', whereIn: guruKelas) // FILTER DITERAPKAN DI SINI
                .orderBy('diunggahPada', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Belum ada materi yang diunggah untuk kelas Anda.'));
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Terjadi error.'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var materiData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadMateriScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Materi'),
      ),
    );
  }
}