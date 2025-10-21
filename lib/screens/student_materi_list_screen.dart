import 'package:aplikasi_e_learning_smk/widgets/materi_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentMateriListScreen extends StatefulWidget {
  final String kelasId;
  const StudentMateriListScreen({super.key, required this.kelasId});

  @override
  State<StudentMateriListScreen> createState() =>
      _StudentMateriListScreenState();
}

class _StudentMateriListScreenState extends State<StudentMateriListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil materi yang ditujukan untuk 'Semua Kelas' ATAU kelas spesifik siswa
        stream: _firestore
            .collection('materi')
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
                'Belum ada materi yang diunggah.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi error.'));
          }

          var materiDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: materiDocs.length,
            itemBuilder: (context, index) {
              var materi = materiDocs[index].data() as Map<String, dynamic>;

              return MateriCard(
                judul: materi['judul'] ?? 'Tanpa Judul',
                deskripsi: materi['deskripsi'] ?? 'Tanpa Deskripsi',
                mapel: materi['mapel'] ?? 'Umum',
                author: materi['authorName'] ?? 'Guru',
                fileUrl: materi['fileUrl'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}