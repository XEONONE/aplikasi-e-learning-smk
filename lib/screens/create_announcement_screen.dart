import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String? _guruNama;
  List<String> _kelasMengajar = [];
  String? _selectedKelas;
  bool _isLoading = false;
  bool _isFetchingData = true;

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
        // Ambil data kelas yang diajar guru
        List<String> kelasList = ['Semua Kelas']; // Tambahkan opsi 'Semua Kelas'
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
        // Handle error jika data guru tidak ditemukan
      }
    }
  }

  void _submitPengumuman() async {
    if (_formKey.currentState!.validate() && _selectedKelas != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _firestore.collection('pengumuman').add({
          'judul': _judulController.text,
          'isi': _isiController.text,
          'authorName': _guruNama ?? 'Guru',
          'authorId': _authService.getCurrentUser()?.uid,
          'targetKelas': _selectedKelas,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Pengumuman berhasil dipublikasikan!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat pengumuman: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pengumuman Baru'),
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
                        labelText: 'Judul Pengumuman',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _isiController,
                      decoration: const InputDecoration(
                        labelText: 'Isi Pengumuman',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Isi pengumuman tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedKelas,
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
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih kelas tujuan';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _submitPengumuman,
                            icon: const Icon(Icons.send),
                            label: const Text('PUBLIKASIKAN'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding:
                                  const EdgeInsets.symmetric(vertical