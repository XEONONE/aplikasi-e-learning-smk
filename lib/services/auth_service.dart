import 'package:aplikasi_e_learning_smk/models/user_model.dart'; // Pastikan path ini benar
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
  Future<User?> signInWithIdAndPassword(String id, String password) async { // Menggunakan 'id' bukan email
    // Buat format email dari ID (sesuaikan 'domain.sekolah' jika perlu)
    String email = '$id@domain.sekolah'; // Logika ini SAMA seperti kode asli Anda
    if (kDebugMode) {
      print('Attempting login with generated email: $email');
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, // Tetap gunakan email untuk Firebase Auth
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Error login: $e');
      }
      rethrow; // Biarkan UI menangani tampilan error
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

  // Mengambil data detail pengguna dari Firestore berdasarkan UID Firebase Auth
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get(); // Ambil berdasarkan UID Auth
      if (doc.exists) {
        return UserModel.fromSnap(doc); // Gunakan UserModel yang sudah disesuaikan
      }
       if (kDebugMode) {
        print('User document not found for UID: $uid');
       }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data for UID $uid: $e');
      }
      return null;
    }
  }

  // Fungsi Aktivasi Akun (dipakai di activation_screen.dart)
  // Menggunakan 'id' (NIP/NISN) untuk mencari user di Firestore
  Future<String> activateAccount(String id, String password, String? fcmToken) async {
    try {
      // 1. Cari user di koleksi 'users' berdasarkan field 'id' (NIP/NISN)
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('id', isEqualTo: id) // Cari berdasarkan field 'id'
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return 'Akun dengan NIP/NISN tersebut tidak ditemukan. Hubungi administrator.';
      }

      DocumentSnapshot userDoc = userQuery.docs.first;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String existingUid = userDoc.id; // Ini adalah ID dokumen Firestore (yang mungkin BUKAN uid auth jika belum aktif)

      // 2. Cek apakah akun sudah aktif
      if (userData['isActivated'] == true) {
        return 'Akun ini sudah diaktivasi sebelumnya. Silakan login.';
      }

      // 3. Buat akun di Firebase Authentication
      // GANTI 'domain.sekolah' DENGAN DOMAIN YANG SAMA SEPERTI DI LOGIN
      String email = '$id@domain.sekolah'; // Logika ini SAMA seperti kode asli Anda

      UserCredential userCredential;
      try {
        if (kDebugMode) {
          print('Attempting to create Firebase Auth user with email: $email');
        }
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
         if (kDebugMode) {
          print('Firebase Auth user created successfully with UID: ${userCredential.user!.uid}');
        }
      } on FirebaseAuthException catch (e) {
         if (kDebugMode) {
          print('Error creating Firebase Auth user: ${e.code} - ${e.message}');
        }
        if (e.code == 'email-already-in-use') {
          // Coba cari apakah email ini sudah terdaftar di Auth tapi dokumen user belum 'isActivated'
          try {
             // Jika sudah ada user Auth, coba update Firestore saja (mungkin aktivasi gagal sebelumnya)
             await _updateUserActivationData(existingUid, userCredential.user!.uid, fcmToken);
             return 'success'; // Anggap sukses jika user auth sudah ada dan kita bisa update data
          } catch(updateError) {
             return 'Akun Auth sudah ada, tetapi gagal memperbarui data pengguna. Hubungi admin. Error: $updateError';
          }

        } else if (e.code == 'weak-password') {
           return 'Password terlalu lemah.';
        }
        return 'Gagal membuat akun Auth: ${e.message}';
      } catch (e) {
         if (kDebugMode) {
          print('Generic error creating Firebase Auth user: $e');
        }
        return 'Terjadi error tidak dikenal saat membuat akun Auth: ${e.toString()}';
      }

      // 4. Update status 'isActivated', 'fcmTokens', dan 'uid' di Firestore
      // PENTING: ID Dokumen di Firestore mungkin berbeda dari UID Firebase Auth
      // Kita perlu update dokumen yang kita temukan berdasarkan field 'id' (NIP/NISN)
       if (kDebugMode) {
         print('Updating Firestore document ID: $existingUid with Auth UID: ${userCredential.user!.uid}');
       }
      await _updateUserActivationData(existingUid, userCredential.user!.uid, fcmToken);


      return 'success';
    } catch (e) {
      if (kDebugMode) {
        print('Error during activation process: $e');
      }
      return 'Terjadi error saat aktivasi: ${e.toString()}';
    }
  }

  // Helper function to update Firestore during activation
  Future<void> _updateUserActivationData(String firestoreDocId, String authUid, String? fcmToken) async {
      Map<String, dynamic> updateData = {
        'isActivated': true,
        'uid': authUid, // Simpan UID Firebase Auth ke dokumen Firestore
      };

      // Hanya update fcmTokens jika token valid
      if (fcmToken != null && fcmToken.isNotEmpty) {
        updateData['fcmTokens'] = FieldValue.arrayUnion([fcmToken]);
      } else {
         // Jika tidak ada token baru, pastikan field fcmTokens ada (sebagai list kosong jika belum)
         updateData['fcmTokens'] = FieldValue.arrayUnion([]);
      }

      await _firestore.collection('users').doc(firestoreDocId).set( // Gunakan set dengan merge true
        updateData,
        SetOptions(merge: true), // Merge agar tidak menimpa field lain yang mungkin sudah ada
      );
       if (kDebugMode) {
         print('Firestore document $firestoreDocId updated successfully.');
       }
  }

}