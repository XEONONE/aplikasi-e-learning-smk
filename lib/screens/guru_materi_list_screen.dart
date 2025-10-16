// lib/screens/guru_materi_list_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/edit_materi_screen.dart';
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
    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }

    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: AuthService().getUserData(currentUser.uid),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final guruKelas = userSnapshot.data!.mengajarKelas;
          if (guruKelas == null || guruKelas.isEmpty) {
            return const Center(
              child: Text('Anda belum terdaftar mengajar di kelas manapun.'),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            // ## PERUBAHAN PADA QUERY DIMULAI DI SINI ##
            stream: FirebaseFirestore.instance
                .collection('materi')
                .where('untukKelas', whereIn: guruKelas)
                .orderBy('mataPelajaran') // Diurutkan berdasarkan mapel
                .orderBy('diunggahPada', descending: true) // Lalu berdasarkan tanggal
                .snapshots(),
            // ## AKHIR PERUBAHAN QUERY ##
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada materi yang diunggah untuk kelas Anda.',
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Terjadi error. Pastikan indeks sudah dibuat.'));
              }

              // ## LOGIKA PENGELOMPOKAN MATERI (FOLDER) DIMULAI DI SINI ##
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: mapelKeys.length,
                itemBuilder: (context, index) {
                  String mapel = mapelKeys[index];
                  List<QueryDocumentSnapshot> materis = groupedMateri[mapel]!;

                  // ExpansionTile bertindak sebagai "Folder" mata pelajaran
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    child: ExpansionTile(
                      title: Text(
                        mapel,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      initiallyExpanded: true, // Folder langsung terbuka
                      children: materis.map((materiDoc) {
                        var materiData = materiDoc.data() as Map<String, dynamic>;
                        
                        // Menampilkan setiap materi di dalam folder
                        return MateriCard(
                          judul: materiData['judul'],
                          deskripsi: materiData['deskripsi'],
                          fileUrl: materiData['fileUrl'],
                          isGuruView: true, // Pastikan ini true untuk menampilkan tombol Edit
                          onEdit: () {
                            // Fungsi Edit tetap berjalan seperti sebelumnya
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditMateriScreen(
                                  materiId: materiDoc.id,
                                  initialData: materiData,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
              // ## AKHIR LOGIKA PENGELOMPOKAN ##
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