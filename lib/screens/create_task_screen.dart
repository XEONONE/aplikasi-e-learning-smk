// lib/screens/create_task_screen.dart

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
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _linkController = TextEditingController();
  final _authService = AuthService();

  DateTime? _tenggatWaktu;
  bool _isLoading = false;
  List<String> _daftarKelas = [];
  String? _selectedKelas;

  // -- BARU: Tambahkan controller untuk Mata Pelajaran --
  final _mapelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    // ... (fungsi _fetchKelas tetap sama) ...
    try {
      var snapshot = await FirebaseFirestore.instance.collection('kelas').get();
      if (!mounted) return;
      List<String> kelas = snapshot.docs
          .map((doc) => doc['namaKelas'] as String)
          .toList();
      setState(() {
        _daftarKelas = kelas;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pilihTanggal() async {
    // ... (fungsi _pilihTanggal tetap sama) ...
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && mounted) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _tenggatWaktu = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _simpanTugas() async {
    // -- PERBAIKAN: Tambahkan validasi mapel --
    if (_formKey.currentState!.validate() &&
        _tenggatWaktu != null &&
        _selectedKelas != null) {
      setState(() => _isLoading = true);
      try {
        final Map<String, dynamic> dataToSave = {
          'judul': _judulController.text.trim(),
          'deskripsi': _deskripsiController.text.trim(),
          // -- BARU: Tambahkan mata pelajaran ke data yang disimpan --
          'mataPelajaran': _mapelController.text.trim(),
          'tenggatWaktu': Timestamp.fromDate(_tenggatWaktu!),
          'dibuatPada': Timestamp.now(),
          'dibuatOlehUid': _authService.getCurrentUser()!.uid,
          'untukKelas': _selectedKelas,
          'fileUrl': _linkController.text.trim().isEmpty
              ? null
              : _linkController.text.trim(),
        };

        await FirebaseFirestore.instance.collection('tugas').add(dataToSave);

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tugas berhasil dibuat!')));
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat tugas: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harap lengkapi semua field yang wajib diisi (judul, instruksi, mapel, kelas, tenggat).',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _linkController.dispose();
    _mapelController.dispose(); // -- BARU: Dispose mapel controller --
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil tema saat ini
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tugas'),
        backgroundColor: Colors.transparent, // Transparan agar sesuai gambar
        elevation: 0,
      ),
      // -- BARU: Gunakan Stack untuk menempatkan Form di atas background --
      body: Stack(
        children: [
          // -- BARU: Background Gradasi --
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade900, // Warna gelap atas
                  Colors.black, // Warna gelap bawah
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // -- BARU: SingleChildScrollView untuk konten form --
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // -- BARU: Judul "Manajemen Tugas" (opsional, karena sudah ada di AppBar) --
                  // Text('Manajemen Tugas', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 24),

                  // -- BARU: Field Mata Pelajaran --
                  TextFormField(
                    controller: _mapelController,
                    style: const TextStyle(color: Colors.white), // Teks putih
                    decoration: InputDecoration(
                      labelText: 'Mata Pelajaran',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade800.withOpacity(
                        0.5,
                      ), // Latar semi-transparan
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border saat focus
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Mata pelajaran tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // -- AKHIR BARU --
                  TextFormField(
                    controller: _judulController,
                    style: const TextStyle(color: Colors.white), // Teks putih
                    decoration: InputDecoration(
                      labelText: 'Judul Tugas',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade800.withOpacity(
                        0.5,
                      ), // Latar semi-transparan
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border saat focus
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deskripsiController,
                    style: const TextStyle(color: Colors.white), // Teks putih
                    decoration: InputDecoration(
                      labelText: 'Instruksi Tugas...',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade800.withOpacity(
                        0.5,
                      ), // Latar semi-transparan
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border saat focus
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    maxLines: 5,
                    validator: (value) =>
                        value!.isEmpty ? 'Instruksi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedKelas, // Tampilkan nilai yang terpilih
                    hint: Text(
                      'Untuk...',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    dropdownColor:
                        Colors.grey.shade800, // Warna background dropdown
                    style: const TextStyle(
                      color: Colors.white,
                    ), // Warna teks item
                    items: _daftarKelas.map((String kelas) {
                      return DropdownMenuItem<String>(
                        value: kelas,
                        child: Text(kelas),
                      );
                    }).toList(),
                    onChanged: (String? newValue) =>
                        setState(() => _selectedKelas = newValue),
                    validator: (value) =>
                        value == null ? 'Kelas harus dipilih' : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade800.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border saat focus
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Tambah jarak
                  // -- PERBAIKAN: Gunakan TextFormField untuk Tanggal/Waktu --
                  TextFormField(
                    readOnly: true, // Tidak bisa diketik langsung
                    controller: TextEditingController(
                      // Buat controller sementara
                      text: _tenggatWaktu == null
                          ? ''
                          : 'Tenggat (e.g. ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_tenggatWaktu!)} )',
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Tenggat',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade800.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border saat focus
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    onTap: _pilihTanggal, // Panggil date picker saat ditekan
                    validator: (_) => _tenggatWaktu == null
                        ? 'Tenggat waktu harus dipilih'
                        : null,
                  ),
                  // -- AKHIR PERBAIKAN --
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _linkController,
                    style: const TextStyle(color: Colors.white), // Teks putih
                    decoration: InputDecoration(
                      labelText: 'Link Soal (Opsional)',
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.link, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade800.withOpacity(
                        0.5,
                      ), // Latar semi-transparan
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border saat focus
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          // -- BARU: Gunakan Row untuk tombol --
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.pop(context), // Aksi tombol Batal
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                child: const Text('Batal'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _simpanTugas, // Aksi tombol Simpan
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Simpan'),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
