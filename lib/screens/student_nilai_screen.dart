import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';

class StudentNilaiScreen extends StatelessWidget {
  const StudentNilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }

    return FutureBuilder<UserModel?>(
      future: AuthService().getUserData(currentUser.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData) {
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final userKelas = userSnapshot.data!.kelas;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tugas')
              .where('untukKelas', isEqualTo: userKelas)
              .orderBy('tenggatWaktu', descending: true)
              .snapshots(),
          builder: (context, taskSnapshot) {
            if (taskSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('Belum ada tugas yang dinilai untuk kelas $userKelas.'),
              );
            }
            if (taskSnapshot.hasError) {
              return const Center(child: Text('Terjadi error saat memuat nilai.'));
            }

            return ListView.builder(
              itemCount: taskSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var taskDoc = taskSnapshot.data!.docs[index];
                var taskData = taskDoc.data() as Map<String, dynamic>;

                return FutureBuilder<DocumentSnapshot>(
                  future: taskDoc.reference.collection('pengumpulan').doc(currentUser.uid).get(),
                  builder: (context, submissionSnapshot) {
                    if (!submissionSnapshot.hasData || !submissionSnapshot.data!.exists) {
                      // Siswa belum mengumpulkan tugas ini, jangan tampilkan apa-apa
                      return const SizedBox.shrink(); 
                    }

                    var submissionData = submissionSnapshot.data!.data() as Map<String, dynamic>;
                    final nilai = submissionData['nilai'];

                    // Hanya tampilkan jika sudah dinilai
                    if (nilai == null) {
                      return const SizedBox.shrink();
                    }
                    
                    final feedback = submissionData['feedback'] ?? 'Tidak ada feedback.';
                    DateTime dikumpulkanPada = (submissionData['dikumpulkanPada'] as Timestamp).toDate();
                    String formattedDate = DateFormat('d MMM yyyy').format(dikumpulkanPada);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(taskData['judul'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Dikumpulkan pada: $formattedDate', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('NILAI:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(nilai.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                                  ],
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('FEEDBACK:', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(feedback.isNotEmpty ? feedback : '-'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}