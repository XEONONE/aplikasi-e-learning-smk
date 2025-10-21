import 'package:aplikasi_e_learning_smk/screens/activation_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPasswordVisible = false; // State untuk melihat password

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // PENTING:
      // Firebase Auth menggunakan email. Kita akan "mengubah" NIP/NISN
      // menjadi format email yang valid untuk Firebase.
      // GANTI 'domain.sekolah' DENGAN DOMAIN EMAIL SEKOLAH ANDA.
      String email = '${_idController.text}@domain.sekolah';

      try {
        User? user = await _authService.signInWithEmailAndPassword(
          email,
          _passwordController.text,
        );

        if (user == null && mounted) {
          setState(() {
            _errorMessage = 'Login gagal. Periksa kembali ID dan password Anda.';
            _isLoading = false;
          });
        }
        // Jika login berhasil, AuthGate akan mendeteksi perubahan
        // dan secara otomatis mengarahkan pengguna ke dasbor.
        // Kita tidak perlu setState atau navigasi manual di sini jika berhasil.
      } catch (e) {
        // Menangkap error spesifik dari Firebase
        String friendlyMessage;
        if (e.toString().contains('invalid-credential')) {
          friendlyMessage = 'NIP/NISN atau Password salah.';
        } else if (e.toString().contains('user-not-found')) {
          friendlyMessage = 'Pengguna tidak ditemukan.';
        } else if (e.toString().contains('wrong-password')) {
          friendlyMessage = 'Password salah.';
        } else {
          friendlyMessage = 'Terjadi error. Coba lagi nanti.';
        }

        if (mounted) {
          setState(() {
            _errorMessage = friendlyMessage;
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_elearning.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logo_sekolah.png',
                          height: 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'E-Learning SMK',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _idController,
                          decoration: const InputDecoration(
                            labelText: 'NIP / NISN',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan NIP / NISN';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text('LOGIN'),
                                ),
                              ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ActivationScreen(),
                              ),
                            );
                          },
                          child: const Text('Aktivasi Akun di Sini'),
                        ),
                      ],
                    ),
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