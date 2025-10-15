// lib/screens/task_list_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/create_task_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/edit_task_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/submission_list_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/task_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  final bool showExpired;

  const TaskListScreen({super.key, this.showExpired = true});

  // ## FUNGSI BARU UNTUK HAPUS TUGAS ##
  Future<void> _deleteTask(BuildContext context, String taskId, String taskTitle) async {
    // Tampilkan dialog konfirmasi
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus tugas "$taskTitle"? Tindakan ini tidak dapat diurungkan.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Tutup dialog, kembalikan false
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Tutup dialog, kembalikan true
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // Jika pengguna menekan "Hapus", maka confirmDelete akan true
    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('tugas').doc(taskId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil dihapus'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus tugas: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }

    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: AuthService().getUserData(currentUser.uid),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final guruKelas = userSnapshot.data!.mengajarKelas;
          if (guruKelas == null || guruKelas.isEmpty) {
            return const Center(
              child: Text('Anda belum terdaftar mengajar di kelas manapun.'),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tugas')
                .where('untukKelas', whereIn: guruKelas)
                .orderBy('tenggatWaktu', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Terjadi error. Pastikan indeks Firestore sudah dibuat.'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('Belum ada tugas yang dibuat untuk kelas Anda.'),
                );
              }

              var taskDocs = snapshot.data!.docs;
              if (!showExpired) {
                taskDocs = taskDocs.where((doc) {
                  var taskData = doc.data() as Map<String, dynamic>;
                  DateTime tenggat = (taskData['tenggatWaktu'] as Timestamp).toDate();
                  return tenggat.isAfter(DateTime.now());
                }).toList();
              }
              
              if (taskDocs.isEmpty) {
                 return Center(
                  child: Text(showExpired 
                      ? 'Tidak ada tugas sama sekali.' 
                      : 'Tidak ada tugas aktif saat ini.'),
                );
              }

              return ListView.builder(
                itemCount: taskDocs.length,
                itemBuilder: (context, index) {
                  var taskDoc = taskDocs[index];
                  var taskData = taskDoc.data() as Map<String, dynamic>;

                  return TaskCard(
                    taskId: taskDoc.id,
                    judul: taskData['judul'],
                    tenggatWaktu: taskData['tenggatWaktu'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmissionListScreen(
                            taskId: taskDoc.id,
                            taskTitle: taskData['judul'],
                          ),
                        ),
                      );
                    },
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(
                            taskId: taskDoc.id,
                            initialData: taskData,
                          ),
                        ),
                      );
                    },
                    // ## PERUBAHAN: Panggil fungsi hapus ##
                    onDelete: () {
                      _deleteTask(context, taskDoc.id, taskData['judul']);
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Tugas'),
      ),
    );
  }
}