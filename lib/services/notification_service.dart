// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    // Meminta izin notifikasi dari pengguna (penting untuk iOS dan Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('Izin notifikasi diberikan oleh pengguna.');
      }
      // Dapatkan token perangkat dan simpan ke database
      await _saveTokenToDatabase();

      // Dengarkan jika token diperbarui, lalu simpan lagi
      _fcm.onTokenRefresh.listen((token) async {
        await _saveTokenToDatabase(token: token);
      });
    } else {
      if (kDebugMode) {
        print('Pengguna menolak atau belum memberikan izin notifikasi.');
      }
    }
  }

  // Fungsi untuk menyimpan token FCM ke dokumen pengguna di Firestore
  Future<void> _saveTokenToDatabase({String? token}) async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;

    String? fcmToken = token ?? await _fcm.getToken();
    if (fcmToken == null) return;

    // Cari dokumen pengguna berdasarkan UID
    var userDocQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: currentUser.uid)
        .limit(1)
        .get();

    if (userDocQuery.docs.isNotEmpty) {
      DocumentReference userDocRef = userDocQuery.docs.first.reference;
      // Simpan token ke dalam sebuah array. Ini berguna jika pengguna login di beberapa perangkat.
      await userDocRef.update({
        'fcmTokens': FieldValue.arrayUnion([fcmToken])
      });
    }
  }
}