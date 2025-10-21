import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk memantau status autentikasi (dipakai oleh AuthGate)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mendapatkan data user saat ini
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Fungsi Login
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Biarkan UI yang menangani tampilan error
      if (kDebugMode) {
        print('Error login: $e');
      }
      rethrow;
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error logout: $e');
      }
    }
  }

  // Mengambil data detail pengguna dari Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromSnap(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error ambil data user: $e');
      }
      return null;
    }
  }

  // Fungsi Aktivasi Akun (dipakai di activation_screen.dart)
  Future<String> activateAccount(
      String nipNisn, String password, String fcmToken) async {
    try {
      // 1. Cari user di koleksi 'users' berdasarkan nipNisn
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('nipNisn', isEqualTo: nipNisn)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return 'Akun tidak ditemukan. Hubungi administrator.';
      }

      DocumentSnapshot userDoc = userQuery.docs.first;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // 2. Cek apakah akun sudah aktif
      if (userData['isActivated'] == true) {
        return 'Akun ini sudah diaktivasi sebelumnya.';
      }

      // 3. Buat akun di Firebase Authentication
      // GANTI 'domain.sekolah' DENGAN DOMAIN YANG SAMA SEPERTI DI LOGINSCREEN
      String email = '$nipNisn@domain.sekolah';

      UserCredential userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          return 'Akun ini sudah diaktivasi. Silakan login.';
        }
        return 'Gagal membuat akun Auth: ${e.toString()}';
      }

      // 4. Update status 'isActivated', 'fcmToken', dan 'uid' di Firestore
      await _firestore.collection('users').doc(userDoc.id).update({
        'isActivated': true,
        'fcmToken': fcmToken,
        'uid': userCredential.user!.uid,
      });

      return 'success';
    } catch (e) {
      if (kDebugMode) {
        print('Error aktivasi: $e');
      }
      return 'Terjadi error: ${e.toString()}';
    }
  }
}