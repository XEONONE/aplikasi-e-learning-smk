import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// PERBAIKAN DI SINI: Menggunakan ':' bukan '.'
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';

class UploadMateriScreen extends StatefulWidget {
  const UploadMateriScreen({super.key});

  @override
  State<UploadMateriScreen> createState() => _UploadMateriScreenState();
}

class _UploadMateriScreenState extends State<UploadMateriScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
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

  Future<void> _uploadMateri() async {
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      setState(() => _isLoading = true);
      try {
        // 1. Upload file ke Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('materi/${DateTime.now().millisecondsSinceEpoch}_$_fileName');
        UploadTask uploadTask = storageRef.putFile(_selectedFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // 2. Simpan informasi materi ke Firestore
        await FirebaseFirestore.instance.collection('materi').add({
          'judul': _judulController.text.trim(),
          'deskripsi': _deskripsiController.text.trim(),
          'fileUrl': downloadUrl,
          'fileName': _fileName,
          'diunggahPada': Timestamp.now(),
          'diunggahOlehUid': _authService.getCurrentUser()!.uid,
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Materi berhasil diunggah!')));
        Navigator.pop(context);

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal mengunggah: $e')));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Harap lengkapi semua field dan pilih file.')));
    }
  }
  
  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Materi Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                    labelText: 'Judul Materi', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Pilih File'),
                onPressed: _pilihFile,
              ),
              if (_fileName != null) ...[
                const SizedBox(height: 8),
                Text('File terpilih: $_fileName',
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('UPLOAD MATERI'),
                      onPressed: _uploadMateri,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}