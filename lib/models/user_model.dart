// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String id; // NIP atau NISN
  final String nama;
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      id: data['id'] ?? '',
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
