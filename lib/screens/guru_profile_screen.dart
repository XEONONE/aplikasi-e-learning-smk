import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart'; 

class GuruProfileScreen extends StatelessWidget {
  final UserModel userModel;
  const GuruProfileScreen({super.key, required this.userModel});

  // Fungsi untuk menampilkan dialog logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 40),
            SizedBox(height: 16),
            Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar?', textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Provider.of<AuthService>(context, listen: false).signOut(); // Logout
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Info Profil Atas
            _buildProfileHeader(context),
            const SizedBox(height: 32),

            // 2. Menu Pilihan
            _buildMenuList(context),
            const SizedBox(height: 32),

            // 3. Tombol Keluar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk header profil
  Widget _buildProfileHeader(BuildContext context) {
    // Ambil inisial nama
    String initials = userModel.nama.isNotEmpty
        ? userModel.nama.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'G';

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: kPrimaryColor.withOpacity(0.2),
          // TODO: Ganti dengan NetworkImage jika user punya foto profil
          child: Text(
            initials.toUpperCase(),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userModel.nama,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          'NIP: ${userModel.id}', // Menggunakan field 'id' dari Firestore
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          "Guru ${userModel.mengajarKelas?.join(', ') ?? 'Pelajaran'}", // Menampilkan info mengajar
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  // Widget untuk daftar menu
  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context: context,
          title: 'Edit Profil',
          icon: Icons.edit_outlined,
          onTap: () {
            // TODO: Navigasi ke Halaman Edit Profil
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halaman Edit Profil belum dibuat.')),
            );
            // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          context: context,
          title: 'Pengaturan Akun',
          icon: Icons.settings_outlined,
          onTap: () {
             // TODO: Navigasi ke Halaman Pengaturan Akun
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Halaman Pengaturan Akun belum dibuat.')),
            );
            // Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettingsScreen()));
          },
        ),
      ],
    );
  }

  // Widget template untuk item menu
  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(12),
             boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
             ],
           ),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}