import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/create_announcement_screen.dart'; // Halaman untuk buat pengumuman
import 'package:aplikasi_e_learning_smk/screens/guru_home_screen.dart'; // Halaman Beranda baru
import 'package:aplikasi_e_learning_smk/screens/guru_materi_list_screen.dart'; // (Akan kita rombak di tahap selanjutnya)
import 'package:aplikasi_e_learning_smk/screens/guru_profile_screen.dart'; // Halaman Profil baru (Akan kita buat)
import 'package:aplikasi_e_learning_smk/screens/task_list_screen.dart'; // (Akan kita rombak di tahap selanjutnya)
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Definisikan warna utama
const Color kPrimaryColor = Color(0xFF4F46E5); // Indigo-600
const Color kBackgroundColor = Color(0xFFF3F4F6); // Gray-100/50

class GuruDashboardScreen extends StatefulWidget {
  final UserModel userModel;
  const GuruDashboardScreen({super.key, required this.userModel});

  @override
  State<GuruDashboardScreen> createState() => _GuruDashboardScreenState();
}

class _GuruDashboardScreenState extends State<GuruDashboardScreen> {
  int _selectedIndex = 0; // 0: Beranda, 1: Materi, 2: Tugas, 3: Profil
  late PageController _pageController;

  // Daftar halaman untuk navigasi
  late List<Widget> _pages;

  // Daftar konfigurasi untuk AppBar
  final List<Map<String, dynamic>> _pageConfigs = [
    {'subtitle': 'Selamat datang,', 'titleKey': 'nama', 'showAvatar': true, 'showBack': false},
    {'subtitle': 'Manajemen', 'titleKey': 'Materi', 'showAvatar': false, 'showBack': false},
    {'subtitle': 'Manajemen', 'titleKey': 'Tugas', 'showAvatar': false, 'showBack': false},
    {'subtitle': 'Akun Saya', 'titleKey': 'Profil', 'showAvatar': false, 'showBack': false},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    // Inisialisasi daftar halaman
    _pages = [
      GuruHomeScreen(userModel: widget.userModel), // Halaman Beranda baru
      GuruMateriListScreen(userModel: widget.userModel), // Halaman Materi (perlu dirombak)
      TaskListScreen(userModel: widget.userModel), // Halaman Tugas (perlu dirombak)
      GuruProfileScreen(userModel: widget.userModel), // Halaman Profil (akan dibuat)
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Langsung pindah tanpa animasi
  }

  // Fungsi untuk logout
  void _showLogoutDialog() {
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

  // Kustom AppBar sesuai desain
  AppBar _buildAppBar() {
    final config = _pageConfigs[_selectedIndex];
    final title = config['titleKey'] == 'nama' ? widget.userModel.nama : config['titleKey'];

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1, // Shadow tipis
      automaticallyImplyLeading: false, // Hilangkan tombol back default
      title: Row(
        children: [
          // Tampilkan Avatar di Beranda
          if (config['showAvatar'])
            CircleAvatar(
              radius: 20,
              backgroundColor: kPrimaryColor.withOpacity(0.2),
              // Ganti dengan NetworkImage jika user punya foto profil
              child: Text(
                widget.userModel.nama.substring(0, 2).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
            ),
          // Tampilkan Tombol Back (jika diperlukan halaman detail nanti)
          if (config['showBack'])
             IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () { /* Logika back */ },
            ),

          if (config['showAvatar']) const SizedBox(width: 12),

          // Judul dan Subjudul
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config['subtitle'],
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Tombol Logout di header
        IconButton(
          icon: const Icon(Icons.logout_outlined, color: Colors.redAccent, size: 26),
          onPressed: _showLogoutDialog,
        ),
        const SizedBox(width: 10), // Padding
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Matikan swipe antar halaman
        children: _pages,
      ),
      // Tombol FAB
      floatingActionButton: _selectedIndex == 0 // Hanya tampil di Beranda
          ? FloatingActionButton(
              onPressed: () {
                // Navigasi ke halaman Buat Pengumuman
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAnnouncementScreen(userModel: widget.userModel),
                  ),
                );
              },
              backgroundColor: kPrimaryColor,
              child: const Icon(Icons.campaign, color: Colors.white), // Ikon bullhorn
            )
          : null, // Sembunyikan di halaman lain

      // Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor, // Warna item aktif
        unselectedItemColor: Colors.grey[600], // Warna item non-aktif
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Tipe agar label selalu tampil
        backgroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
}
