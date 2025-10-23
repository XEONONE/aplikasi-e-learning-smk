import 'package:cloud_firestore/cloud_firestore.dart';

class PengumumanModel {
  final String id;
  final String dibuatUntuk;
  final Timestamp dibuatPada;
  final String isi;
  final String judul;
  final String untukKelas;

  PengumumanModel({
    required this.id,
    required this.dibuatUntuk,
    required this.dibuatPada,
    required this.isi,
    required this.judul,
    required this.untukKelas,
  });

  factory PengumumanModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PengumumanModel(
      id: doc.id,
      dibuatUntuk: data['dibuatUntuk'] ?? '',
      dibuatPada: data['dibuatPada'] ?? Timestamp.now(),
      isi: data['isi'] ?? '',
      judul: data['judul'] ?? '',
      untukKelas: data['untukKelas'] ?? '',
    );
  }
}
