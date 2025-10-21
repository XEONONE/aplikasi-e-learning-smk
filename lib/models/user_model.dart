import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String id; // Mengganti 'nipNisn' menjadi 'id' sesuai Firestore
  final String nama;
  final String role;
  final String? email; // Menambahkan field email sesuai Firestore
  final String? kelas; // Untuk siswa
  final List<String>? mengajarKelas; // Untuk guru
  final bool isActivated;
  final List<String>? fcmTokens; // Mengganti 'fcmToken' menjadi List 'fcmTokens'

  UserModel({
    required this.uid,
    required this.id, // Menggunakan 'id'
    required this.nama,
    required this.role,
    this.email, // Menambahkan email
    this.kelas,
    this.mengajarKelas,
    required this.isActivated,
    this.fcmTokens, // Menggunakan 'fcmTokens'
  });

  // Factory constructor untuk membuat UserModel dari DocumentSnapshot
  factory UserModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    // Helper untuk konversi List<dynamic> ke List<String> dengan aman
    List<String>? parseListString(dynamic listData) {
      if (listData is List) {
        // Pastikan semua elemen adalah string sebelum konversi
        if (listData.every((item) => item is String)) {
          return List<String>.from(listData);
        }
      }
      return null;
    }

    return UserModel(
      uid: snapshot['uid'] ?? '',
      id: snapshot['id'] ?? '', // Menggunakan 'id' dari Firestore
      nama: snapshot['nama'] ?? '',
      role: snapshot['role'] ?? '',
      email: snapshot['email'], // Mengambil email
      kelas: snapshot['kelas'],
      mengajarKelas: parseListString(snapshot['mengajarKelas']), // Menggunakan helper
      isActivated: snapshot['isActivated'] ?? false,
      fcmTokens: parseListString(snapshot['fcmTokens']), // Mengambil fcmTokens sebagai List
    );
  }

  // Method untuk konversi UserModel ke Map (jika diperlukan)
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'id': id,
        'nama': nama,
        'role': role,
        'email': email,
        'kelas': kelas,
        'mengajarKelas': mengajarKelas,
        'isActivated': isActivated,
        'fcmTokens': fcmTokens,
      };
}