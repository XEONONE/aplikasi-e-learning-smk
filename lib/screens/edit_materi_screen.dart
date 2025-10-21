import 'package.aplikasi_e_learning_smk/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class EditMateriScreen extends StatefulWidget {
  final UserModel userModel;
  final QueryDocumentSnapshot materiDoc; // Menerima data materi yang akan diedit
  const EditMateriScreen({
    super.key, 
    required this.userModel, 
    required this.materiDoc
  });

  @override
  State<EditMateriScreen> createState() => _EditMateriScreenState();
}

class _EditMateriScreenState extends State<EditMateriScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mapelController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  String? _selectedKelas;
  bool _isLoading = false;

  List<String> _dropdownItems = [];
  late Map<String, dynamic> _materiData;

  @override
  void initState() {
    super.initState();
    _materiData = widget.materiDoc.data() as Map<String, dynamic>;

    // Isi controller dengan data yang ada
    _mapelController.text = _materiData['mapel'] ?? '';
    _judulController.text = _materiData['judul'] ?? '';
    _deskripsiController.text = _materiData['deskripsi'] ?? '';
    _linkController.text = _materiData['fileUrl'] ?? '';

    // Siapkan item untuk dropdown
    _dropdownItems = [
      "Semua Kelas", 
      ...?widget.userModel.mengajarKelas
    ];
    
    // Set selected value, pastikan value ada di list
    String? currentKelas = _materiData['untukKelas'];
    if (currentKelas != null && _dropdownItems.contains(currentKelas)) {
      _selectedKelas = currentKelas;
    } else {
      _selectedKelas = _dropdownItems[0]; // Default jika tidak ada
    }
  }

  @override
  void dispose() {
    _mapelController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // Fungsi untuk update materi
  Future<void> _updateMateri() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Update data di Firestore menggunakan ID dokumen
      await FirebaseFirestore.instance.collection('materi').doc(widget.materiDoc.id).update({
        'mapel': _mapelController.text.trim(),
        'judul': _judulController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'fileUrl': _linkController.text.trim(),
        'untukKelas': _selectedKelas,
        // 'diBuatOlehId', 'diBuatOleh', 'diBuatPada' tidak perlu diupdate
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Materi berhasil di-update!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(); // Kembali

    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update materi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper untuk styling input (sama seperti di create)
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
          'Edit Materi',
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
                decoration: _inputDecoration(hint: 'Mata Pelajaran'),
                validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 16),
              
              // 2. Judul Materi
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration(hint: 'Judul Materi'),
                 validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 16),

              // 3. Deskripsi
              TextFormField(
                controller: _deskripsiController,
                decoration: _inputDecoration(hint: 'Deskripsi', label: 'Deskripsi'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                 validator: (value) { /* ... validasi ... */ },
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
                 validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 16),
              
               // 5. Link Materi
              TextFormField(
                controller: _linkController,
                decoration: _inputDecoration(hint: 'Link Google Drive Materi'),
                keyboardType: TextInputType.url,
                 validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 32),

              // 6. Tombol Update
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Update', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: _updateMateri,
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