import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/student_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_materi_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_profile_screen.dart'; // Akan kita buat nanti
import 'package:aplikasi_e_learning_smk/screens/student_task_list_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Definisikan warna utama
const Color kPrimaryColor = Color(0xFF4F46E5); // Indigo-600
const Color kBackgroundColor = Color(0xFFF3F4F6); // Gray-100/50

class SiswaDashboardScreen extends StatefulWidget {
  final UserModel userModel;
  const SiswaDashboardScreen({super.key, required this.userModel});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  int _selectedIndex = 0; // 0: Beranda, 1: Materi, 2: Tugas, 3: Profil
  late PageController _pageController;

  // Daftar halaman untuk navigasi
  late List<Widget> _pages;

  // Daftar konfigurasi untuk AppBar
  final List<Map<String, dynamic>> _pageConfigs = [
    {'subtitle': 'Selamat datang,', 'titleKey': 'nama', 'showAvatar': true, 'showBack': false},
    {'subtitle': 'Daftar', 'titleKey': 'Mata Pelajaran', 'showAvatar': false, 'showBack': false},
    {'subtitle': 'Daftar', 'titleKey': 'Tugas', 'showAvatar': false, 'showBack': false},
    {'subtitle': 'Akun Saya', 'titleKey': 'Profil', 'showAvatar': false, 'showBack': false},
    // Konfigurasi untuk halaman non-nav
    {'subtitle': 'Aktivitas Terbaru', 'titleKey': 'Notifikasi', 'showAvatar': false, 'showBack': true},
    {'subtitle': 'Detail', 'titleKey': 'Tugas', 'showAvatar': false, 'showBack': true},
    // ...tambahkan config lain jika ada halaman detail
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Inisialisasi daftar halaman
    _pages = [
      StudentHomeScreen(userModel: widget.userModel), // Halaman Beranda baru (akan dibuat)
      StudentMateriListScreen(kelasId: widget.userModel.kelas ?? ''), // Halaman Materi (akan dirombak)
      StudentTaskListScreen(kelasId: widget.userModel.kelas ?? '', siswaId: widget.userModel.id), // Halaman Tugas (akan dirombak)
      StudentProfileScreen(userModel: widget.userModel), // Halaman Profil (akan dibuat)
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
    _pageController.jumpToPage(index); // Langsung pindah
  }

  // Kustom AppBar sesuai desain
  AppBar _buildAppBar() {
    // Navigasi Non-Standar (misal: Notifikasi) akan ditangani di luar widget ini
    // Di sini kita hanya menangani 4 tab utama
    final config = _pageConfigs[_selectedIndex];
    final title = config['titleKey'] == 'nama' ? widget.userModel.nama : config['titleKey'];
    
    // Tampilkan inisial nama
    String initials = widget.userModel.nama.isNotEmpty
        ? widget.userModel.nama.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'S';

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
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
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
        // Hanya tampilkan tombol search & notif di Beranda (sesuai HTML)
        if (_selectedIndex == 0) ...[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54, size: 26),
            onPressed: () {
               // TODO: Tampilkan modal/halaman search
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Pencarian belum dibuat.')),
                );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black54, size: 26),
            onPressed: () {
              // TODO: Navigasi ke halaman Notifikasi
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Halaman Notifikasi belum dibuat.')),
                );
              // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen()));
            },
          ),
          const SizedBox(width: 10),
        ]
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
        physics: const NeverScrollableScrollPhysics(), // Matikan swipe
        children: _pages,
      ),
      
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