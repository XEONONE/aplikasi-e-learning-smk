import 'package:aplikasi_e_learning_smk/screens/create_task_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/submission_list_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _guruId = AuthService().getCurrentUser()?.uid ?? '';

  // Fungsi untuk menghapus tugas
  Future<void> _deleteTask(String taskId) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _firestore.collection('tugas').doc(taskId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil dihapus.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus tugas: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil semua tugas yang dibuat oleh guru ini
        stream: _firestore
            .collection('tugas')
            .where('guruId', isEqualTo: _guruId)
            .orderBy('deadline', descending: true) // Tugas terbaru/terjauh
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum membuat tugas apapun.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi error.'));
          }

          var taskDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: taskDocs.length,
            itemBuilder: (context, index) {
              var task = taskDocs[index].data() as Map<String, dynamic>;
              String taskId = taskDocs[index].id;
              Timestamp deadline = task['deadline'] as Timestamp;
              String formattedDeadline =
                  DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
                      .format(deadline.toDate());

              return Card(
                elevation: 3.0,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.indigo),
                  title: Text(task['judul'] ?? 'Tanpa Judul'),
                  subtitle: Text(
                      'Kelas: ${task['targetKelas']} | Tenggat: $formattedDeadline'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'lihat') {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SubmissionListScreen(taskId: taskId),
                        ));
                      } else if (value == 'edit') {
                        // TODO: Navigasi ke halaman Edit Tugas
                        // Navigator.of(context).push(MaterialPageRoute(
                        //   builder: (context) => EditTaskScreen(taskId: taskId),
                        // ));
                      } else if (value == 'hapus') {
                        _deleteTask(taskId);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'lihat',
                        child: Text('Lihat Pengumpulan'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Tugas'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'hapus',
                        child:
                            Text('Hapus Tugas', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Default action: Lihat pengumpulan
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SubmissionListScreen(taskId: taskId),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateTaskScreen(),
            ),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add_task),
        tooltip: 'Buat Tugas Baru',
      ),
    );
  }
}