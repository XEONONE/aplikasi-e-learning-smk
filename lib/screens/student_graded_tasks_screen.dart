// lib/screens/student_graded_tasks_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/task_detail_screen.dart'; // Untuk navigasi detail
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/custom_loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentGradedTasksScreen extends StatefulWidget {
  const StudentGradedTasksScreen({super.key});

  @override
  State<StudentGradedTasksScreen> createState() => _StudentGradedTasksScreenState();
}

class _StudentGradedTasksScreenState extends State<StudentGradedTasksScreen> {
  int _selectedToggleIndex = 0; // 0: Aktif, 1: Selesai
  late Future<UserModel?> _userFuture;
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Inisialisasi format tanggal Indonesia
    Intl.defaultLocale = 'id_ID';
    if (currentUser != null) {
      _userFuture = _authService.getUserData(currentUser!.uid);
    }
  }

  // --- WIDGET KARTU TUGAS YANG SUDAH DINILAI ---
  Widget _buildGradedTaskCard(BuildContext context, String taskId, Map<String, dynamic> taskData, Map<String, dynamic> submissionData) {
    final theme = Theme.of(context);
    final String judul = taskData['judul'] ?? 'Tanpa Judul';
    final String mapel = taskData['mataPelajaran'] ?? 'Mapel';
    final nilai = submissionData['nilai'];
    
    // Ambil tanggal pengumpulan/penilaian, fallback ke tenggat waktu jika tidak ada
    final Timestamp dinilaiTimestamp = submissionData['tanggalPengumpulan'] as Timestamp? ?? taskData['tenggatWaktu'] as Timestamp? ?? Timestamp.now();
    final DateTime dinilaiTanggal = dinilaiTimestamp.toDate();
    final String formattedTanggal = DateFormat('dd MMM').format(dinilaiTanggal);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi ke detail tugas
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                taskId: taskId,
                taskData: taskData,
              ),
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
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$mapel • Dinilai pada $formattedTanggal',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // Warna berdasarkan nilai (Contoh: KKM 75)
                  color: (nilai is num && nilai >= 75) 
                       ? Colors.green.shade700 
                       : Colors.orange.shade700, 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  nilai?.toString() ?? '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
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

    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CustomLoadingIndicator());
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final userKelas = userSnapshot.data!.kelas;
        final userId = currentUser!.uid; // Ambil UID siswa

        return Column(
          children: [
            // --- BAGIAN HEADER & TOGGLE ---
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              color: theme.scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                        Text(
                          'Daftar\nTugas',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Ikon notifikasi (sesuai screenshot)
                        IconButton(
                          onPressed: () {
                             // TODO: Tambahkan aksi notifikasi
                          },
                          icon: Icon(Icons.notifications_outlined, color: Colors.grey[400]),
                        )
                     ],
                  ),

                  const SizedBox(height: 24),
                  Center(
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
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.blueAccent.shade100.withOpacity(0.5),
                      selectedColor: Colors.white,
                      fillColor: Colors.blueAccent.withOpacity(0.2), // Warna saat terpilih
                      color: Colors.grey[400], // Warna saat tidak terpilih
                      borderColor: Colors.grey[700],
                      constraints: const BoxConstraints(
                        minHeight: 35.0,
                        minWidth: 100.0,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Aktif'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Selesai'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- BAGIAN LIST TUGAS ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Query semua tugas untuk kelas siswa
                stream: FirebaseFirestore.instance
                    .collection('tugas')
                    .where('untukKelas', isEqualTo: userKelas)
                    .orderBy('tenggatWaktu', descending: true)
                    .snapshots(),
                builder: (context, taskSnapshot) {
                  if (taskSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoadingIndicator());
                  }
                  if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                         padding: const EdgeInsets.all(32.0),
                         child: Text(
                            'Belum ada tugas yang dinilai untuk kelas $userKelas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                      ),
                    );
                  }

                  // Proses data untuk mendapatkan tugas yang sudah dinilai saja
                  List<Future<Widget?>> gradedTaskWidgetsFutures = taskSnapshot.data!.docs.map((taskDoc) async {
                    Map<String, dynamic> taskData = taskDoc.data() as Map<String, dynamic>;
                    Timestamp tenggatTimestamp = taskData['tenggatWaktu'] as Timestamp? ?? Timestamp.now();
                    DateTime tenggatWaktu = tenggatTimestamp.toDate();
                    bool isTaskExpired = tenggatWaktu.isBefore(DateTime.now());

                    // Filter berdasarkan toggle Aktif/Selesai (berdasarkan tenggat tugas)
                    if ((_selectedToggleIndex == 0 && isTaskExpired) || (_selectedToggleIndex == 1 && !isTaskExpired)) {
                      return null; // Skip tugas ini jika tidak sesuai filter
                    }

                    // Ambil data pengumpulan siswa untuk tugas ini
                    DocumentSnapshot submissionSnapshot = await FirebaseFirestore.instance
                        .collection('tugas')
                        .doc(taskDoc.id)
                        .collection('pengumpulan')
                        .doc(userId)
                        .get();

                    // Cek apakah siswa sudah mengumpulkan DAN sudah dinilai
                    if (submissionSnapshot.exists) {
                       Map<String, dynamic> submissionData = submissionSnapshot.data() as Map<String, dynamic>;
                       if (submissionData['nilai'] != null) {
                          // Jika sudah dinilai, buat cardnya
                          return _buildGradedTaskCard(context, taskDoc.id, taskData, submissionData);
                       }
                    }
                    return null; // Return null jika belum dinilai atau belum dikumpulkan
                  }).toList();

                  // Gunakan FutureBuilder untuk menunggu semua widget selesai dibuat
                  return FutureBuilder<List<Widget?>>(
                     future: Future.wait(gradedTaskWidgetsFutures),
                     builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                           return const Center(child: CustomLoadingIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Center(child: Text('Gagal memuat detail nilai.', style: TextStyle(color: Colors.grey[500]),));
                        }

                        // Filter widget yang tidak null
                        final List<Widget> gradedTaskWidgets = snapshot.data!.whereType<Widget>().toList();

                        if (gradedTaskWidgets.isEmpty) {
                           return Center(
                             child: Padding(
                               padding: const EdgeInsets.all(32.0),
                               child: Text(
                                 _selectedToggleIndex == 0
                                     ? 'Tidak ada tugas aktif yang sudah dinilai.'
                                     : 'Tidak ada tugas selesai yang sudah dinilai.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[500]),
                               ),
                             ),
                           );
                        }

                        return ListView(
                           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                           children: gradedTaskWidgets,
                        );
                     },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}