// lib/screens/task_list_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/create_task_screen.dart';
import 'package:aplikasi_e_learning_smk/screens/edit_tugas_screen.dart'; // ## IMPORT BARU ##
import 'package:aplikasi_e_learning_smk/screens/submission_list_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/task_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

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
                .orderBy('dibuatPada', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('Belum ada tugas yang dibuat untuk kelas Anda.'),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Terjadi error saat memuat tugas.'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var taskDoc = snapshot.data!.docs[index];
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
                    // ## PERUBAHAN: Tambahkan onEdit ##
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
