import 'package.cloud_firestore/cloud_firestore.dart';
import 'package.firebase_messaging/firebase_messaging.dart';
import 'package.flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Meminta izin notifikasi (untuk iOS & Web)
  Future<void> requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Mendapatkan FCM Token perangkat
  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  // Menyimpan token ke database (untuk user yang SUDAH LOGIN)
  // Catatan: Logika ini sekarang menggunakan arrayUnion untuk 'fcmTokens'
  Future<void> saveTokenToDatabase(String userId, String? token) async {
    if (token == null || userId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(userId).set( // Gunakan 'set' dengan 'merge: true'
        {
          'fcmTokens': FieldValue.arrayUnion([token]) // Gunakan arrayUnion
        },
        SetOptions(merge: true), // Pastikan merge: true
      );
      if (kDebugMode) {
        print('FCM Token saved to user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  // Inisialisasi notifikasi (bisa dipanggil di main.dart atau dashboard)
  Future<void> initNotifications() async {
    await requestPermission();
    // Anda bisa tambahkan listener untuk notifikasi di sini
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) { ... });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) { ... });
  }
}