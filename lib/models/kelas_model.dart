import 'package:cloud_firestore/cloud_firestore.dart';

class KelasModel {
  final String id;
  final String namaKelas;

  KelasModel({required this.id, required this.namaKelas});

  factory KelasModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KelasModel(id: doc.id, namaKelas: data['namaKelas'] ?? '');
  }
}
