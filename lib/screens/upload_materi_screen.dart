import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class UploadMateriScreen extends StatefulWidget {
  final UserModel userModel;
  const UploadMateriScreen({super.key, required this.userModel});

  @override
  State<UploadMateriScreen> createState() => _UploadMateriScreenState();
}

class _UploadMateriScreenState extends State<UploadMateriScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mapelController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _linkController = TextEditingController(); // Untuk link GDrive

  String? _selectedKelas;
  bool _isLoading = false;

  List<String> _dropdownItems = [];

  @override
  void initState() {
    super.initState();
    // Siapkan item untuk dropdown
    _dropdownItems = [
      "Semua Kelas", // Opsi pertama
      ...?widget.userModel.mengajarKelas // Tambahkan semua kelas yang diajar guru
    ];
    _selectedKelas = _dropdownItems[0]; // Set default
  }

  @override
  void dispose() {
    _mapelController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // Fungsi untuk submit materi
  Future<void> _submitMateri() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop jika form tidak valid
    }

    setState(() { _isLoading = true; });

    try {
      // Kirim data ke Firestore
      await FirebaseFirestore.instance.collection('materi').add({
        'mapel': _mapelController.text.trim(),
        'judul': _judulController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'fileUrl': _linkController.text.trim(), // Sesuai field Firestore & desain
        'untukKelas': _selectedKelas,
        'diBuatOlehId': widget.userModel.uid, // Sesuai field Firestore
        'diBuatOleh': widget.userModel.nama, // Menambahkan nama pembuat
        'diBuatPada': FieldValue.serverTimestamp(), // Sesuai field Firestore
      });

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Materi berhasil di-upload!'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman sebelumnya
      Navigator.of(context).pop();

    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
      // Tampilkan notifikasi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal upload materi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper untuk styling input
  InputDecoration _inputDecoration({required String hint, String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label ?? hint,
      alignLabelWithHint: true,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Materi Baru',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Mata Pelajaran
              TextFormField(
                controller: _mapelController,
                decoration: _inputDecoration(hint: 'Mata Pelajaran (e.g. Informatika)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mata pelajaran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 2. Judul Materi
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration(hint: 'Judul Materi'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Deskripsi
              TextFormField(
                controller: _deskripsiController,
                decoration: _inputDecoration(
                  hint: 'Deskripsi singkat...',
                  label: 'Deskripsi',
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                 validator: (value) { // Deskripsi bisa opsional, hapus validator jika boleh kosong
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Dropdown Target Kelas
              DropdownButtonFormField<String>(
                value: _selectedKelas,
                decoration: _inputDecoration(hint: 'Untuk', label: 'Tujukan Untuk'),
                items: _dropdownItems.map((String kelas) {
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
                 validator: (value) {
                  if (value == null) {
                    return 'Silakan pilih target kelas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
               // 5. Link Materi
              TextFormField(
                controller: _linkController,
                decoration: _inputDecoration(hint: 'Link Google Drive Materi'),
                keyboardType: TextInputType.url,
                 validator: (value) { // Link bisa opsional, hapus validator jika boleh kosong
                  if (value == null || value.trim().isEmpty) {
                    return 'Link materi tidak boleh kosong';
                  }
                  if (!Uri.parse(value.trim()).isAbsolute) {
                    return 'Masukkan URL yang valid (e.g. https://...)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 6. Tombol Upload
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: const Text('Upload', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: _submitMateri,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}