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

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    String result = await _authService.login(
      nipNisn: _nipNisnController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result != 'Sukses') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.red,
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
      appBar: AppBar(title: const Text('Login E-Learning')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kolom Input NIP / NISN
              TextFormField(
                controller: _nipNisnController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'NIP / NISN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Kolom Input Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Login
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('LOGIN'),
                    ),
              const SizedBox(height: 12),

              // Tombol Aktivasi
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ActivationScreen()),
                  );
                },
                child: const Text('Belum punya akun? Aktivasi di sini'),
              )
            ],
          ),
        ),
      ),
    );
  }
}