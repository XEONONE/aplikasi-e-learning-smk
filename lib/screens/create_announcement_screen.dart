import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateAnnouncementScreen({super.key, required this.userModel});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();

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
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  // Fungsi untuk kirim pengumuman
  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop jika form tidak valid
    }

    setState(() { _isLoading = true; });

    try {
      // Kirim data ke Firestore
      await FirebaseFirestore.instance.collection('pengumuman').add({
        'judul': _judulController.text.trim(),
        'isi': _isiController.text.trim(),
        'untukKelas': _selectedKelas,
        'diBuatOlehId': widget.userModel.uid, // Sesuai field Firestore
        'diBuatOleh': widget.userModel.nama, // Menambahkan nama pembuat
        'diBuatPada': FieldValue.serverTimestamp(), // Sesuai field Firestore
      });

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengumuman berhasil dikirim!'),
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
          content: Text('Gagal mengirim pengumuman: $e'),
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
          'Buat Pengumuman',
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
              // 1. Judul
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration(hint: 'Judul Pengumuman'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Isi Pengumuman
              TextFormField(
                controller: _isiController,
                decoration: _inputDecoration(
                  hint: 'Isi Pengumuman...',
                  label: 'Isi Pengumuman',
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi pengumuman tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Dropdown Target Kelas
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
              const SizedBox(height: 32),

              // 4. Tombol Kirim
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Kirim', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: _submitAnnouncement,
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