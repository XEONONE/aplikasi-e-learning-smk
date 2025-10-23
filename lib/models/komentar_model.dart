import 'package:cloud_firestore/cloud_firestore.dart';

class KomentarModel {
  final String id;
  final String authorName;
  final String authorUid;
  final String text;
  final Timestamp timestamp;

  KomentarModel({
    required this.id,
    required this.authorName,
    required this.authorUid,
    required this.text,
    required this.timestamp,
  });

  factory KomentarModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KomentarModel(
      id: doc.id,
      authorName: data['authorName'] ?? '',
      authorUid: data['authorUid'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
