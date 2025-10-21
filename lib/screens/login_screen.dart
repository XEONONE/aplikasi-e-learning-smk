import 'package:aplikasi_e_learning_smk/screens/activation_screen.dart'; // Untuk navigasi ke aktivasi
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController(); // Untuk NIP/NISN
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Fungsi untuk menangani login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jangan lakukan apa-apa jika form tidak valid
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Panggil fungsi signInWithIdAndPassword dari service yang sudah diupdate
      await authService.signInWithIdAndPassword(
        _idController.text.trim(), // Gunakan 'id' (NIP/NISN)
        _passwordController.text.trim(),
      );
      
      // Jika berhasil, AuthGate akan otomatis menangani navigasi
      // Tidak perlu setState loading=false di sini karena widget akan di-unmount
      
    } catch (e) {
      if (kDebugMode) {
        print('Login failed: $e');
      }
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Gagal. Periksa NIP/NISN dan Password Anda.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToActivation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ActivationScreen()),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan warna yang sesuai dengan desain
    const Color primaryColor = Color(0xFF6366F1); // ungu muda
    const Color darkPurple = Color(0xFF312E81);  // ungu tua
    const Color lightPurpleText = Color(0xFFD8B4FE); // ungu sangat muda (untuk text)


    return Scaffold(
      body: Container(
        // Background Gradasi
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [darkPurple, primaryColor, Color(0xFF1E1B4B)], // Sesuaikan warna gradasi
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400), // Batasi lebar form
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Sekolah
                    // Pastikan Anda sudah menambahkan 'assets/logo_sekolah.png' di pubspec.yaml
                    Image.asset(
                      'assets/logo_sekolah.png', // GANTI JIKA NAMA FILE BEDA
                      height: 100,
                      // Jika file tidak ada, gunakan placeholder
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.school, color: Colors.white, size: 100);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Judul
                    const Text(
                      'PORTAL E-LEARNING',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'SMK Rahayu Mulya', // Sesuaikan nama sekolah
                      style: TextStyle(
                        fontSize: 14,
                        color: lightPurpleText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Input NIP / NISN
                    TextFormField(
                      controller: _idController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'NIP / NISN',
                        hintStyle: TextStyle(color: lightPurpleText.withOpacity(0.8)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        prefixIcon: const Icon(Icons.person_outline, color: lightPurpleText),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'NIP / NISN tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: lightPurpleText.withOpacity(0.8)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        prefixIcon: const Icon(Icons.lock_outline, color: lightPurpleText),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: lightPurpleText,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                         focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tombol Login
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor, // Warna tombol
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                'SIGN IN',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                    const SizedBox(height: 24),

                    // Link Aktivasi
                    RichText(
                      text: TextSpan(
                        text: 'Belum punya akun? ',
                        style: TextStyle(color: lightPurpleText.withOpacity(0.8), fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Aktivasi di sini',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontSize: 14
                            ),
                            recognizer: TapGestureRecognizer()..onTap = _goToActivation,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}