import 'package.cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nipNisn; // Mengganti 'id' menjadi 'nipNisn' agar lebih jelas
  final String nama;
  final String role;
  final String? kelas; // Untuk siswa
  final List<String>? mengajarKelas; // Untuk guru
  final bool isActivated;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.nipNisn,
    required this.nama,
    required this.role,
    this.kelas,
    this.mengajarKelas,
    required this.isActivated,
    this.fcmToken,
  });

  // Factory constructor untuk membuat UserModel dari DocumentSnapshot
  factory UserModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
      uid: snapshot['uid'] ?? '',
      nipNisn: snapshot['nipNisn'] ?? '',
      nama: snapshot['nama'] ?? '',
      role: snapshot['role'] ?? '',
      kelas: snapshot['kelas'],
      // Konversi List<dynamic> ke List<String> dengan aman
      mengajarKelas: snapshot['mengajarKelas'] != null
          ? List<String>.from(snapshot['mengajarKelas'])
          : null,
      isActivated: snapshot['isActivated'] ?? false,
      fcmToken: snapshot['fcmToken'],
    );
  }
}