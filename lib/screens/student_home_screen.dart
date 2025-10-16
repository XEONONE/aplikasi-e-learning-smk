// lib/screens/student_home_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Widget untuk menampilkan kartu pengumuman
class AnnouncementCard extends StatelessWidget {
  final String judul;
  final String isi;
  final Timestamp dibuatPada;
  final String dibuatOlehUid;

  const AnnouncementCard({
    super.key,
    required this.judul,
    required this.isi,
    required this.dibuatPada,
    required this.dibuatOlehUid,
  });

  Future<String> _getAuthorName(String uid) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data()['nama'] ?? 'Admin';
      }
      return 'Admin';
    } catch (e) {
      return 'Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'd MMMM yyyy, HH:mm',
    ).format(dibuatPada.toDate());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _getAuthorName(dibuatOlehUid),
              builder: (context, snapshot) {
                return Text(
                  'Diposting oleh ${snapshot.data ?? "..."} • $formattedDate',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                );
              },
            ),
            const Divider(height: 24),
            Text(isi, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// Widget utama untuk halaman beranda siswa
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }

    // Gunakan FutureBuilder untuk mendapatkan data kelas siswa
    return FutureBuilder<UserModel?>(
      future: AuthService().getUserData(currentUser.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final user = userSnapshot.data!;
        final userKelas = user.kelas;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ## PENAMBAHAN HEADER NAMA DAN KELAS SISWA ##
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selamat Datang,',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(
                    user.nama,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (userKelas != null && userKelas.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Kelas: $userKelas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Pengumuman Terbaru',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            // ## AKHIR PENAMBAHAN ##
            
            // Bagian Daftar Pengumuman
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pengumuman')
                    .where('untukKelas', whereIn: [userKelas, 'Semua Kelas'])
                    .orderBy('dibuatPada', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada pengumuman.'));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Terjadi error saat memuat pengumuman.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      return AnnouncementCard(
                        judul: data['judul'],
                        isi: data['isi'],
                        dibuatPada: data['dibuatPada'],
                        dibuatOlehUid: data['dibuatOlehUid'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}