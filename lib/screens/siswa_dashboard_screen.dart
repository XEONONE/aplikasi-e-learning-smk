// lib/screens/siswa_dashboard_screen.dart

import 'package:aplikasi_e_learning_smk/screens/student_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_materi_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_task_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_nilai_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_e_learning_smk/screens/loading_screen.dart'; // <-- TAMBAHKAN IMPORT INI

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _pageTitles = [
    'Beranda',
    'Materi',
    'Tugas',
    'Nilai',
  ];

  final List<Widget> _pages = [
    const StudentHomeScreen(),
    const StudentMateriListScreen(),
    const StudentTaskListScreen(),
    const StudentNilaiScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoadingScreen(
            destinationPage: Scaffold(
              appBar: AppBar(
                title: Text(_pageTitles[index]),
                 actions: [
                  IconButton(
                    onPressed: () => AuthService().signOut(),
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: _pages[index],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    label: 'Materi',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment),
                    label: 'Tugas',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grade),
                    label: 'Nilai',
                  ),
                ],
                currentIndex: index,
                onTap: _onItemTapped,
              ),
            ),
          ),
        ),
      ).then((_) {
        // Setelah kembali dari halaman loading, set state di sini jika diperlukan
        // Namun karena kita menggunakan push, halaman ini akan tetap ada di stack
        // Untuk pengalaman yang lebih baik, mungkin perlu refaktor cara navigasi
      });
    }
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
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: 'Nilai',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}