// lib/screens/task_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/comment_section.dart';
import 'package:aplikasi_e_learning_smk/widgets/custom_loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.taskData,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _authService = AuthService();
  final _linkController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka link $urlString')),
        );
      }
    }
  }

  Future<void> _kumpulkanTugas() async {
    if (_linkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan link jawaban Anda.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // JEDA 2 DETIK
    await Future.delayed(const Duration(seconds: 2));

    final currentUserUid = _authService.getCurrentUser()!.uid;
    final String linkJawaban = _linkController.text.trim();

    try {
      await FirebaseFirestore.instance
          .collection('tugas')
          .doc(widget.taskId)
          .collection('pengumpulan')
          .doc(currentUserUid)
          .set({
        'fileUrl': linkJawaban,
        'fileName': 'Link Jawaban',
        'dikumpulkanPada': Timestamp.now(),
        'siswaUid': currentUserUid,
        'nilai': null,
        'feedback': '',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil dikumpulkan!'),
          backgroundColor: Colors.green,
        ),
      );
      _linkController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengumpulkan: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSubmissionStatus(DocumentSnapshot submissionDoc) {
    final data = submissionDoc.data() as Map<String, dynamic>;
    final dikumpulkanPada = (data['dikumpulkanPada'] as Timestamp).toDate();
    final nilai = data['nilai'];
    final feedback = data['feedback'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anda Sudah Mengumpulkan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
              'Pada: ${DateFormat.yMMMMEEEEd('id_ID').add_Hms().format(dikumpulkanPada)}'),
          const Divider(height: 24),
          Text('Nilai: ${nilai ?? "Belum dinilai"}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Feedback Guru: $feedback'),
          ]
        ],
      ),
    );
  }

  Widget _buildSubmissionForm(DateTime tenggat) {
    bool isLate = DateTime.now().isAfter(tenggat);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isLate)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Anda terlambat mengumpulkan tugas. Anda tetap bisa mengumpulkan, namun akan ditandai terlambat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _linkController,
          decoration: const InputDecoration(
            labelText: 'Masukkan Link Google Drive Jawaban',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
        ),
        const SizedBox(height: 16),
        _isLoading
            ? const CustomLoadingIndicator()
            : ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('KUMPULKAN'),
                onPressed: _kumpulkanTugas,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String judul = widget.taskData['judul'];
    final String deskripsi = widget.taskData['deskripsi'];
    final String mapel = widget.taskData['mataPelajaran'];
    final String fileUrl = widget.taskData['fileUrl'] ?? '';
    final DateTime tenggat = (widget.taskData['tenggatWaktu'] as Timestamp).toDate();
    final String formattedTenggat =
        DateFormat.yMMMMEEEEd('id_ID').add_Hms().format(tenggat);
    final currentUserUid = _authService.getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(mapel),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tenggat: $formattedTenggat',
              style: TextStyle(color: Colors.red.shade700),
            ),
            const Divider(height: 24),
            Text(
              deskripsi,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (fileUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Lihat Lampiran/Soal'),
                onPressed: () => _launchUrl(fileUrl),
              ),
            ],
            const Divider(height: 32),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tugas')
                  .doc(widget.taskId)
                  .collection('pengumpulan')
                  .doc(currentUserUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomLoadingIndicator();
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  return _buildSubmissionStatus(snapshot.data!);
                }
                return _buildSubmissionForm(tenggat);
              },
            ),
            const Divider(height: 32),
            CommentSection(
              collectionPath: 'tugas', 
              documentId: widget.taskId,
            ),
          ],
        ),
      ),
    );
  }
}