// lib/screens/student_home_screen.dart
import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/account_settings_screen.dart'; //
import 'package:aplikasi_e_learning_smk/screens/task_detail_screen.dart'; //
import 'package:aplikasi_e_learning_smk/services/auth_service.dart'; //
import 'package:aplikasi_e_learning_smk/widgets/custom_loading_indicator.dart'; //
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentHomeScreen extends StatefulWidget {
  final VoidCallback? onLihatSemuaMateri; // Callback untuk navigasi

  const StudentHomeScreen({super.key, this.onLihatSemuaMateri});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final AuthService _authService = AuthService(); //
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _userFuture = _authService.getUserData(currentUser!.uid);
    } else {
      _userFuture = Future.value(null);
    }
  }

  // --- WIDGET KARTU RINGKASAN MATERI & TUGAS ---
  Widget _buildSummaryCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        // Style Card diambil dari tema
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30), // Warna ikon spesifik ok
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    // Gunakan warna abu-abu dari tema
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    value,
                    // Gunakan style headline dari tema (warna otomatis ikut)
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
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
    IconData icon,
    String subject,
    String progress,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30), // Warna ikon spesifik ok
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    // Gunakan style title dari tema
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress,
                    // Gunakan style bodySmall dari tema
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.8, // Contoh
                    // Warna background progress bar (sesuaikan dengan tema)
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300],
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
    final theme = Theme.of(context);
    const String placeholderTaskId = "id_tugas_contoh"; // Placeholder ID
    // Placeholder Data Tugas (ambil dari Firestore nanti)
    final Map<String, dynamic> placeholderTaskData = {
      'judul': title,
      'deskripsi': 'Deskripsi tugas placeholder...',
      'mataPelajaran': 'Mapel Contoh',
      'tenggatWaktu': Timestamp.now(), // Atau Timestamp yang sesuai
      'lampiranUrl': null,
      'dibuatPada': Timestamp.now(),
      'untukKelas': 'Kelas Contoh',
      'guruId': 'id_guru_contoh',
      'guruNama': 'Nama Guru Contoh',
    };

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.assignment_outlined,
          color: theme.colorScheme.secondary,
        ), // Warna ikon sekunder tema
        // Gunakan style dari listTileTheme (warna otomatis ikut)
        title: Text(title),
        subtitle: Text(deadline),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade500,
        ), // Panah abu-abu
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                //
                taskId: placeholderTaskId,
                taskData: placeholderTaskData,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ambil tema di awal build

    return FutureBuilder<UserModel?>(
      //
      future: _userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CustomLoadingIndicator()); //
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final user = userSnapshot.data!;
        final userKelas = user.kelas;
        final initial = user.nama.isNotEmpty
            ? user.nama
                  .split(' ')
                  .map((e) => e.isNotEmpty ? e[0] : '')
                  .take(2)
                  .join()
            : '?';

        return Scaffold(
          // <<-- Tambahkan Scaffold di sini
          // appBar: AppBar(...), // AppBar bisa ditambahkan di sini jika perlu
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- BAGIAN HEADER --
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          Colors.grey.shade700, // Background Avatar
                      child: Text(
                        initial.toUpperCase(),
                        // Teks di Avatar boleh kontras dengan backgroundnya
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang,',
                          // Ambil warna teks dari tema (lebih redup)
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          user.nama,
                          // Ambil style judul dari tema (warna otomatis)
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      // Ambil warna ikon dari tema (lebih redup)
                      icon: Icon(
                        Icons.notifications_none,
                        color: theme.iconTheme.color?.withOpacity(0.7),
                      ),
                      onPressed: () {},
                      tooltip: 'Notifikasi',
                    ),
                    IconButton(
                      // Ambil warna ikon dari tema (lebih redup)
                      icon: Icon(
                        Icons.settings_outlined,
                        color: theme.iconTheme.color?.withOpacity(0.7),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AccountSettingsScreen(), //
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userKelas ?? 'Kelas Tidak Diketahui',
                          // Ambil style headline dari tema
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Semangatmu hari ini adalah kunci kesuksesan di masa depan!',
                          // Ambil style bodyMedium dari tema (warna otomatis)
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // -- RINGKASAN MATERI & TUGAS --
                Row(
                  children: [
                    // Ganti 'value' dengan data dinamis jika sudah ada
                    _buildSummaryCard(
                      Icons.library_books_outlined,
                      'Materi',
                      '12/20',
                      Colors.green.shade400,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryCard(
                      Icons.edit_note_outlined,
                      'Tugas',
                      '5/8',
                      Colors.orange.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // -- DAFTAR MATA PELAJARAN --
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mata Pelajaran',
                      // Ambil style titleLarge dari tema
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onLihatSemuaMateri,
                      child: const Text(
                        'Lihat Semua',
                      ), // Warna TextButton otomatis dari tema
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSubjectCard(
                  Icons.computer_outlined,
                  'Informatika',
                  'Progress 8 dari 10 modul',
                  Colors.blue.shade400,
                ),
                const SizedBox(height: 12),
                _buildSubjectCard(
                  Icons.calculate_outlined,
                  'Matematika',
                  'Progress 8 dari 12 modul',
                  Colors.green.shade400,
                ),
                const SizedBox(height: 32),

                // -- TUGAS MENDATANG --
                Text(
                  'Tugas Mendatang',
                  // Ambil style titleLarge dari tema
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildUpcomingTaskCard(
                  'Tugas Algoritma Dasar',
                  'Tenggat: 25 Okt 2025',
                ),
                const SizedBox(height: 12),
                _buildUpcomingTaskCard(
                  'Latihan Soal Vektor',
                  'Tenggat: 28 Okt 2025',
                ),
              ],
            ),
          ),
        ); // <<-- Tutup Scaffold
      },
    );
  }
}
