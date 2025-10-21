import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/comment_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final String siswaId;

  const TaskDetailScreen(
      {super.key, required this.taskId, required this.siswaId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _linkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Fungsi untuk membuka URL
  Future<void> _launchUrl(String url) async {
    // Tambahkan https:// jika belum ada
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

  // Fungsi untuk submit link tugas
  Future<void> _submitTugas() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Cari dokumen submission yang ada (jika ada)
        QuerySnapshot submissionQuery = await _firestore
            .collection('submissions')
            .where('tugasId', isEqualTo: widget.taskId)
            .where('siswaId', isEqualTo: widget.siswaId)
            .limit(1)
            .get();

        String submissionId;

        // Mendapatkan data siswa (nama, kelas)
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(widget.siswaId).get();
        String siswaNama = (userDoc.data() as Map<String, dynamic>)['nama'] ?? 'Siswa';
        String kelasId = (userDoc.data() as Map<String, dynamic>)['kelas'] ?? 'Umum';

        Map<String, dynamic> submissionData = {
          'tugasId': widget.taskId,
          'siswaId': widget.siswaId,
          'siswaNama': siswaNama,
          'kelasId': kelasId,
          'linkJawaban': _linkController.text,
          'timestamp': FieldValue.serverTimestamp(),
          'nilai': null, // Set nilai ke null saat submit/resubmit
          'feedback': null, // Set feedback ke null
        };

        if (submissionQuery.docs.isNotEmpty) {
          // Jika sudah ada, update
          submissionId = submissionQuery.docs.first.id;
          await _firestore
              .collection('submissions')
              .doc(submissionId)
              .update(submissionData);
        } else {
          // Jika belum ada, buat baru
          await _firestore.collection('submissions').add(submissionData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil dikumpulkan!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengumpulkan tugas: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Widget untuk menampilkan area nilai dan feedback
  Widget _buildNilaiCard(Map<String, dynamic> submissionData) {
    num? nilai = submissionData['nilai'];
    String? feedback = submissionData['feedback'];

    if (nilai == null) {
      return const Card(
        color: Colors.blueGrey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Tugas Anda sedang dinilai oleh guru.',
              style:
                  TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4.0,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nilai Anda:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              nilai.toString(),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Feedback Guru:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              feedback ?? 'Tidak ada feedback.',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('tugas').doc(widget.taskId).get(),
        builder: (context, taskSnapshot) {
          if (!taskSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (taskSnapshot.hasError) {
            return const Center(child: Text('Gagal memuat tugas.'));
          }

          var taskData = taskSnapshot.data!.data() as Map<String, dynamic>;
          Timestamp deadline = taskData['deadline'] as Timestamp;
          String formattedDeadline =
              DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID')
                  .format(deadline.toDate());
          bool isOverdue = DateTime.now().isAfter(deadline.toDate());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detail Tugas
                Text(
                  taskData['judul'] ?? 'Tanpa Judul',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mapel: ${taskData['mapel'] ?? 'Umum'}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo),
                ),
                const SizedBox(height: 4),
                Text(
                  'Oleh: ${taskData['authorName'] ?? 'Guru'}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tenggat Waktu: $formattedDeadline',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : Colors.green,
                  ),
                ),
                const Divider(height: 24),

                // Deskripsi
                Text(
                  taskData['deskripsi'] ?? 'Tidak ada deskripsi.',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),

                // Link Lampiran (jika ada)
                if (taskData['linkLampiran'] != null &&
                    taskData['linkLampiran'].isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _launchUrl(taskData['linkLampiran']),
                    icon: const Icon(Icons.link),
                    label: const Text('Lihat Lampiran/Soal'),
                  ),
                const Divider(height: 24),

                // Area Pengumpulan
                const Text(
                  'Kumpulkan Tugas Anda',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                    'Tempelkan link (Google Drive, Canva, dll) jawaban Anda di bawah ini.'),
                const SizedBox(height: 16),

                StreamBuilder<QuerySnapshot>(
                  // Stream untuk mendapatkan data submission
                  stream: _firestore
                      .collection('submissions')
                      .where('tugasId', isEqualTo: widget.taskId)
                      .where('siswaId', isEqualTo: widget.siswaId)
                      .limit(1)
                      .snapshots(),
                  builder: (context, submissionSnapshot) {
                    if (submissionSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    Map<String, dynamic>? submissionData;
                    if (submissionSnapshot.hasData &&
                        submissionSnapshot.data!.docs.isNotEmpty) {
                      submissionData = submissionSnapshot.data!.docs.first
                          .data() as Map<String, dynamic>;
                      // Set controller dengan link yang sudah disubmit
                      _linkController.text =
                          submissionData['linkJawaban'] ?? '';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _linkController,
                            decoration: const InputDecoration(
                              labelText: 'Link Jawaban Tugas',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.link),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Link tidak boleh kosong';
                              }
                              // Validasi URL sederhana
                              if (!value.startsWith('http://') &&
                                  !value.startsWith('https://')) {
                                return 'Link tidak valid (harus diawali http:// atau https://)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                                onPressed: _submitTugas,
                                icon: const Icon(Icons.send),
                                label: Text(submissionData != null
                                    ? 'KIRIM ULANG TUGAS'
                                    : 'KIRIM TUGAS'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                ),
                              ),
                        const SizedBox(height: 24),
                        // Tampilkan Nilai & Feedback jika sudah ada
                        if (submissionData != null)
                          _buildNilaiCard(submissionData),
                      ],
                    );
                  },
                ),

                const Divider(height: 32),
                // Bagian Komentar
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
          );
        },
      ),
    );
  }
}