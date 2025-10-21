import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/guru_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/guru_materi_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/login_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/task_list_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GuruDashboardScreen extends StatefulWidget {
  const GuruDashboardScreen({super.key});

  @override
  State<GuruDashboardScreen> createState() => _GuruDashboardScreenState();
}

class _GuruDashboardScreenState extends State<GuruDashboardScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  late Future<UserModel?> _userDataFuture;
  late String _guruId;

  // Daftar halaman untuk navigasi
  final List<Widget> _pages = [
    const GuruHomeScreen(),
    const GuruMateriListScreen(),
    const TaskListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Mengambil data user saat ini
    User? user = _authService.getCurrentUser();
    if (user != null) {
      _guruId = user.uid;
      _userDataFuture = _authService.getUserData(_guruId);
    } else {
      // Jika user null (seharusnya tidak terjadi di sini),
      // kita set future error
      _userDataFuture = Future.value(null);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    // Tampilkan dialog konfirmasi
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await _authService.signOut();
      if (mounted) {
        // Navigasi ke LoginScreen dan hapus semua rute sebelumnya
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<UserModel?>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Memuat...');
            }
            if (snapshot.hasData && snapshot.data != null) {
              // Tampilkan nama guru di AppBar
              return Text('Selamat Datang, ${snapshot.data!.nama}');
            }
            return const Text('Dasbor Guru');
          },
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}