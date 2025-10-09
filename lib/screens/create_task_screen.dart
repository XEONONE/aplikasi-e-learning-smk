import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:intl/intl.dart'; // Impor paket intl

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _authService = AuthService();

  DateTime? _tenggatWaktu;
  bool _isLoading = false;

  Future<void> _pilihTanggal() async {
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
    if (_formKey.currentState!.validate() && _tenggatWaktu != null) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('tugas').add({
          'judul': _judulController.text.trim(),
          'deskripsi': _deskripsiController.text.trim(),
          'tenggatWaktu': Timestamp.fromDate(_tenggatWaktu!),
          'dibuatPada': Timestamp.now(),
          'dibuatOlehUid': _authService.getCurrentUser()!.uid,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil dibuat!')));
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal membuat tugas: $e')));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap lengkapi semua field dan pilih tenggat waktu.')));
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
      appBar: AppBar(title: const Text('Buat Tugas Baru')),
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
                    labelText: 'Judul Tugas', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                    labelText: 'Instruksi/Deskripsi',
                    border: OutlineInputBorder()),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_tenggatWaktu == null
                    ? 'Pilih Tenggat Waktu'
                    // Menggunakan intl untuk format yang lebih baik
                    : 'Tenggat: ${DateFormat('d MMM yyyy, HH:mm').format(_tenggatWaktu!)}'),
                onPressed: _pilihTanggal,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('SIMPAN TUGAS'),
                      onPressed: _simpanTugas,
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