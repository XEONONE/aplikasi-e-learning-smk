import 'dart:io';
import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadMateriScreen extends StatefulWidget {
  const UploadMateriScreen({super.key});

  @override
  State<UploadMateriScreen> createState() => _UploadMateriScreenState();
}

class _UploadMateriScreenState extends State<UploadMateriScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _mapelController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  String? _guruNama;
  List<String> _kelasMengajar = [];
  String? _selectedKelas;
  bool _isLoading = false;
  bool _isFetchingData = true;
  PlatformFile? _pickedFile; // File yang dipilih

  @override
  void initState() {
    super.initState();
    _fetchGuruData();
  }

  void _fetchGuruData() async {
    String? guruId = _authService.getCurrentUser()?.uid;
    if (guruId != null) {
      UserModel? guruData = await _authService.getUserData(guruId);
      if (guruData != null) {
        List<String> kelasList = ['Semua Kelas'];
        if (guruData.mengajarKelas != null &&
            guruData.mengajarKelas!.isNotEmpty) {
          kelasList.addAll(guruData.mengajarKelas!);
        }

        setState(() {
          _guruNama = guruData.nama;
          _kelasMengajar = kelasList;
          _selectedKelas =
              _kelasMengajar.isNotEmpty ? _kelasMengajar[0] : null;
          _isFetchingData = false;
        });
      } else {
        setState(() {
          _isFetchingData = false;
        });
      }
    }
  }

  Future<void> _pilihFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<String> _uploadFile(PlatformFile file) async {
    String filePath = 'materi/${_guruNama ?? 'guru'}/${file.name}';
    File fileOnPlatform = File(file.path!);

    TaskSnapshot snapshot = await _storage.ref(filePath).putFile(fileOnPlatform);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _submitMateri() async {
    if (_formKey.currentState!.validate() &&
        _selectedKelas != null &&
        _pickedFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Upload file ke Firebase Storage
        String fileUrl = await _uploadFile(_pickedFile!);

        // 2. Simpan metadata ke Firestore
        await _firestore.collection('materi').add({
          'judul': _judulController.text,
          'deskripsi': _deskripsiController.text,
          'mapel': _mapelController.text,
          'fileUrl': fileUrl,
          'fileName': _pickedFile!.name,
          'authorName': _guruNama ?? 'Guru',
          'guruId': _authService.getCurrentUser()?.uid,
          'targetKelas': _selectedKelas,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Materi berhasil diunggah!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengunggah materi: $e')),
          );
        }
      }
    } else if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda belum memilih file.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unggah Materi Baru'),
        backgroundColor: Colors.indigo,
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _judulController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Materi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deskripsiController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Singkat',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mapelController,
                      decoration: const InputDecoration(
                        labelText: 'Mata Pelajaran',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Mapel tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedKelas,
                      decoration: const InputDecoration(
                        labelText: 'Tujukan Untuk Kelas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.class_),
                      ),
                      items: _kelasMengajar.map((String kelas) {
                        return DropdownMenuItem<String>(
                          value: kelas,
                          child: Text(kelas),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedKelas = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Pilih kelas tujuan' : null,
                    ),
                    const SizedBox(height: 24),
                    // Tampilan File Picker
                    OutlinedButton.icon(
                      onPressed: _pilihFile,
                      icon: const Icon(Icons.attach_file),
                      label: Text(_pickedFile == null
                          ? 'Pilih File Materi'
                          : 'File: ${_pickedFile!.name}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _submitMateri,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('UNGGAH MATERI'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}