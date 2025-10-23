import 'package:cloud_firestore/cloud_firestore.dart';

class TugasModel {
  final String id;
  final String deskripsi;
  final Timestamp dibuatPada;
  final String judul1;
  final String file1;
  final Timestamp tenggatWaktu;
  final String untukKelas;

  TugasModel({
    required this.id,
    required this.deskripsi,
    required this.dibuatPada,
    required this.judul1,
    required this.file1,
    required this.tenggatWaktu,
    required this.untukKelas,
  });

  factory TugasModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TugasModel(
      id: doc.id,
      deskripsi: data['deskripsi'] ?? '',
      dibuatPada: data['dibuatPada'] ?? Timestamp.now(),
      judul1: data['judul1'] ?? '',
      file1: data['file1'] ?? '',
      tenggatWaktu: data['tenggatWaktu'] ?? Timestamp.now(),
      untukKelas: data['untukKelas'] ?? '',
    );
  }
}
