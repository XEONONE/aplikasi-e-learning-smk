// lib/screens/student_graded_tasks_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart'; //
import 'package:aplikasi_e_learning_smk/screens/task_detail_screen.dart'; //
import 'package:aplikasi_e_learning_smk/services/auth_service.dart'; //
import 'package:aplikasi_e_learning_smk/widgets/custom_loading_indicator.dart'; //
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
  late Future<UserModel?> _userFuture; //
  final AuthService _authService = AuthService(); //
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    if (currentUser != null) {
      _userFuture = _authService.getUserData(currentUser!.uid);
    } else {
      _userFuture = Future.value(null); // Handle jika user null
    }
  }

  // --- WIDGET KARTU TUGAS YANG SUDAH DINILAI ---
  Widget _buildGradedTaskCard(
    BuildContext context,
    String taskId,
    Map<String, dynamic> taskData,
    Map<String, dynamic> submissionData,
  ) {
    final theme = Theme.of(context); // Ambil tema
    final String judul = taskData['judul'] ?? 'Tanpa Judul';
    final String mapel = taskData['mataPelajaran'] ?? 'Mapel';
    final nilai = submissionData['nilai'];

    final Timestamp dinilaiTimestamp =
        submissionData['tanggalPengumpulan'] as Timestamp? ??
        taskData['tenggatWaktu'] as Timestamp? ??
        Timestamp.now();
    final DateTime dinilaiTanggal = dinilaiTimestamp.toDate();
    final String formattedTanggal = DateFormat('dd MMM').format(dinilaiTanggal);

    final Color nilaiBackgroundColor = (nilai is num && nilai >= 75)
        ? Colors.green.shade700
        : Colors.orange.shade700;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        borderRadius: theme.cardTheme.shape is RoundedRectangleBorder
            ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
                  .resolve(Directionality.of(context))
            : BorderRadius.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                //
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
                      // Ambil style dari tema
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$mapel • Dinilai pada $formattedTanggal',
                      // Ambil style dari tema (redup)
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: nilaiBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  nilai?.toString() ?? '?',
                  // Teks nilai tetap putih
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
    final theme = Theme.of(context); // Ambil tema

    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }

    return Scaffold(
      // <<-- Tambahkan Scaffold
      appBar: AppBar(
        // <<-- Tambahkan AppBar
        title: const Text('Tugas Dinilai'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {}, // Aksi notifikasi?
            icon: Icon(
              Icons.notifications_outlined,
              color: theme.iconTheme.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        //
        future: _userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoadingIndicator()); //
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Gagal memuat data siswa.'));
          }

          final userKelas = userSnapshot.data!.kelas;
          final userId = currentUser!.uid;

          return Column(
            children: [
              // --- BAGIAN TOGGLE ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
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
                    // Style dari tema
                    borderRadius: theme.toggleButtonsTheme.borderRadius,
                    selectedBorderColor:
                        theme.toggleButtonsTheme.selectedBorderColor,
                    selectedColor: theme.toggleButtonsTheme.selectedColor,
                    fillColor: theme.toggleButtonsTheme.fillColor,
                    color: theme.toggleButtonsTheme.color,
                    borderColor: theme.toggleButtonsTheme.borderColor,
                    textStyle: theme.toggleButtonsTheme.textStyle,
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
              ),

              // --- BAGIAN LIST TUGAS ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tugas')
                      .where('untukKelas', isEqualTo: userKelas)
                      .orderBy('tenggatWaktu', descending: true)
                      .snapshots(),
                  builder: (context, taskSnapshot) {
                    if (taskSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CustomLoadingIndicator()); //
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

                    List<Future<Widget?>> gradedTaskWidgetsFutures =
                        taskSnapshot.data!.docs.map((taskDoc) async {
                          Map<String, dynamic> taskData =
                              taskDoc.data() as Map<String, dynamic>;
                          Timestamp tenggatTimestamp =
                              taskData['tenggatWaktu'] as Timestamp? ??
                              Timestamp.now();
                          DateTime tenggatWaktu = tenggatTimestamp.toDate();
                          bool isTaskExpired = tenggatWaktu.isBefore(
                            DateTime.now(),
                          );

                          if ((_selectedToggleIndex == 0 && isTaskExpired) ||
                              (_selectedToggleIndex == 1 && !isTaskExpired)) {
                            return null;
                          }

                          DocumentSnapshot submissionSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('tugas')
                                  .doc(taskDoc.id)
                                  .collection('pengumpulan')
                                  .doc(userId)
                                  .get();

                          if (submissionSnapshot.exists) {
                            Map<String, dynamic> submissionData =
                                submissionSnapshot.data()
                                    as Map<String, dynamic>;
                            if (submissionData['nilai'] != null) {
                              return _buildGradedTaskCard(
                                context,
                                taskDoc.id,
                                taskData,
                                submissionData,
                              );
                            }
                          }
                          return null;
                        }).toList();

                    return FutureBuilder<List<Widget?>>(
                      future: Future.wait(gradedTaskWidgetsFutures),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: CustomLoadingIndicator());
                        } //
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Center(
                            child: Text(
                              'Gagal memuat detail nilai.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          );
                        }

                        final List<Widget> gradedTaskWidgets = snapshot.data!
                            .whereType<Widget>()
                            .toList();

                        if (gradedTaskWidgets.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                _selectedToggleIndex == 0
                                    ? 'Tidak ada tugas aktif yang sudah dinilai.'
                                    : 'Tidak ada tugas selesai yang sudah dinilai.',
                                textAlign: TextAlign.center,
                                style: theme
                                    .textTheme
                                    .bodyMedium, // Ambil style dari tema
                              ),
                            ),
                          );
                        }

                        return ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
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
      ),
    ); // <<-- Tutup Scaffold
  }
}
