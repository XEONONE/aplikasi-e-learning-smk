// lib/screens/profile_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/account_settings_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/edit_profile_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/custom_loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _userFuture = _authService.getUserData(currentUser!.uid);
    } else {
      // Jika tidak ada user, buat Future yang langsung selesai dengan null
      _userFuture = Future.value(null);
    }
  }

  // Fungsi untuk refresh data user setelah edit
  void _refreshUserData() {
    if (currentUser != null) {
      setState(() {
        _userFuture = _authService.getUserData(currentUser!.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar disesuaikan dengan desain
      appBar: AppBar(
        automaticallyImplyLeading: false, // Sembunyikan tombol back default
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun Saya',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[400],
              ),
            ),
            const Text(
              'Profil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Aksi notifikasi jika perlu
            },
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[400]),
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoadingIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat data profil.'));
          }

          final user = snapshot.data!;
          // Inisial nama (maksimal 2 huruf)
          final initial = user.nama.isNotEmpty
              ? user.nama.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
              : '?';
          // Deskripsi peran (Guru/Siswa)
          final String roleDescription;
          if (user.role == 'guru') {
            roleDescription = 'Guru ${user.mengajarKelas?.join(', ') ?? 'Mapel'}';
          } else {
            roleDescription = 'Siswa ${user.kelas ?? 'Kelas tidak diketahui'}';
          }
          final String idLabel = user.role == 'guru' ? 'NIP' : 'NIS';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Center(
              // Batasi lebar konten agar tidak terlalu lebar di layar besar
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Avatar dan Info Pengguna ---
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[700],
                      child: Text(
                        initial.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.nama,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$idLabel: ${user.id}', // Menampilkan NIP/NIS dari user.id
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleDescription, // Tampilkan peran dan kelas/mapel
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Tombol Aksi ---
                    _buildProfileActionTile(
                      icon: Icons.edit_outlined,
                      text: 'Edit Profil',
                      onTap: () async {
                        // Navigasi ke EditProfileScreen
                        final bool? result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(userData: user),
                          ),
                        );
                        // Jika kembali dari EditProfileScreen dan ada hasil 'true', refresh data
                        if (result == true) {
                          _refreshUserData();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildProfileActionTile(
                      icon: Icons.settings_outlined,
                      text: 'Pengaturan Akun',
                      onTap: () {
                        // Navigasi ke AccountSettingsScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // --- Tombol Keluar ---
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Keluar'),
                      onPressed: () async {
                        // Dialog konfirmasi keluar
                        bool? confirmLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi Keluar'),
                              content: const Text(
                                'Apakah Anda yakin ingin keluar?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Keluar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        // Jika dikonfirmasi, panggil signOut
                        if (confirmLogout == true) {
                          await _authService.signOut();
                          // AuthGate akan menangani navigasi setelah logout
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withAlpha(220), // Warna merah
                        foregroundColor: Colors.white, // Teks putih
                        minimumSize: const Size(double.infinity, 50), // Lebar penuh
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget untuk membuat ListTile aksi profil
  Widget _buildProfileActionTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10), // Samakan radius dengan Container
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Warna latar card
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]), // Ikon panah kanan
          ],
        ),
      ),
    );
  }
}