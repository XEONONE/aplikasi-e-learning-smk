// lib/screens/account_settings_screen.dart

import 'package:aplikasi_e_learning_smk/services/auth_service.dart'; // Untuk mendapatkan email user
import 'package:firebase_auth/firebase_auth.dart'; // Untuk update password
import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _notificationsEnabled = true; // Nilai default
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Isi email dari user yang sedang login
    _emailController.text = _currentUser?.email ?? 'Email tidak ditemukan';
    // TODO: Ambil status notifikasi dari penyimpanan (misal: Firestore/SharedPreferences)
    // _loadNotificationSetting();
  }

  // Future<void> _loadNotificationSetting() async {
  //   // Implementasi ambil data notifikasi
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan pengaturan
  Future<void> _saveSettings() async {
    // Validasi dasar (minimal password jika diisi)
    final newPassword = _newPasswordController.text.trim();
    if (newPassword.isNotEmpty && newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru minimal harus 6 karakter.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Update password jika diisi
      if (newPassword.isNotEmpty && _currentUser != null) {
        await _currentUser!.updatePassword(newPassword);
        // Kosongkan field setelah berhasil update
        _newPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // 2. Simpan status notifikasi
      // TODO: Implementasi simpan status notifikasi ke Firestore/SharedPreferences
      // await _saveNotificationSetting(_notificationsEnabled);

      // Tampilkan pesan sukses umum jika tidak ada error password
      if (newPassword.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Gagal memperbarui password.';
      if (e.code == 'requires-recent-login') {
        errorMessage = 'Sesi login Anda sudah terlalu lama. Silakan logout dan login kembali untuk mengubah password.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      // Handle error penyimpanan notifikasi atau error lainnya
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pengaturan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Future<void> _saveNotificationSetting(bool enabled) async {
  //   // Implementasi simpan data notifikasi
  // }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Warna field disesuaikan tema gelap
    final fieldColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800.withOpacity(0.5)
        : Colors.grey.shade200;
    final textColor = theme.textTheme.bodyLarge!.color;
    final iconColor = Colors.grey.shade400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Aksi notifikasi jika perlu
            },
          ),
        ],
        // Styling AppBar agar sesuai gambar
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false, // Judul rata kiri
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Field Email (Read Only) ---
            TextField(
              controller: _emailController,
              readOnly: true, // Tidak bisa diubah
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: fieldColor, // Warna latar field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                 focusedBorder: OutlineInputBorder( // Border saat focus
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
              ),
              style: TextStyle(color: textColor?.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),

            // --- Field Ganti Password ---
            TextField(
              controller: _newPasswordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Ganti Password',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                hintText: 'Masukkan password baru',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: fieldColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                 focusedBorder: OutlineInputBorder( // Border saat focus
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 24),

            // --- Toggle Notifikasi Push ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: fieldColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active_outlined, color: iconColor),
                      const SizedBox(width: 12),
                      Text('Notifikasi Push', style: TextStyle(color: textColor, fontSize: 16)),
                    ],
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeTrackColor: Colors.blueAccent.shade100,
                    activeColor: Colors.blueAccent.shade700,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Tombol Simpan ---
             _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Warna biru
                      foregroundColor: Colors.white, // Teks putih
                      minimumSize: const Size(double.infinity, 50), // Lebar penuh
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Simpan Pengaturan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}