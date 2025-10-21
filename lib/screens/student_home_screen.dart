import 'package:aplikasi_e_learning_smk/widgets/announcement_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentHomeScreen extends StatefulWidget {
  final String kelasId;
  const StudentHomeScreen({super.key, required this.kelasId});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil pengumuman yang ditujukan untuk 'Semua Kelas' ATAU kelas spesifik siswa
        stream: _firestore
            .collection('pengumuman')
            .where('targetKelas',
                whereIn: ['Semua Kelas', widget.kelasId])
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada pengumuman terbaru.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi error.'));
          }

          var announcements = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              var announcement =
                  announcements[index].data() as Map<String, dynamic>;
              return AnnouncementCard(
                title: announcement['judul'] ?? 'Tanpa Judul',
                content: announcement['isi'] ?? 'Tanpa Isi',
                timestamp: announcement['timestamp'] as Timestamp,
                author: announcement['authorName'] ?? 'Administrator',
              );
            },
          );
        },
      ),
    );
  }
}