import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController(); // NIP/NISN
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 1; // 1: Verifikasi ID, 2: Buat Password
  bool _isLoading = false;
  String _foundUserName = ""; // Untuk menyimpan nama user yang ditemukan
  
  // Definisikan warna yang konsisten
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color darkPurple = Color(0xFF312E81);
  static const Color lightPurpleText = Color(0xFFD8B4FE);

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk Cek NIP/NISN (Step 1)
  Future<void> _verifyId() async {
    if (_idController.text.trim().isEmpty) {
      _showError('NIP / NISN tidak boleh kosong.');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Kita cek manual ke Firestore apakah user ada dan belum aktif
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: _idController.text.trim()) // Cari berdasarkan 'id'
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _showError('NIP / NISN tidak ditemukan. Hubungi administrator.');
        setState(() { _isLoading = false; });
        return;
      }

      final userData = query.docs.first.data();
      if (userData['isActivated'] == true) {
        _showError('Akun ini sudah aktif. Silakan login.');
        setState(() { _isLoading = false; });
        return;
      }

      // Jika ditemukan dan belum aktif, lanjut ke step 2
      setState(() {
        _isLoading = false;
        _currentStep = 2; // Pindah ke layar buat password
        _foundUserName = userData['nama'] ?? 'Pengguna'; // Simpan nama
      });

    } catch (e) {
      if (kDebugMode) print('Error verifying ID: $e');
      _showError('Terjadi kesalahan saat verifikasi: $e');
      setState(() { _isLoading = false; });
    }
  }

  // Fungsi untuk Aktivasi Akun (Step 2)
  Future<void> _activateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    final authService = Provider.of<AuthService>(context, listen: false);
    final notifService = Provider.of<NotificationService>(context, listen: false);

    try {
      // 1. Dapatkan FCM Token terlebih dahulu
      String? fcmToken = await notifService.getFCMToken();

      // 2. Panggil fungsi activateAccount dari service
      String result = await authService.activateAccount(
        _idController.text.trim(), // 'id' (NIP/NISN)
        _passwordController.text.trim(),
        fcmToken, // Kirim tokennya
      );

      setState(() { _isLoading = false; });

      if (result == 'success') {
        // Tampilkan dialog sukses dan kembali ke login
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Aktivasi Berhasil'),
            content: const Text('Akun Anda telah berhasil diaktivasi. Silakan login.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.of(context).pop(); // Kembali ke LoginScreen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Tampilkan pesan error dari service
        _showError(result);
      }
    } catch (e) {
      if (kDebugMode) print('Error activating account: $e');
      _showError('Terjadi kesalahan: $e');
      setState(() { _isLoading = false; });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // --- Widgets untuk setiap step ---

  Widget _buildStep1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Aktivasi Akun',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan NIP/NISN Anda untuk verifikasi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _idController,
          decoration: _inputDecoration(hint: 'NIP / NISN'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator(color: primaryColor)
            : SizedBox(
                width: double.infinity,
                child: _primaryButton(
                  text: 'Verifikasi',
                  onPressed: _verifyId,
                ),
              ),
      ],
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Buat Password Baru',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Akun untuk "$_foundUserName" ditemukan.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _passwordController,
            decoration: _inputDecoration(hint: 'Password Baru (min. 6 karakter)'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: _inputDecoration(hint: 'Konfirmasi Password'),
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Password tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator(color: primaryColor)
              : SizedBox(
                  width: double.infinity,
                  child: _primaryButton(
                    text: 'Aktifkan Akun',
                    onPressed: _activateAccount,
                  ),
                ),
        ],
      ),
    );
  }

  // --- Helper Widget ---

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  Widget _primaryButton({required String text, required VoidCallback onPressed}) {
     return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih seperti modal
      appBar: AppBar(
        // AppBar agar bisa kembali ke Login
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.close), // Tombol close/batal
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
             constraints: const BoxConstraints(maxWidth: 400),
            // AnimatedSwitcher untuk transisi antar step
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentStep == 1
                  ? _buildStep1() // Tampilkan widget step 1
                  : _buildStep2(), // Tampilkan widget step 2
            ),
          ),
        ),
      ),
    );
  }
}