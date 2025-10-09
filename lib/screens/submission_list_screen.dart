// PERBAIKAN DI SINI: Menggunakan ':' bukan '.'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionListScreen extends StatelessWidget {
  final String taskId;
  final String taskTitle;

  const SubmissionListScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  Future<void> _launchUrl(String fileUrl) async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
  
  // Fungsi untuk mengambil nama siswa berdasarkan UID
  Future<String> _getStudentName(String uid) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: uid).limit(1).get();
      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data()['nama'] ?? 'Siswa tidak ditemukan';
      }
      return 'Siswa Anonim';
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengumpulan: $taskTitle'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil data dari sub-collection 'pengumpulan'
        stream: FirebaseFirestore.instance
            .collection('tugas')
            .doc(taskId)
            .collection('pengumpulan')
            .orderBy('dikumpulkanPada', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada siswa yang mengumpulkan tugas ini.'));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi error.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var submissionData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              DateTime dikumpulkanPada = (submissionData['dikumpulkanPada'] as Timestamp).toDate();
              String formattedDate = DateFormat('d MMM yyyy, HH:mm').format(dikumpulkanPada);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.person, size: 40),
                  title: FutureBuilder<String>(
                    future: _getStudentName(submissionData['siswaUid']),
                    builder: (context, nameSnapshot) {
                      if (nameSnapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Memuat nama...', style: TextStyle(fontWeight: FontWeight.bold));
                      }
                      return Text(nameSnapshot.data ?? '...', style: const TextStyle(fontWeight: FontWeight.bold));
                    },
                  ),
                  subtitle: Text('Mengumpulkan pada: $formattedDate'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Unduh Jawaban',
                    onPressed: () => _launchUrl(submissionData['fileUrl']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}