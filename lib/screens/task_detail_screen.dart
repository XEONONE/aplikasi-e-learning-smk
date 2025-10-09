import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';

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
  File? _selectedFile;
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pilihFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _kumpulkanTugas() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih file jawaban Anda.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final currentUserUid = _authService.getCurrentUser()!.uid;

    try {
      // 1. Upload file jawaban ke Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('jawaban_tugas/${widget.taskId}/$currentUserUid-$_fileName');
      UploadTask uploadTask = storageRef.putFile(_selectedFile!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // 2. Simpan info pengumpulan di sub-collection 'pengumpulan'
      await FirebaseFirestore.instance
          .collection('tugas')
          .doc(widget.taskId)
          .collection('pengumpulan')
          .doc(currentUserUid) // Gunakan UID siswa sebagai ID dokumen
          .set({
        'fileUrl': downloadUrl,
        'fileName': _fileName,
        'dikumpulkanPada': Timestamp.now(),
        'siswaUid': currentUserUid,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tugas berhasil dikumpulkan!'),
          backgroundColor: Colors.green));
      Navigator.pop(context);

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

  @override
  Widget build(BuildContext context) {
    DateTime tenggat = (widget.taskData['tenggatWaktu'] as Timestamp).toDate();
    String formattedTenggat = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id_ID').format(tenggat);

    return Scaffold(
      appBar: AppBar(title: Text(widget.taskData['judul'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instruksi Tugas:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.taskData['deskripsi'], style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),
            Text('Tenggat Waktu:', style: Theme.of(context).textTheme.titleMedium),
            Text(formattedTenggat, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            const Divider(height: 32),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}