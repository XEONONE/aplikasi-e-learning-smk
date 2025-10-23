// Lokasi: lib/models/materi_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MateriModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String fileUrl;
  final Timestamp diunggahPada;
  final String untukKelas;

  MateriModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.fileUrl,
    required this.diunggahPada,
    required this.untukKelas,
  });

  // Factory constructor untuk membuat instance dari Firestore document
  factory MateriModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return MateriModel(
      id: doc.id,
      judul: data['judul'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      diunggahPada: data['diunggahPada'] ?? Timestamp.now(),
      untukKelas: data['untukKelas'] ?? '',
    );
  }
}
