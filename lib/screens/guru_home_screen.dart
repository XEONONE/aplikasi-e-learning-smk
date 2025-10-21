import 'package:aplikasi_e_learning_smk/screens/create_announcement_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GuruHomeScreen extends StatefulWidget {
  const GuruHomeScreen({super.key});

  @override
  State<GuruHomeScreen> createState() => _GuruHomeScreenState();
}

class _GuruHomeScreenState extends State<GuruHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _guruId = AuthService().getCurrentUser()?.uid ?? '';

  // Fungsi untuk membuat widget kartu statistik
  Widget _buildStatCard(String title, Stream<int> stream) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<int>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.hasError) {
                  return const Text(
                    '0',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  );
                }
                return Text(
                  snapshot.data.toString(),
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Stream untuk menghitung jumlah siswa yang diajar guru
  Stream<int> _getSiswaCountStream() {
    // Implementasi ini bergantung pada bagaimana Anda menstrukturkan data 'kelas'
    // Asumsi sederhana: menghitung semua siswa
    // Implementasi lebih baik: menghitung siswa di kelas yang diajar guru
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'siswa')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Stream untuk menghitung jumlah materi yang dibuat guru
  Stream<int> _getMateriCountStream() {
    return _firestore
        .collection('materi')
        .where('guruId', isEqualTo: _guruId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Stream untuk menghitung jumlah tugas yang dibuat guru
  Stream<int> _getTugasCountStream() {
    return _firestore
        .collection('tugas')
        .where('guruId', isEqualTo: _guruId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildStatCard('Total Siswa', _getSiswaCountStream()),
            _buildStatCard('Total Materi', _getMateriCountStream()),
            _buildStatCard('Total Tugas', _getTugasCountStream()),
            // Anda bisa tambahkan kartu lain jika perlu
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateAnnouncementScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_alert),
        label: const Text('Buat Pengumuman'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}