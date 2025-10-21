import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/login_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_home_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_materi_list_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_nilai_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/student_task_list_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SiswaDashboardScreen extends StatefulWidget {
  const SiswaDashboardScreen({super.key});

  @override
  State<SiswaDashboardScreen> createState() => _SiswaDashboardScreenState();
}

class _SiswaDashboardScreenState extends State<SiswaDashboardScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  late Future<UserModel?> _userDataFuture;
  late String _siswaId;
  String _kelasId = ''; // Menyimpan kelas siswa

  // Daftar halaman untuk navigasi
  // Kita perlu menginisialisasinya di initState setelah mendapat _kelasId
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi service notifikasi
    NotificationService().initialize();

    User? user = _authService.getCurrentUser();
    if (user != null) {
      _siswaId = user.uid;
      _userDataFuture = _authService.getUserData(_siswaId);
      // Ambil data user untuk mendapatkan kelasId
      _userDataFuture.then((userData) {
        if (userData != null && userData.kelas != null) {
          setState(() {
            _kelasId = userData.kelas!;
            // Sekarang inisialisasi _pages dengan kelasId
            _pages = [
              StudentHomeScreen(kelasId: _kelasId),
              StudentMateriListScreen(kelasId: _kelasId),
              StudentTaskListScreen(kelasId: _kelasId, siswaId: _siswaId),
              StudentNilaiScreen(siswaId: _siswaId),
            ];
          });
        }
      });
    } else {
      _userDataFuture = Future.value(null);
    }
    // Inisialisasi _pages dengan placeholder selagi menunggu _kelasId
    _pages = [
      const Center(child: CircularProgressIndicator()),
      const Center(child: CircularProgressIndicator()),
      const Center(child: CircularProgressIndicator()),
      const Center(child: CircularProgressIndicator()),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
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
              return Text('Selamat Datang, ${snapshot.data!.nama}');
            }
            return const Text('Dasbor Siswa');
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
        type: BottomNavigationBarType.fixed, // Agar 4 item muat
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
            icon: Icon(Icons.bar_chart),
            label: 'Nilai',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        onTap: _onItemTapped,
      ),
    );
  }
}