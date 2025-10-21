import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/comment_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionListScreen extends StatefulWidget {
  final String taskId;
  const SubmissionListScreen({super.key, required this.taskId});

  @override
  State<SubmissionListScreen> createState() => _SubmissionListScreenState();
}

class _SubmissionListScreenState extends State<SubmissionListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk membuka URL
  Future<void> _launchUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka $url')),
        );
      }
    }
  }

  // Fungsi untuk menampilkan dialog pemberian nilai
  Future<void> _showNilaiDialog(
      String submissionId, num? currentNilai, String? currentFeedback) async {
    final TextEditingController nilaiController =
        TextEditingController(text: currentNilai?.toString());
    final TextEditingController feedbackController =
        TextEditingController(text: currentFeedback);
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Beri Nilai dan Feedback'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nilaiController,
                    decoration: const InputDecoration(
                      labelText: 'Nilai (0-100)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nilai tidak boleh kosong';
                      }
                      final n = num.tryParse(value);
                      if (n == null) {
                        return 'Format angka tidak valid';
                      }
                      if (n < 0 || n > 100) {
                        return 'Nilai harus antara 0 dan 100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: feedbackController,
                    decoration: const InputDecoration(
                      labelText: 'Feedback (Opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _firestore
                        .collection('submissions')
                        .doc(submissionId)
                        .update({
                      'nilai': num.parse(nilaiController.text),
                      'feedback': feedbackController.text,
                    });
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nilai berhasil disimpan!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal simpan nilai: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Simpan Nilai'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumpulan Tugas'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Daftar Siswa yang Mengumpulkan
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('submissions')
                  .where('tugasId', isEqualTo: widget.taskId)
                  .orderBy('siswaNama')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Belum ada siswa yang mengumpulkan.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi error.'));
                }

                var submissions = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    var sub = submissions[index].data() as Map<String, dynamic>;
                    String submissionId = submissions[index].id;
                    num? nilai = sub['nilai'];
                    String? feedback = sub['feedback'];

                    return Card(
                      elevation: 2.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              nilai != null ? Colors.green : Colors.grey,
                          child: nilai != null
                              ? Text(
                                  nilai.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(sub['siswaNama'] ?? 'Nama Siswa'),
                        subtitle: Text(
                          sub['linkJawaban'] ?? 'Belum ada link',
                          style: const TextStyle(
                              color: Colors.blue, fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new,
                                  color: Colors.blue),
                              tooltip: 'Buka Link',
                              onPressed: () {
                                if (sub['linkJawaban'] != null) {
                                  _launchUrl(sub['linkJawaban']);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_note,
                                  color: Colors.indigo),
                              tooltip: 'Beri Nilai',
                              onPressed: () {
                                _showNilaiDialog(submissionId, nilai, feedback);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            
            const Divider(height: 32),
            // Bagian Komentar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diskusi / Tanya Jawab',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  CommentSection(
                    documentId: widget.taskId, // Gunakan ID Tugas
                    collectionName: 'tugas', // Koleksi 'tugas'
                    currentUser: AuthService().getCurrentUser(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}