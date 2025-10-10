import 'package:aplikasi_e_learning_smk/screens/activation_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nipNisnController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _login() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    String result = await _authService.login(
      nipNisn: _nipNisnController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Pastikan widget masih ada sebelum mengubah state
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result != 'Sukses') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    // Jika sukses, AuthGate akan otomatis pindah halaman
  }

  @override
  void dispose() {
    _nipNisnController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Latar belakang dengan gradasi
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade200, Colors.indigo.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            // ⭐ 1. Gunakan SizedBox untuk membatasi lebar Card
            child: SizedBox(
              width: 400, // Lebar kotak login disesuaikan
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ⭐ 2. Menambahkan logo dari URL
                      Image.network(
                        'https://elearning.bsi.ac.id/assets/img/mybest_3.png',
                        height: 50, // Sesuaikan tinggi logo
                        errorBuilder: (context, error, stackTrace) {
                          // Tampilkan judul jika logo gagal dimuat
                          return const Text(
                            'E-Learning App',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Input field NIP/NISN
                      TextFormField(
                        controller: _nipNisnController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'NIP / NISN',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input field Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ⭐ 3. Menambahkan tombol "Lupa Password?"
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Buat halaman atau fungsi untuk lupa password
                          },
                          child: const Text('Lupa Password?'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Login
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 5.0,
                              ),
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),

                      // Tombol Aktivasi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Belum punya akun?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ActivationScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Aktivasi di sini',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
