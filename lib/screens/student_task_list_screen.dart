import 'package:aplikasi_e_learning_smk/screens/task_detail_screen.dart'; // Impor halaman detail
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentTaskListScreen extends StatelessWidget {
  const StudentTaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tugas')
          .orderBy('dibuatPada', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada tugas yang diberikan.'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi error saat memuat tugas.'));
        }
        
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // Ambil seluruh dokumen, bukan hanya datanya
            var taskDoc = snapshot.data!.docs[index];
            var taskData = taskDoc.data() as Map<String, dynamic>;

            DateTime tenggat = (taskData['tenggatWaktu'] as Timestamp).toDate();
            String formattedTenggat = DateFormat('d MMM yyyy, HH:mm').format(tenggat);
            bool isLate = DateTime.now().isAfter(tenggat);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(taskData['judul'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Tenggat: $formattedTenggat',
                    style: TextStyle(
                      color: isLate ? Colors.red : Colors.black54,
                      fontWeight: isLate ? FontWeight.bold : FontWeight.normal
                    ),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigasi ke halaman detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(
                        taskId: taskDoc.id,      // Kirim ID dokumen
                        taskData: taskData,   // Kirim data tugas
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}