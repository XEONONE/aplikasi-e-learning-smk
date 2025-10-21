// lib/screens/siswa_dashboard_screen.dart

import 'package:aplikasi_e_learning_smk/screens/student_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_materi_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_task_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_nilai_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/services/notification_service.dart';
import 'package:flutter/material.dart';

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  int _selectedIndex = 0;

  // --- PERUBAHAN 1: Deklarasi _pages di sini ---
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    NotificationService().initialize();

    // --- PERUBAHAN 2: Inisialisasi _pages di dalam initState ---
    _pages = <Widget>[
      StudentHomeScreen(
        // --- PERUBAHAN 3: Tambahkan callback ini ---
        // Ini akan memanggil _onItemTapped(1) saat tombol ditekan
        onLihatSemuaMateri: () => _onItemTapped(1),
      ),
      const StudentMateriListScreen(),
      const StudentTaskListScreen(),
      const StudentNilaiScreen(),
    ];
  }

  // --- PERUBAHAN 4: Hapus 'static const List<Widget> _pages' dari sini ---

  static const List<String> _pageTitles = <String>[
    'Beranda',
    'Materi',
    'Tugas',
    'Nilai',
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
        title: Text(_pageTitles[_selectedIndex]),
        actions: [
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      // --- PERUBAHAN 5: Pastikan body menggunakan _pages (non-static) ---
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.grade_outlined),
            activeIcon: Icon(Icons.grade),
            label: 'Nilai',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}