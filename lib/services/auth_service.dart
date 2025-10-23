// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplikasi_e_learning_smk/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan stream status autentikasi user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mendapatkan data user dari Firestore berdasarkan UID
  Future<UserModel?> getUserData(String uid) async {
    try {
      print("getUserData: Fetching user data for UID: $uid");

      // Cari di koleksi users berdasarkan field 'uid'
      var snapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      print(
        "getUserData: Query completed. Docs found: ${snapshot.docs.length}",
      );

      if (snapshot.docs.isNotEmpty) {
        // Ambil ID dokumen (yaitu NIP/NISN)
        String docId = snapshot.docs.first.id;
        // Ambil data dan tambahkan ID ke dalamnya
        Map<String, dynamic> data = snapshot.docs.first.data();
        data['id'] = docId; // Memastikan field 'id' terisi

        print("getUserData: User data retrieved: $data");

        return UserModel.fromMap(data);
      }

      print("getUserData: No user document found for UID: $uid");
      return null;
    } catch (e) {
      print("getUserData: Error getting user data: $e");
      return null;
    }
  }

  // Tambahkan ini di dalam class AuthService
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Fungsi Aktivasi Akun
  Future<String> activateAccount({
    required String nipNisn,
    required String password,
  }) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(nipNisn)
          .get();

      if (!userDoc.exists) {
        return "NIP/NISN tidak terdaftar.";
      }

      final data = userDoc.data() as Map<String, dynamic>;
      if (data['uid'] != null && data['uid'] != '') {
        return "Akun ini sudah aktif. Silakan login.";
      }

      String email = data['email'];
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(nipNisn).update({
        'uid': userCredential.user!.uid,
      });

      return "Sukses";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Terjadi error.";
    } catch (e) {
      return "Terjadi error tidak diketahui.";
    }
  }

  // Fungsi Login
  Future<String> login({
    required String nipNisn,
    required String password,
  }) async {
    try {
      print("Login attempt for NIP/NISN: $nipNisn");

      // Cek apakah dokumen user ada
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(nipNisn)
          .get();

      if (!userDoc.exists) {
        print("User document does not exist for NIP/NISN: $nipNisn");
        return "NIP/NISN tidak terdaftar.";
      }

      print("User document exists. Data: ${userDoc.data()}");

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String email = userData['email'];

      if (email == null || email.isEmpty) {
        print("Email field is missing or empty for NIP/NISN: $nipNisn");
        return "Data akun tidak lengkap. Hubungi admin.";
      }

      print("Attempting Firebase Auth sign in with email: $email");

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("Firebase Auth successful. User UID: ${userCredential.user?.uid}");

      return "Sukses";
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      if (e.code == 'user-not-found') {
        return "Akun belum diaktifkan. Silakan aktivasi terlebih dahulu.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Password salah.";
      } else if (e.code == 'user-disabled') {
        return "Akun dinonaktifkan.";
      } else if (e.code == 'too-many-requests') {
        return "Terlalu banyak percobaan login. Coba lagi nanti.";
      } else if (e.code == 'network-request-failed') {
        return "Koneksi internet bermasalah.";
      }
      return e.message ?? "Terjadi error autentikasi.";
    } catch (e) {
      print("Unexpected error: $e");
      return "Terjadi error tidak diketahui: $e";
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
