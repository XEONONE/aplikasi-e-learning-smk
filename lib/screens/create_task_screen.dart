import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _mapelController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String? _guruNama;
  List<String> _kelasMengajar = [];
  String? _selectedKelas;
  bool _isLoading = false;
  bool _isFetchingData = true;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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

  // Fungsi untuk memilih tanggal
  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk memilih waktu
  Future<void> _pilihWaktu(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitTugas() async {
    if (_formKey.currentState!.validate() &&
        _selectedKelas != null &&
        _selectedDate != null &&
        _selectedTime != null) {
      setState(() {
        _isLoading = true;
      });

      // Gabungkan tanggal dan waktu menjadi satu DateTime
      final DateTime deadline = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      try {
        await _firestore.collection('tugas').add({
          'judul': _judulController.text,
          'deskripsi': _deskripsiController.text,
          'mapel': _mapelController.text,
          'linkLampiran': _linkController.text, // Link opsional
          'deadline': Timestamp.fromDate(deadline),
          'authorName': _guruNama ?? 'Guru',
          'guruId': _authService.getCurrentUser()?.uid,
          'targetKelas': _selectedKelas,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil dibuat!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat tugas: $e')),
          );
        }
      }
    } else if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tenggat waktu belum lengkap.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal dan waktu yang dipilih
    String formattedDate = _selectedDate == null
        ? 'Pilih Tanggal'
        : DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!);
    String formattedTime = _selectedTime == null
        ? 'Pilih Waktu'
        : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tugas Baru'),
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
                        labelText: 'Judul Tugas',
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
                        labelText: 'Deskripsi Tugas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 5,
                      validator: (value) => value!.isEmpty
                          ? 'Deskripsi tidak boleh kosong'
                          : null,
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
                    TextFormField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link Lampiran (Opsional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
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
                    const SizedBox(height: 16),
                    // Input Tenggat Waktu (Tanggal & Jam)
                    const Text('Tenggat Waktu:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pilihTanggal(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(formattedDate),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pilihWaktu(context),
                            icon: const Icon(Icons.access_time),
                            label: Text(formattedTime),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _submitTugas,
                            icon: const Icon(Icons.save),
                            label: const Text('BUAT TUGAS'),
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