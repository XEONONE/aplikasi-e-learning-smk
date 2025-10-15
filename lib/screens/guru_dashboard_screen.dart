// lib/screens/guru_dashboard_screen.dart

import 'package:aplikasi_e_learning_smk/screens/guru_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/guru_materi_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/task_list_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:flutter/material.dart';

class GuruDashboardScreen extends StatefulWidget {
  const GuruDashboardScreen({super.key});

  @override
  State<GuruDashboardScreen> createState() => _GuruDashboardScreenState();
}

class _GuruDashboardScreenState extends State<GuruDashboardScreen> {
  int _selectedIndex = 0;
  bool _showExpiredTasks = false;

  final List<String> _pageTitles = [
    'Beranda',
    'Manajemen Materi',
    'Manajemen Tugas',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const GuruHomeScreen(),
      const GuruMateriListScreen(),
      TaskListScreen(showExpired: _showExpiredTasks),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 2)
            IconButton(
              icon: Icon(
                _showExpiredTasks
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              tooltip: _showExpiredTasks
                  ? 'Sembunyikan Tugas Kedaluwarsa'
                  : 'Tampilkan Tugas Kedaluwarsa',
              onPressed: () {
                setState(() {
                  _showExpiredTasks = !_showExpiredTasks;
                });
              },
            ),
          IconButton(
              onPressed: () => AuthService().signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      // ## PERUBAHAN DI SINI: Latar belakang dihapus ##
      body: pages[_selectedIndex],
      // ## AKHIR PERUBAHAN ##
      bottomNavigationBar: BottomNavigationBar(
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
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}