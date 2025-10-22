import 'package:aplikasi_e_learning_smk/screens/task_detail_screen.dart';
import 'package:aplikasi_e_learning_smk/widgets/task_summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskListScreen extends StatefulWidget {
  final bool showExpired;

  const TaskListScreen({super.key, this.showExpired = false});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // ## PERBAIKAN: Hapus FirebaseService ##
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Center(child: Text("Silakan login kembali."));
    }

    return StreamBuilder<QuerySnapshot>(
      // ## PERBAIKAN: Query langsung ke Firestore ##
      stream: FirebaseFirestore.instance
          .collection('tugas')
          .where('dibuatOlehUid', isEqualTo: currentUserId)
          .snapshots(),
      // ## AKHIR PERBAIKAN ##
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Anda belum membuat tugas.'));
        }

        // ## PERBAIKAN: Ubah 'Tugas' menjadi 'QueryDocumentSnapshot' ##
        final allTasks = snapshot.data!.docs;
        List<QueryDocumentSnapshot> filteredTasks = allTasks.where((doc) {
          final taskData = doc.data() as Map<String, dynamic>;
          // Tambahkan pengecekan null safety
          final dueDate =
              (taskData['tenggatWaktu'] as Timestamp? ?? Timestamp.now())
                  .toDate();
          final isExpired = dueDate.isBefore(DateTime.now());

          if (widget.showExpired) {
            return isExpired;
          } else {
            return !isExpired;
          }
        }).toList();
        // ## AKHIR PERBAIKAN ##

        if (filteredTasks.isEmpty) {
          return Center(
            child: Text(
              widget.showExpired
                  ? 'Tidak ada riwayat tugas.'
                  : 'Tidak ada tugas aktif saat ini.',
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        // ## PERBAIKAN: Logika sorting untuk Map/Timestamp ##
        filteredTasks.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime =
              (aData['tenggatWaktu'] as Timestamp? ?? Timestamp.now());
          final bTime =
              (bData['tenggatWaktu'] as Timestamp? ?? Timestamp.now());
          if (widget.showExpired) {
            return bTime.compareTo(aTime); // Terbaru di atas
          } else {
            return aTime.compareTo(bTime); // Terdekat di atas
          }
        });
        // ## AKHIR PERBAIKAN ##

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            // ## PERBAIKAN: Ambil doc dan data ##
            QueryDocumentSnapshot taskDoc = filteredTasks[index];
            final taskData = taskDoc.data() as Map<String, dynamic>;
            final String taskTitle = taskData['judul'] ?? 'Tugas Tanpa Judul';
            // ## AKHIR PERBAIKAN ##

            return TaskSummaryCard(
              // ## PERBAIKAN: Kirim taskId dan taskData ##
              taskId: taskDoc.id,
              taskData: taskData,
              // ## AKHIR PERBAIKAN ##
              onEdit: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Edit Tugas: $taskTitle (belum diimplementasikan)',
                    ),
                  ),
                );
              },
              onDelete: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi Hapus'),
                      content: Text(
                        'Apakah Anda yakin ingin menghapus tugas "$taskTitle"?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
                if (confirm == true) {
                  // ## PERBAIKAN: Hapus langsung & cek 'mounted' ##
                  await FirebaseFirestore.instance
                      .collection('tugas')
                      .doc(taskDoc.id)
                      .delete();

                  if (!mounted)
                    return; // Cek mounted sebelum pakai BuildContext
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tugas "$taskTitle" dihapus.')),
                  );
                  // ## AKHIR PERBAIKAN ##
                }
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // ## PERBAIKAN: Tambahkan parameter taskData ##
                    builder: (context) => TaskDetailScreen(
                      taskId: taskDoc.id,
                      taskData: taskData,
                    ),
                    // ## AKHIR PERBAIKAN ##
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
