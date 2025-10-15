// lib/screens/siswa_dashboard_screen.dart

import 'package:aplikasi_e_learning_smk/screens/student_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_materi_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_task_list_screen.dart';
// HAPUS: import 'package:aplikasi_e_learning_smk/screens/student_nilai_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/material.dart';

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  int _selectedIndex = 0;

  // --- PERUBAHAN DI SINI ---
  final List<Widget> _pages = [
    const StudentHomeScreen(),
    const StudentMateriListScreen(),
    const StudentTaskListScreen(),
    // HAPUS: const StudentNilaiScreen(),
  ];

  final List<String> _pageTitles = [
    'Beranda',
    'Materi Pelajaran',
    'Daftar Tugas',
    // HAPUS: 'Daftar Nilai',
  ];
  // --- AKHIR PERUBAHAN ---

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
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // --- PERUBAHAN DI SINI ---
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materi'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tugas'),
          // HAPUS: BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Nilai'),
        ],
        // --- AKHIR PERUBAHAN ---
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
