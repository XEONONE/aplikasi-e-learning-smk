import 'package:cloud_firestore/cloud_firestore.dart';

class PengumpulanModel {
  final String id;
  final Timestamp dikumpulkanPada;
  final String feedback;
  final String fileName;
  final String fileUrl;
  final String? nilai;
  final String siswaUid;

  PengumpulanModel({
    required this.id,
    required this.dikumpulkanPada,
    required this.feedback,
    required this.fileName,
    required this.fileUrl,
    this.nilai,
    required this.siswaUid,
  });

  factory PengumpulanModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PengumpulanModel(
      id: doc.id,
      dikumpulkanPada: data['dikumpulkanPada'] ?? Timestamp.now(),
      feedback: data['feedback'] ?? '',
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      nilai: data['nilai'],
      siswaUid: data['siswaUid'] ?? '',
    );
  }
}
