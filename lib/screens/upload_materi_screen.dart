import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Uint8List? _selectedFileBytes;
  String? _fileName;
  bool _isLoading = false;
  
  List<String> _daftarKelas = [];
  String? _selectedKelas;

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('kelas').get();
      if (!mounted) return;
      List<String> kelas = snapshot.docs.map((doc) => doc['namaKelas'] as String).toList();
      setState(() {
        _daftarKelas = kelas;
      });
    } catch (e) {
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat daftar kelas: $e')),
      );
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

  Future<void> _uploadMateri() async {
    if (_formKey.currentState!.validate() && _selectedFileBytes != null && _selectedKelas != null) {
      setState(() => _isLoading = true);
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('materi/${DateTime.now().millisecondsSinceEpoch}_$_fileName');
        UploadTask uploadTask = storageRef.putData(_selectedFileBytes!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('materi').add({
          'judul': _judulController.text.trim(),
          'deskripsi': _deskripsiController.text.trim(),
          'fileUrl': downloadUrl,
          'fileName': _fileName,
          'diunggahPada': Timestamp.now(),
          'diunggahOlehUid': _authService.getCurrentUser()!.uid,
          'untukKelas': _selectedKelas,
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
            .showSnackBar(const SnackBar(content: Text('Harap lengkapi semua field, pilih kelas, dan pilih file.')));
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedKelas,
                hint: const Text('Pilih Kelas'),
                items: _daftarKelas.map((String kelas) {
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
                validator: (value) => value == null ? 'Kelas harus dipilih' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
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