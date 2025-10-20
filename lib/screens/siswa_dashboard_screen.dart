// lib/screens/siswa_dashboard_screen.dart

import 'package:aplikasi_e_learning_smk/screens/student_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_materi_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_task_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_nilai_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/services/notification_service.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'package:flutter/material.dart';

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  int _selectedIndex = 0;

  // ++ 2. TAMBAHKAN BLOK KODE INITSTATE INI ++
  @override
  void initState() {
    super.initState();
    // Inisialisasi layanan notifikasi saat pengguna masuk ke dasbor
    NotificationService().initialize();
  }
  // ++ AKHIR PERUBAHAN ++

  static const List<Widget> _pages = <Widget>[
    StudentHomeScreen(),
    StudentMateriListScreen(),
    StudentTaskListScreen(),
    StudentNilaiScreen(),
  ];

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
