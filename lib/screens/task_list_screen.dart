import 'package:aplikasi_e_learning_smk/screens/create_task_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_e_learning_smk/screens/submission_list_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sudah ada di dasbor utama, jadi kita tidak perlu di sini.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tugas')
            .orderBy('dibuatPada', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada tugas yang dibuat.'));
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi error saat memuat tugas.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var taskData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              DateTime tenggat = (taskData['tenggatWaktu'] as Timestamp)
                  .toDate();
              String formattedTenggat = DateFormat(
                'd MMM yyyy, HH:mm',
              ).format(tenggat);

              return ListTile(
                title: Text(taskData['judul']),
                subtitle: Text('Tenggat: $formattedTenggat'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Nanti di sini akan membuka halaman detail tugas untuk melihat siapa saja yang sudah mengumpulkan
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
