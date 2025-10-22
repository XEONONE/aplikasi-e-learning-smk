// lib/screens/siswa_dashboard_screen.dart

import 'package:aplikasi_e_learning_smk/screens/student_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_materi_list_screen.dart';
// Halaman lama yang dihapus
// import 'package:aplikasi_e_learning_smk/screens/student_task_list_screen.dart';
// import 'package:aplikasi_e_learning_smk/screens/student_nilai_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/services/notification_service.dart';
import 'package:flutter/material.dart';

// Halaman baru yang ditambahkan
import 'package:aplikasi_e_learning_smk/screens/student_graded_tasks_screen.dart'; // Halaman Tugas (Aktif/Selesai)
import 'package:aplikasi_e_learning_smk/screens/profile_screen.dart'; // Halaman Profil Baru

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  int _selectedIndex = 0;
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    NotificationService().initialize();

    // --- PERUBAHAN 1: Daftar halaman disesuaikan ---
    // Sekarang ada 4 halaman: Beranda, Materi, Tugas (baru), Profil (baru)
    _pages = <Widget>[
      StudentHomeScreen(
        onLihatSemuaMateri: () => _onItemTapped(1),
      ),
      const StudentMateriListScreen(),
      const StudentGradedTasksScreen(), // Halaman tugas baru
      const ProfileScreen(),          // Halaman profil baru
    ];
  }

  // --- PERUBAHAN 2: Daftar judul disesuaikan ---
  static const List<String> _pageTitles = <String>[
    'Beranda',
    'Materi',
    'Tugas',
    'Profil', // Judul untuk halaman profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex < _pageTitles.length 
            ? _pageTitles[_selectedIndex]
            : 'E-Learning'), // AppBar akan ganti judul sesuai tab
        actions: [
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      
      // --- PERUBAHAN 3: Tombol navigasi disesuaikan ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem( // Tombol profil baru
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}