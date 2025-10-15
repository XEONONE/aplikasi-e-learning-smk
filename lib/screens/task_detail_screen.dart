// lib/screens/task_detail_screen.dart

import 'package:flutter/foundation.dart' show Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/comment_section.dart';
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
  Uint8List? _selectedFileBytes;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _pilihFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _selectedFileBytes = result.files.single.bytes;
      });
    }
  }

  Future<void> _kumpulkanTugas() async {
    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih file jawaban Anda.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final currentUserUid = _authService.getCurrentUser()!.uid;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('jawaban_tugas/${widget.taskId}/$currentUserUid-$_fileName');
      
      UploadTask uploadTask = storageRef.putData(_selectedFileBytes!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('tugas')
          .doc(widget.taskId)
          .collection('pengumpulan')
          .doc(currentUserUid)
          .set({
        'fileUrl': downloadUrl,
        'fileName': _fileName,
        'dikumpulkanPada': Timestamp.now(),
        'siswaUid': currentUserUid,
        'nilai': null,
        'feedback': '',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tugas berhasil dikumpulkan!'),
          backgroundColor: Colors.green));

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
    final nilai = data['nilai'];
    final feedback = data['feedback'];
    final dikumpulkanPada = (data['dikumpulkanPada'] as Timestamp).toDate();
    final formattedDate = DateFormat('d MMM yyyy, HH:mm').format(dikumpulkanPada);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status Anda:', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('Tugas Sudah Dikumpulkan'),
          subtitle: Text('Pada: $formattedDate'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.grade, color: Colors.amber),
          title: const Text('Nilai'),
          subtitle: Text(
            nilai == null ? 'Belum dinilai' : nilai.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.feedback, color: Colors.blue),
          title: const Text('Feedback dari Guru'),
          subtitle: Text(
            (feedback == null || feedback.isEmpty) ? 'Belum ada feedback.' : feedback,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kumpulkan Jawaban Anda:', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.attach_file),
          label: Text(_fileName ?? 'Pilih File Jawaban'),
          onPressed: _pilihFile,
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('KUMPULKAN TUGAS'),
                  onPressed: _kumpulkanTugas,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime tenggat = (widget.taskData['tenggatWaktu'] as Timestamp).toDate();
    String formattedTenggat =
        DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id_ID').format(tenggat);
    final currentUserUid = _authService.getCurrentUser()!.uid;

    final String? fileSoalUrl = widget.taskData['fileUrl'];
    final String? fileSoalName = widget.taskData['fileName'];

    return Scaffold(
      appBar: AppBar(title: Text(widget.taskData['judul'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instruksi Tugas:',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.taskData['deskripsi'],
                style: const TextStyle(fontSize: 16)),
            
            if (fileSoalUrl != null) ...[
              const SizedBox(height: 24),
              Text('Lampiran Soal:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.attach_file, color: Colors.deepPurple,),
                  title: Text(fileSoalName ?? 'Lihat File Soal'),
                  trailing: const Icon(Icons.download_for_offline),
                  onTap: () => _launchUrl(fileSoalUrl),
                ),
              )
            ],

            const Divider(height: 32),
            Text('Tenggat Waktu:',
                style: Theme.of(context).textTheme.titleMedium),
            Text(formattedTenggat,
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  return _buildSubmissionStatus(snapshot.data!);
                }
                return _buildSubmissionForm();
              },
            ),
            
            const Divider(height: 48),
            CommentSection(
              documentId: widget.taskId,
              collectionPath: 'tugas',
            ),
          ],
        ),
      ),
    );
  }
}