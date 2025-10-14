import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Widget untuk menampilkan kartu pengumuman (sudah ada sebelumnya)
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
      var userDoc = await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: uid).limit(1).get();
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
    String formattedDate = DateFormat('d MMMM yyyy, HH:mm').format(dibuatPada.toDate());

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

// ⭐️ KELAS YANG HILANG DITAMBAHKAN DI SINI ⭐️
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Mengambil data dari koleksi 'pengumuman' di Firestore
      stream: FirebaseFirestore.instance
          .collection('pengumuman')
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
          return const Center(child: Text('Terjadi error saat memuat pengumuman.'));
        }

        // Menampilkan daftar pengumuman menggunakan ListView
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;
            // Menggunakan widget AnnouncementCard yang sudah ada
            return AnnouncementCard(
              judul: data['judul'],
              isi: data['isi'],
              dibuatPada: data['dibuatPada'],
              dibuatOlehUid: data['dibuatOlehUid'],
            );
          },
        );
      },
    );
  }
}