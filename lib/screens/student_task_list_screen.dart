import 'package:aplikasi_e_learning_smk/screens/task_detail_screen.dart';
import 'package:aplikasi_e_learning_smk/widgets/task_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentTaskListScreen extends StatefulWidget {
  final String kelasId;
  final String siswaId;
  const StudentTaskListScreen(
      {super.key, required this.kelasId, required this.siswaId});

  @override
  State<StudentTaskListScreen> createState() => _StudentTaskListScreenState();
}

class _StudentTaskListScreenState extends State<StudentTaskListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mengambil data pengumpulan siswa
  Stream<Map<String, Map<String, dynamic>>> _getSubmissionsStream() {
    return _firestore
        .collection('submissions')
        .where('siswaId', isEqualTo: widget.siswaId)
        .snapshots()
        .map((snapshot) {
      Map<String, Map<String, dynamic>> submissionsMap = {};
      for (var doc in snapshot.docs) {
        submissionsMap[doc['tugasId']] = doc.data();
      }
      return submissionsMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Map<String, Map<String, dynamic>>>(
        stream: _getSubmissionsStream(),
        builder: (context, submissionSnapshot) {
          if (submissionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final submissions = submissionSnapshot.data ?? {};

          return StreamBuilder<QuerySnapshot>(
            // Mengambil tugas yang ditujukan untuk 'Semua Kelas' ATAU kelas spesifik siswa
            stream: _firestore
                .collection('tugas')
                .where('targetKelas', whereIn: ['Semua Kelas', widget.kelasId])
                .orderBy('deadline',
                    descending: false) // Tenggat terdekat dulu
                .snapshots(),
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada tugas yang diberikan.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              if (taskSnapshot.hasError) {
                return const Center(child: Text('Terjadi error.'));
              }

              var taskDocs = taskSnapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: taskDocs.length,
                itemBuilder: (context, index) {
                  var task = taskDocs[index].data() as Map<String, dynamic>;
                  String taskId = taskDocs[index].id;
                  var submissionData = submissions[taskId];

                  // Tentukan status pengumpulan
                  TaskStatus status = TaskStatus.belumSelesai;
                  if (submissionData != null) {
                    status = (submissionData['nilai'] != null &&
                            submissionData['nilai'] > 0)
                        ? TaskStatus.sudahDinilai
                        : TaskStatus.sudahDikumpulkan;
                  }

                  return TaskCard(
                    judul: task['judul'] ?? 'Tanpa Judul',
                    mapel: task['mapel'] ?? 'Umum',
                    deadline: task['deadline'] as Timestamp,
                    status: status,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(
                            taskId: taskId,
                            siswaId: widget.siswaId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}