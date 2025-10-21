import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class EditTaskScreen extends StatefulWidget {
  final UserModel userModel;
  final QueryDocumentSnapshot taskDoc; // Menerima data tugas yang akan diedit
  const EditTaskScreen({
    super.key, 
    required this.userModel, 
    required this.taskDoc
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _instruksiController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();

  String? _selectedKelas;
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  List<String> _dropdownItems = [];
  late Map<String, dynamic> _taskData;

  @override
  void initState() {
    super.initState();
    _taskData = widget.taskDoc.data() as Map<String, dynamic>;

    // Isi controller dengan data yang ada
    _judulController.text = _taskData['judul'] ?? '';
    _instruksiController.text = _taskData['deskripsi'] ?? '';
    _linkController.text = _taskData['fileUrl'] ?? '';

    // Isi data tenggat waktu
    if (_taskData['tenggatWaktu'] != null) {
      Timestamp ts = _taskData['tenggatWaktu'];
      _selectedDeadline = ts.toDate();
      _deadlineController.text = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(_selectedDeadline!);
    }

    // Siapkan item untuk dropdown
    _dropdownItems = [
      "Semua Kelas", 
      ...?widget.userModel.mengajarKelas
    ];
    
    String? currentKelas = _taskData['untukKelas'];
    if (currentKelas != null && _dropdownItems.contains(currentKelas)) {
      _selectedKelas = currentKelas;
    } else {
      _selectedKelas = _dropdownItems[0];
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _instruksiController.dispose();
    _linkController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih tanggal dan waktu (sama seperti create)
  Future<void> _pickDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(), // Mungkin Anda ingin izinkan edit ke masa lalu?
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _deadlineController.text = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(_selectedDeadline!);
        });
      }
    }
  }

  // Fungsi untuk update tugas
  void _updateTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
     if (_selectedDeadline == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tenggat waktu tidak boleh kosong.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Update data di Firestore
      await FirebaseFirestore.instance.collection('tugas').doc(widget.taskDoc.id).update({
        'judul': _judulController.text.trim(),
        'deskripsi': _instruksiController.text.trim(),
        'fileUrl': _linkController.text.trim(),
        'untukKelas': _selectedKelas,
        'tenggatWaktu': Timestamp.fromDate(_selectedDeadline!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil di-update!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();

    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update tugas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Helper untuk styling input (sama seperti di create)
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
          'Edit Tugas',
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
                validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 16),

              // 2. Instruksi Tugas
              TextFormField(
                controller: _instruksiController,
                decoration: _inputDecoration(hint: 'Instruksi', label: 'Instruksi'),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                 validator: (value) { /* ... validasi ... */ },
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
                 validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 16),
              
              // 4. Input Tenggat Waktu
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                decoration: _inputDecoration(
                  hint: 'Pilih Tenggat Waktu',
                  suffixIcon: const Icon(Icons.calendar_month, color: kPrimaryColor),
                ),
                onTap: _pickDeadline,
                validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 16),
              
               // 5. Link Soal (Opsional)
              TextFormField(
                controller: _linkController,
                decoration: _inputDecoration(hint: 'Link Soal (Opsional)'),
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
                      onPressed: _updateTask,
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