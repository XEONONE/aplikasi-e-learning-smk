// lib/screens/student_home_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/account_settings_screen.dart';
// import 'package:aplikasi_e_learning_smk/screens/student_materi_list_screen.dart'; // <-- Hapus import ini, sudah tidak perlu
import 'package:aplikasi_e_learning_smk/screens/task_detail_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Widget utama untuk halaman beranda siswa
class StudentHomeScreen extends StatefulWidget {
  // --- PERUBAHAN 1: Tambahkan parameter callback ---
  final VoidCallback onLihatSemuaMateri;

  // --- PERUBAHAN 2: Update constructor ---
  const StudentHomeScreen({
    super.key,
    required this.onLihatSemuaMateri,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  late Future<UserModel?> _userFuture;
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _userFuture = _authService.getUserData(currentUser!.uid);
    }
  }

  // --- WIDGET KARTU RINGKASAN MATERI & TUGAS ---
  Widget _buildSummaryCard(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET KARTU RINGKASAN MATA PELAJARAN ---
  Widget _buildSubjectCard(
      IconData icon, String subject, String progress, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.8, // Contoh progress 80%
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU TUGAS MENDATANG ---
  Widget _buildUpcomingTaskCard(String title, String deadline) {
    // !! CONTOH DATA STATIS - HARUS DIAMBIL DARI FIREBASE !!
    // Anda perlu query ke 'tugas' dan ambil data sebenarnya
    // Ini hanyalah placeholder
    const String placeholderTaskId = "id_tugas_contoh";
    final Map<String, dynamic> placeholderTaskData = {
      'judul': title,
      'deskripsi': 'Deskripsi placeholder untuk tugas ini.',
      'tenggatWaktu': Timestamp.now(), // Ganti dengan tenggat sebenarnya
      'fileUrl': null,
      'untukKelas': 'Kelas Contoh',
      'dibuatPada': Timestamp.now(),
      'dibuatOlehUid': 'uid_guru_contoh',
      'mataPelajaran': 'Mapel Contoh',
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.assignment_outlined, color: Colors.orange),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(deadline, style: TextStyle(color: Colors.grey[400])),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // --- NAVIGASI KE DETAIL TUGAS ---
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                taskId: placeholderTaskId, // Ganti dengan ID tugas asli
                taskData: placeholderTaskData, // Ganti dengan data tugas asli
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }
    final theme = Theme.of(context);

    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final user = userSnapshot.data!;
        final userKelas = user.kelas;
        final initial = user.nama.isNotEmpty
            ? user.nama.split(' ').map((e) => e[0]).take(2).join()
            : '?';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                      initial.toUpperCase(),
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
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.notifications_none, color: Colors.grey[400]),
                    onPressed: () {},
                    tooltip: 'Notifikasi',
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: Colors.grey[400]),
                    onPressed: () {
                      // --- NAVIGASI KE PENGATURAN ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSettingsScreen(),
                        ),
                      );
                    },
                    tooltip: 'Pengaturan',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // -- KARTU SAPAAN DAN KELAS --
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userKelas ?? 'Kelas Tidak Diketahui',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Semangatmu hari ini adalah kunci kesuksesan di masa depan!',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // -- RINGKASAN MATERI & TUGAS --
              Row(
                children: [
                  _buildSummaryCard(Icons.library_books_outlined, 'Materi', '12/20', Colors.green.shade400),
                  const SizedBox(width: 16),
                  _buildSummaryCard(Icons.edit_note_outlined, 'Tugas', '5/8', Colors.orange.shade400),
                ],
              ),
              const SizedBox(height: 32),

              // -- DAFTAR MATA PELAJARAN --
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mata Pelajaran',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextButton(
                    // --- PERUBAHAN 3: Ganti onPressed dengan callback ---
                    onPressed: widget.onLihatSemuaMateri,
                    child: const Text('Lihat Semua'),
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Contoh Card Mapel (Gantilah dengan data dinamis nanti)
              _buildSubjectCard(Icons.computer_outlined, 'Informatika', 'Progress 8 dari 10 modul', Colors.blue.shade400),
              const SizedBox(height: 12),
              _buildSubjectCard(Icons.calculate_outlined, 'Matematika', 'Progress 8 dari 12 modul', Colors.green.shade400),
              const SizedBox(height: 32),

              // -- TUGAS MENDATANG --
              Text(
                'Tugas Mendatang',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              // Contoh Card Tugas Mendatang (Gantilah dengan data dinamis nanti)
              _buildUpcomingTaskCard('Tugas Algoritma Dasar', 'Tenggat: 25 Okt 2025'),
              const SizedBox(height: 12),
              _buildUpcomingTaskCard('Latihan Soal Vektor', 'Tenggat: 28 Okt 2025'),
            ],
          ),
        );
      },
    );
  }
}

// Widget untuk menampilkan kartu pengumuman (Tidak ada perubahan di sini)
// ... (Kode AnnouncementCard tetap sama) ...
class AnnouncementCard extends StatefulWidget {
  final String judul;
  final String isi;
  final Timestamp dibuatPada;
  final String dibuatOlehUid;

  const AnnouncementCard({
    super.key,
    required this.judul,
    required this.isi,
    required this.dibuatPada,
    required this.dibuatOlehUid,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  late Future<String> _authorNameFuture;

  @override
  void initState() {
    super.initState();
    _authorNameFuture = _getAuthorName(widget.dibuatOlehUid);
  }

  Future<String> _getAuthorName(String uid) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data()['nama'] ?? 'Admin';
      }
      return 'Admin';
    } catch (e) {
      return 'Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'd MMMM yyyy, HH:mm', 'id_ID'
    ).format(widget.dibuatPada.toDate());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.judul,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _authorNameFuture,
              builder: (context, snapshot) {
                return Text(
                  'Diposting oleh ${snapshot.data ?? "..."} • $formattedDate',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                );
              },
            ),
            const Divider(height: 24),
            Text(widget.isi, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}