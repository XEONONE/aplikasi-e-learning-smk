// lib/screens/student_graded_tasks_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/task_detail_screen.dart'; // Pastikan Anda punya screen ini
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/custom_loading_indicator.dart'; // Pastikan Anda punya widget ini
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentGradedTasksScreen extends StatefulWidget {
  const StudentGradedTasksScreen({super.key});

  @override
  State<StudentGradedTasksScreen> createState() =>
      _StudentGradedTasksScreenState();
}

class _StudentGradedTasksScreenState extends State<StudentGradedTasksScreen> {
  int _selectedToggleIndex = 0; // 0: Aktif, 1: Selesai
  late Future<UserModel?> _userFuture;
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID'; // Atur locale untuk format tanggal Indonesia
    if (currentUser != null) {
      _userFuture = _authService.getUserData(currentUser!.uid);
    } else {
      _userFuture = Future.value(null); // Handle jika user null
    }
  }

  // --- WIDGET KARTU TUGAS AKTIF ---
  Widget _buildActiveTaskCard(
    BuildContext context,
    String taskId,
    Map<String, dynamic> taskData,
  ) {
    final theme = Theme.of(context);
    final String judul = taskData['judul'] ?? 'Tanpa Judul';
    final String mapel = taskData['mataPelajaran'] ?? 'Mapel';
    final Timestamp tenggatTimestamp =
        taskData['tenggatWaktu'] as Timestamp? ?? Timestamp.now();
    final DateTime tenggatWaktu = tenggatTimestamp.toDate();
    final now = DateTime.now();
    final difference = tenggatWaktu.difference(now);

    String deadlineText;
    Color deadlineColor = Colors.orange.shade600; // Default

    // Logika menampilkan status tenggat
    if (difference.isNegative) {
      deadlineText = 'Terlewat';
      deadlineColor = theme.colorScheme.error;
    } else if (difference.inDays == 0 && tenggatWaktu.day == now.day) {
      deadlineText = 'Hari ini';
      deadlineColor = Colors.red.shade400; // Mendesak jika hari ini
    } else if (difference.inDays == 0 &&
        tenggatWaktu.day == now.add(const Duration(days: 1)).day) {
      deadlineText = 'Besok';
      deadlineColor = Colors.orange.shade600;
    } else if (difference.inDays >= 1) {
      deadlineText = '${difference.inDays} hari lagi';
      deadlineColor = Colors.green.shade600; // Tidak mendesak jika > 1 hari
    } else if (difference.inHours >= 1) {
      deadlineText = '${difference.inHours} jam lagi';
      deadlineColor = Colors.orange.shade600; // Cukup mendesak
    } else if (difference.inMinutes >= 1) {
      deadlineText = '${difference.inMinutes} menit lagi';
      deadlineColor = Colors.red.shade400; // Mendesak
    } else {
      deadlineText = 'Segera Berakhir';
      deadlineColor = theme.colorScheme.error; // Sangat mendesak
    }

    final String timeText = DateFormat('HH:mm').format(tenggatWaktu);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaskDetailScreen(taskId: taskId, taskData: taskData),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mapel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    deadlineText,
                    style: TextStyle(
                      color: deadlineColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  // Hanya tampilkan jam jika tidak terlewat
                  if (!difference.isNegative) ...[
                    const SizedBox(height: 2),
                    Text(
                      timeText, // Menampilkan jam tenggat
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET KARTU TUGAS SELESAI (SUDAH DINILAI ATAU TERLEWAT) ---
  Widget _buildGradedTaskCard(
    BuildContext context,
    String taskId,
    Map<String, dynamic> taskData,
    Map<String, dynamic>? submissionData, // Jadikan nullable
  ) {
    final theme = Theme.of(context);
    final String judul = taskData['judul'] ?? 'Tanpa Judul';
    final String mapel = taskData['mataPelajaran'] ?? 'Mapel';
    // Ambil nilai HANYA jika submissionData tidak null
    final nilai = submissionData?['nilai']; // Gunakan ?.

    // Ambil tanggal pengumpulan jika ada, jika tidak, gunakan tanggal tenggat sebagai fallback
    final Timestamp eventTimestamp =
        submissionData?['dikumpulkanPada'] as Timestamp? ?? // Gunakan ?.
        taskData['tenggatWaktu'] as Timestamp? ??
        Timestamp.now();
    final DateTime eventDate = eventTimestamp.toDate();
    // Format tanggal sesuai gambar: "dd Okt"
    final String formattedTanggal = DateFormat(
      'dd MMM',
      'id_ID',
    ).format(eventDate);

    // Tentukan warna background nilai dan teks nilai/status
    final Color nilaiBackgroundColor;
    final String nilaiText;

    if (nilai != null) {
      // Jika sudah ada nilai
      nilaiBackgroundColor = (nilai is num && nilai >= 75)
          ? Colors
                .green
                .shade600 // Hijau jika >= 75
          : Colors.orange.shade700; // Oranye jika < 75
      nilaiText = nilai.toString(); // Tampilkan nilai
    } else {
      // Jika belum ada nilai (kasus terlewat tapi belum dikumpul/dinilai)
      nilaiBackgroundColor = Colors.grey.shade600; // Warna abu-abu
      nilaiText = '-'; // Tampilkan strip
    }

    // Tentukan subtitle berdasarkan apakah sudah dinilai atau hanya terlewat
    final String subtitleText = nilai != null
        ? '$mapel - Dinilai pada $formattedTanggal' // Jika sudah dinilai
        : '$mapel - Terlewat'; // Jika hanya terlewat

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaskDetailScreen(taskId: taskId, taskData: taskData),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul, // Judul Tugas
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Subtitle: Menampilkan status (Dinilai/Terlewat)
                    Text(
                      subtitleText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Lingkaran untuk nilai atau status
              CircleAvatar(
                backgroundColor: nilaiBackgroundColor,
                radius: 22, // Sesuaikan ukuran jika perlu
                child: Text(
                  nilaiText, // Tampilkan nilai atau '-'
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false, // Judul rata kiri
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Aksi Pencarian
            },
            icon: Icon(
              Icons.search, // Icon kaca pembesar
              color: theme.iconTheme.color?.withOpacity(
                0.9,
              ), // Sedikit lebih jelas
            ),
            tooltip: 'Cari Tugas',
          ),
          IconButton(
            onPressed: () {
              // TODO: Aksi notifikasi
            },
            icon: Icon(
              Icons.notifications_outlined, // Icon lonceng
              color: theme.iconTheme.color?.withOpacity(
                0.9,
              ), // Sedikit lebih jelas
            ),
            tooltip: 'Notifikasi',
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoadingIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Gagal memuat data siswa.'));
          }

          final userKelas = userSnapshot.data!.kelas;
          final userId = currentUser!.uid;

          return Column(
            children: [
              // --- BAGIAN TOGGLE (SESUAI GAMBAR) ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ), // Tambah padding horizontal
                child: Container(
                  // Bungkus dengan Container untuk styling
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300], // Warna background toggle
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ToggleButtons(
                    isSelected: [
                      _selectedToggleIndex == 0,
                      _selectedToggleIndex == 1,
                    ],
                    onPressed: (index) {
                      setState(() {
                        _selectedToggleIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    selectedBorderColor:
                        theme.colorScheme.primary, // Warna border saat terpilih
                    selectedColor:
                        theme.colorScheme.onPrimary, // Warna teks saat terpilih
                    fillColor:
                        theme.colorScheme.primary, // Warna fill saat terpilih
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(
                      0.6,
                    ), // Warna teks saat tidak terpilih
                    borderColor: Colors.transparent, // Hilangkan border luar
                    renderBorder: false, // Hilangkan border antar tombol
                    constraints: const BoxConstraints(
                      minHeight: 38.0,
                      minWidth: 100.0,
                    ), // Atur ukuran minimum
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Aktif',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Selesai',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // --- AKHIR BAGIAN TOGGLE ---

              // --- BAGIAN LIST TUGAS ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tugas')
                      .where('untukKelas', isEqualTo: userKelas)
                      .snapshots(), // Hapus orderBy di sini, lakukan setelah filter
                  builder: (context, taskSnapshot) {
                    if (taskSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CustomLoadingIndicator());
                    }
                    if (!taskSnapshot.hasData ||
                        taskSnapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'Belum ada tugas untuk kelas $userKelas.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collectionGroup('pengumpulan')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, submissionSnapshot) {
                        Map<String, Map<String, dynamic>> submissions = {};
                        if (submissionSnapshot.hasData) {
                          for (var doc in submissionSnapshot.data!.docs) {
                            submissions[doc.reference.parent.parent!.id] =
                                doc.data() as Map<String, dynamic>;
                          }
                        }

                        // --- LOGIKA PEMISAHAN AKTIF DAN SELESAI (SUDAH DIPERBAIKI) ---
                        List<QueryDocumentSnapshot> activeTasks = [];
                        List<QueryDocumentSnapshot> completedTasks = [];
                        final now = DateTime.now();

                        for (var taskDoc in taskSnapshot.data!.docs) {
                          final taskData =
                              taskDoc.data() as Map<String, dynamic>;
                          // Ambil submissionData DARI MAP submissions, bukan dari snapshot langsung
                          final submissionData =
                              submissions[taskDoc.id]; // <<< PENTING

                          final Timestamp tenggatTimestamp =
                              taskData['tenggatWaktu'] as Timestamp? ??
                              Timestamp.now();
                          final DateTime tenggatWaktu = tenggatTimestamp
                              .toDate();
                          final bool isOverdue = tenggatWaktu.isBefore(now);
                          // Cek nilai dari submissionData yang diambil dari map
                          final bool isGraded =
                              submissionData != null &&
                              submissionData['nilai'] != null; // <<< PENTING

                          if (isGraded || isOverdue) {
                            // Masuk ke Selesai JIKA sudah dinilai ATAU sudah lewat tenggat
                            completedTasks.add(taskDoc);
                          } else {
                            // Masuk ke Aktif HANYA JIKA belum dinilai DAN belum lewat tenggat
                            activeTasks.add(taskDoc);
                          }
                        }
                        // --- AKHIR LOGIKA PEMISAHAN ---

                        // Urutkan tugas aktif (tenggat terdekat di atas)
                        activeTasks.sort((a, b) {
                          Timestamp aTenggat =
                              (a.data()
                                  as Map<String, dynamic>)['tenggatWaktu'] ??
                              Timestamp.now();
                          Timestamp bTenggat =
                              (b.data()
                                  as Map<String, dynamic>)['tenggatWaktu'] ??
                              Timestamp.now();
                          return aTenggat.compareTo(bTenggat);
                        });

                        // Urutkan tugas selesai (terbaru dinilai/terlewat di atas)
                        completedTasks.sort((a, b) {
                          // Ambil submission data dari MAP submissions lagi
                          final subA = submissions[a.id]; // <<< PENTING
                          final subB = submissions[b.id]; // <<< PENTING
                          Timestamp aTimestamp =
                              subA?['dikumpulkanPada'] as Timestamp? ??
                              (a.data()
                                  as Map<String, dynamic>)['tenggatWaktu'] ??
                              Timestamp.now();
                          Timestamp bTimestamp =
                              subB?['dikumpulkanPada'] as Timestamp? ??
                              (b.data()
                                  as Map<String, dynamic>)['tenggatWaktu'] ??
                              Timestamp.now();
                          return bTimestamp.compareTo(aTimestamp);
                        });

                        final List<QueryDocumentSnapshot> tasksToShow =
                            _selectedToggleIndex == 0
                            ? activeTasks
                            : completedTasks;

                        if (tasksToShow.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                _selectedToggleIndex == 0
                                    ? 'Tidak ada tugas aktif.'
                                    : 'Tidak ada tugas yang sudah selesai.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }

                        // --- PEMANGGILAN KARTU YANG DIPASTIKAN BENAR ---
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          itemCount: tasksToShow.length,
                          itemBuilder: (context, index) {
                            final taskDoc = tasksToShow[index];
                            final taskData =
                                taskDoc.data() as Map<String, dynamic>;

                            if (_selectedToggleIndex == 0) {
                              // Tampilkan kartu tugas aktif
                              return _buildActiveTaskCard(
                                context,
                                taskDoc.id,
                                taskData,
                              );
                            } else {
                              // TAB SELESAI: SELALU TAMPILKAN KARTU GRADED
                              // Ambil submission data dari MAP submissions
                              final submissionData =
                                  submissions[taskDoc
                                      .id]; // <<< PENTING: Ambil dari map
                              return _buildGradedTaskCard(
                                context,
                                taskDoc.id,
                                taskData,
                                submissionData, // Kirim data dari map (bisa null)
                              );
                            }
                          },
                        );
                        // --- AKHIR PEMANGGILAN KARTU ---
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
