import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  final UserModel userModel;
  const CreateTaskScreen({super.key, required this.userModel});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _instruksiController = TextEditingController();
  final TextEditingController _linkController = TextEditingController(); // Link Soal Opsional
  final TextEditingController _deadlineController = TextEditingController(); // Hanya untuk tampilan

  String? _selectedKelas;
  DateTime? _selectedDeadline; // Untuk menyimpan DateTime
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
    _instruksiController.dispose();
    _linkController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih tanggal dan waktu
  Future<void> _pickDeadline() async {
    // 1. Pilih Tanggal
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      // 2. Pilih Waktu
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline ?? DateTime.now()),
      );

      if (pickedTime != null) {
        // Gabungkan tanggal dan waktu
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // Format untuk ditampilkan di TextField
          _deadlineController.text = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(_selectedDeadline!);
        });
      }
    }
  }

  // Fungsi untuk submit tugas
  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop jika form tidak valid
    }
    
    if (_selectedDeadline == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tenggat waktu terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Kirim data ke Firestore
      await FirebaseFirestore.instance.collection('tugas').add({
        'judul': _judulController.text.trim(),
        'deskripsi': _instruksiController.text.trim(),
        'fileUrl': _linkController.text.trim(), // Sesuai field Firestore (Link Soal Opsional)
        'untukKelas': _selectedKelas,
        'tenggatWaktu': Timestamp.fromDate(_selectedDeadline!), // Sesuai field Firestore
        'diBuatOlehId': widget.userModel.uid, // Sesuai field Firestore
        'diBuatOleh': widget.userModel.nama, // Menambahkan nama pembuat
        'diBuatPada': FieldValue.serverTimestamp(), // Sesuai field Firestore
      });

      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil dibuat!'),
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
          content: Text('Gagal membuat tugas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper untuk styling input
  InputDecoration _inputDecoration({required String hint, String? label, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      labelText: label ?? hint,
      alignLabelWithHint: true,
      filled: true,
      fillColor: Colors.grey[50],
      suffixIcon: suffixIcon,
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
          'Buat Tugas Baru',
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
              // 1. Judul Tugas
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration(hint: 'Judul Tugas'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Instruksi Tugas
              TextFormField(
                controller: _instruksiController,
                decoration: _inputDecoration(
                  hint: 'Instruksi tugas...',
                  label: 'Instruksi',
                ),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                 validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Instruksi tidak boleh kosong';
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
              const SizedBox(height: 16),
              
              // 4. Input Tenggat Waktu (DateTimePicker)
              TextFormField(
                controller: _deadlineController,
                readOnly: true, // Tidak bisa diketik manual
                decoration: _inputDecoration(
                  hint: 'Pilih Tenggat Waktu',
                  suffixIcon: const Icon(Icons.calendar_month, color: kPrimaryColor),
                ),
                onTap: _pickDeadline, // Panggil picker saat diklik
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tenggat waktu tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
               // 5. Link Soal (Opsional)
              TextFormField(
                controller: _linkController,
                decoration: _inputDecoration(hint: 'Link Soal (Opsional)'),
                keyboardType: TextInputType.url,
                 validator: (value) { // Opsional, jadi tidak perlu validasi
                  if (value != null && value.trim().isNotEmpty && !Uri.parse(value.trim()).isAbsolute) {
                     return 'Masukkan URL yang valid (e.g. https://...)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 6. Tombol Simpan
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: _submitTask,
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