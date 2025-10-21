import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/create_announcement_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/announcement_card.dart'; // Import AnnouncementCard
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GuruHomeScreen extends StatefulWidget {
  const GuruHomeScreen({super.key});

  @override
  State<GuruHomeScreen> createState() => _GuruHomeScreenState();
}

class _GuruHomeScreenState extends State<GuruHomeScreen> {
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Helper widget untuk membuat kartu ringkasan
  Widget _buildSummaryCard(IconData icon, String label,
      Stream<QuerySnapshot> stream, Color iconColor) {
    return Expanded(
      child: Card(
        // elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: stream,
                    builder: (context, snapshot) {
                      // Filter by UID guru jika diperlukan
                      // final count = snapshot.data?.docs.where((doc) => doc['dibuatOlehUid'] == currentUser?.uid).length ?? 0;
                      final count = snapshot.data?.docs.length ?? 0; // Total
                      return Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ambil tema

    return Scaffold(
      // Background diset di main.dart
      body: FutureBuilder<UserModel?>(
        future: _authService.getUserData(currentUser!.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Gagal memuat data guru.'));
          }

          final user = userSnapshot.data!;
          final initial =
              user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?';

          // ++ GUNAKAN SINGLECHILDSCROLLVIEW ++
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Padding utama
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- BAGIAN HEADER --
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[700],
                      child: Text(
                        initial,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang,',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[400]),
                        ),
                        Text(
                          user.nama,
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    // Spacer(),
                    // IconButton(
                    //   icon: Icon(Icons.notifications_none, color: Colors.grey[400]),
                    //   onPressed: () {},
                    // ),
                  ],
                ),
                const SizedBox(height: 24),
                // Card sapaan yang lebih besar
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang, Bpk. ${user.nama.split(' ').first}!',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        if (user.mengajarKelas != null &&
                            user.mengajarKelas!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Mengajar: ${user.mengajarKelas!.join(', ')}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[400]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // -- BAGIAN RINGKASAN --
                Row(
                  children: [
                    _buildSummaryCard(
                      Icons.library_books, // Icon buku
                      'Total Materi',
                      FirebaseFirestore.instance
                          .collection('materi')
                          // .where('dibuatOlehUid', isEqualTo: currentUser?.uid) // Filter by guru
                          .snapshots(),
                      Colors.green.shade400, // Warna hijau
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      Icons.edit_note, // Icon pensil/catatan
                      'Total Tugas',
                      FirebaseFirestore.instance
                          .collection('tugas')
                          // .where('dibuatOlehUid', isEqualTo: currentUser?.uid) // Filter by guru
                          .snapshots(),
                      Colors.orange.shade400, // Warna orange/kuning
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // -- BAGIAN PENGUMUMAN --
                Text(
                  'Pengumuman Terkini',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pengumuman')
                      .where('untukKelas',
                          whereIn: [...?user.mengajarKelas, 'Semua Kelas'])
                      .orderBy('dibuatPada', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Belum ada pengumuman.',
                              style: TextStyle(color: Colors.grey)));
                    }
                    if (snapshot.hasError) {
                      print("Error loading announcements: ${snapshot.error}");
                      return const Center(
                          child: Text('Gagal memuat pengumuman.',
                              style: TextStyle(color: Colors.red)));
                    }

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return AnnouncementCard(
                          judul: data['judul'] ?? 'Tanpa Judul',
                          isi: data['isi'] ?? 'Tidak ada isi.',
                          dibuatPada:
                              data['dibuatPada'] ?? Timestamp.now(),
                          dibuatOlehUid: data['dibuatOlehUid'] ?? '',
                          untukKelas: data['untukKelas'] ?? 'Tidak diketahui',
                        );
                      }).toList(),
                    );
                  },
                ),
                // -- AKHIR BAGIAN PENGUMUMAN --

                const SizedBox(
                    height: 80), // Ruang untuk FAB
              ],
            ),
          );
        },
      ),
      // Tombol FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateAnnouncementScreen()),
          );
        },
        label: const Text('Buat Pengumuman'),
        icon: const Icon(Icons.campaign),
      ),
    );
  }
}