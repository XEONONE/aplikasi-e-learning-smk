import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  // SEMUA VARIABEL HARUS ADA DI DALAM CLASS INI
  final _formKey = GlobalKey<FormState>();
  final _nipNisnController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isVerified = false;
  String _userName = '';

  // SEMUA FUNGSI JUGA HARUS ADA DI DALAM CLASS INI
  Future<void> _verifyNipNisn() async {
    if (_nipNisnController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_nipNisnController.text.trim())
          .get();

      if (!mounted) return;

      String errorMessage = ''; // Variabel untuk pesan error saja
      bool isSuccess = false;

      if (!userDoc.exists) {
        errorMessage = 'NIP/NISN tidak terdaftar.';
      } else {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data['uid'] != null && data['uid'] != '') {
          errorMessage = 'Akun ini sudah aktif. Silakan login.';
        } else {
          // Jika sukses, cukup ubah state tanpa menampilkan notifikasi
          isSuccess = true;
          setState(() {
            _isVerified = true;
            _userName = data['nama'] ?? '[Nama tidak ditemukan]';
          });
        }
      }

      // HANYA tampilkan notifikasi jika GAGAL (isSuccess adalah false)
      if (!isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _activateAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String result = await _authService.activateAccount(
        nipNisn: _nipNisnController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      final isSuccess = result == 'Sukses';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSuccess ? 'Aktivasi berhasil! Anda akan dialihkan.' : result,
          ),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
        ),
      );

      if (isSuccess) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nipNisnController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aktivasi Akun')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isVerified) ...[
                  const Text(
                    'Masukkan NIP atau NISN Anda untuk memulai proses aktivasi.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nipNisnController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'NIP / NISN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _verifyNipNisn,
                          child: const Text('Verifikasi'),
                        ),
                ],
                if (_isVerified) ...[
                  Text(
                    'Akun untuk "$_userName" ditemukan. Silakan buat password baru Anda.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password minimal harus 6 karakter.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Password tidak cocok.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _activateAccount,
                          child: const Text('AKTIFKAN AKUN'),
                        ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
