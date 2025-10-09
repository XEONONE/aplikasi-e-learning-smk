// lib/screens/student_materi_list_screen.dart

import 'package:aplikasi_e_learning_smk/widgets/materi_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentMateriListScreen extends StatelessWidget {
  const StudentMateriListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('materi')
          .orderBy('diunggahPada', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada materi yang diunggah.'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi error.'));
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
  }
}