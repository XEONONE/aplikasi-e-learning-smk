// lib/screens/submission_list_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// ## 1. IMPORT WIDGET KOMENTAR ##
import 'package:aplikasi_e_learning_smk/widgets/comment_section.dart';

class SubmissionListScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const SubmissionListScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<SubmissionListScreen> createState() => _SubmissionListScreenState();
}

class _SubmissionListScreenState extends State<SubmissionListScreen> {
  Future<void> _launchUrl(String fileUrl) async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<String> _getStudentName(String uid) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      if (userDoc.docs.isNotEmpty) {
        return userDoc.docs.first.data()['nama'] ?? 'Siswa tidak ditemukan';
      }
      return 'Siswa Anonim';
    } catch (e) {
      return 'Error';
    }
  }

  Future<void> _showGradingDialog(
    String submissionId,
    Map<String, dynamic> currentSubmissionData,
  ) async {
    final nilaiController = TextEditingController(
      text: currentSubmissionData['nilai']?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: currentSubmissionData['feedback'] ?? '',
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Beri Nilai dan Feedback'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nilaiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nilai (0-100)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan / Feedback',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('tugas')
                    .doc(widget.taskId)
                    .collection('pengumpulan')
                    .doc(submissionId)
                    .update({
                      'nilai': int.tryParse(nilaiController.text) ?? 0,
                      'feedback': feedbackController.text.trim(),
                    });
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengumpulan: ${widget.taskTitle}')),
      // ## 2. UBAH STRUKTUR BODY MENJADI SCROLLABLE COLUMN ##
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN DAFTAR PENGUMPULAN SISWA
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tugas')
                  .doc(widget.taskId)
                  .collection('pengumpulan')
                  .orderBy('dikumpulkanPada', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        'Belum ada siswa yang mengumpulkan tugas ini.',
                      ),
                    ),
                  );
                }

                // Kita gunakan Column di sini, bukan ListView, karena sudah ada SingleChildScrollView di luar
                return Column(
                  children: snapshot.data!.docs.map((submissionDoc) {
                    var submissionData =
                        submissionDoc.data() as Map<String, dynamic>;
                    DateTime dikumpulkanPada =
                        (submissionData['dikumpulkanPada'] as Timestamp)
                            .toDate();
                    String formattedDate = DateFormat(
                      'd MMM yyyy, HH:mm',
                    ).format(dikumpulkanPada);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.person, size: 40),
                        title: FutureBuilder<String>(
                          future: _getStudentName(submissionData['siswaUid']),
                          builder: (context, nameSnapshot) {
                            if (nameSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                'Memuat nama...',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              );
                            }
                            return Text(
                              nameSnapshot.data ?? '...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        subtitle: Text('Mengumpulkan pada: $formattedDate'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.file_open,
                                color: Colors.blue,
                              ),
                              tooltip: 'Lihat Jawaban',
                              onPressed: () =>
                                  _launchUrl(submissionData['fileUrl']),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.rate_review,
                                color: Colors.orange,
                              ),
                              tooltip: 'Beri Nilai',
                              onPressed: () => _showGradingDialog(
                                submissionDoc.id,
                                submissionData,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // ## 3. TAMBAHKAN WIDGET KOMENTAR DI SINI ##
            const Divider(height: 48, thickness: 1),
            CommentSection(documentId: widget.taskId, collectionPath: 'tugas'),
          ],
        ),
      ),
    );
  }
}
