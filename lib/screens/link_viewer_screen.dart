// lib/screens/link_viewer_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_e_learning_smk/services/dynamic_link_service.dart';
import 'package:aplikasi_e_learning_smk/models/materi_model.dart';
import 'package:aplikasi_e_learning_smk/models/tugas_model.dart';
import 'package:aplikasi_e_learning_smk/models/pengumuman_model.dart';

class LinkViewerScreen extends StatefulWidget {
  final String shortCode;

  const LinkViewerScreen({super.key, required this.shortCode});

  @override
  State<LinkViewerScreen> createState() => _LinkViewerScreenState();
}

class _LinkViewerScreenState extends State<LinkViewerScreen> {
  bool isLoading = true;
  Map<String, dynamic>? data;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      Map<String, dynamic>? result = await DynamicLinkService.getDataFromLink(widget.shortCode);
      
      if (result != null) {
        setState(() {
          data = result;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Link tidak ditemukan atau sudah tidak aktif';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Content'),
        actions: [
          if (data != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareLink,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorView()
              : _buildDataView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataView() {
    String type = data!['linkInfo']['type'];
    
    switch (type) {
      case 'materi':
        return _buildMateriView();
      case 'tugas':
        return _buildTugasView();
      case 'pengumuman':
        return _buildPengumumanView();
      default:
        return const Center(child: Text('Unknown content type'));
    }
  }

  Widget _buildMateriView() {
    MateriModel materi = MateriModel.fromMap(data!);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.book, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MATERI PEMBELAJARAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        materi.judul,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    materi.deskripsi,
                    style: const TextStyle(fontSize: 14),
                  ),
                  
                  if (materi.fileUrl != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'File Terlampir',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openFile(materi.fileUrl!),
                      icon: const Icon(Icons.download),
                      label: const Text('Download File'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Metadata
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetadataRow('Guru', materi.namaGuru),
                  _buildMetadataRow('Tanggal', _formatDate(materi.tanggalDibuat)),
                  _buildMetadataRow('Link Clicks', '${data!['linkInfo']['clickCount']}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTugasView() {
    TugasModel tugas = TugasModel.fromMap(data!);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment, size: 32, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TUGAS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        tugas.judul,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Deadline Warning
          if (tugas.deadline != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Deadline: ${_formatDate(tugas.deadline)}',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi Tugas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tugas.deskripsi,
                    style: const TextStyle(fontSize: 14),
                  ),
                  
                  if (tugas.fileUrl != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'File Terlampir',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openFile(tugas.fileUrl!),
                      icon: const Icon(Icons.download),
                      label: const Text('Download File'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Metadata
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetadataRow('Guru', tugas.namaGuru),
                  _buildMetadataRow('Tanggal Dibuat', _formatDate(tugas.tanggalDibuat)),
                  if (tugas.deadline != null)
                    _buildMetadataRow('Deadline', _formatDate(tugas.deadline)),
                  _buildMetadataRow('Link Clicks', '${data!['linkInfo']['clickCount']}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengumumanView() {
    PengumumanModel pengumuman = PengumumanModel.fromMap(data!);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.announcement, size: 32, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PENGUMUMAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        pengumuman.judul,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Isi Pengumuman',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pengumuman.isi,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Metadata
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetadataRow('Dibuat oleh', pengumuman.namaGuru),
                  _buildMetadataRow('Tanggal', _formatDate(pengumuman.tanggalDibuat)),
                  _buildMetadataRow('Link Clicks', '${data!['linkInfo']['clickCount']}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    
    // Handle Firestore Timestamp
    if (date.runtimeType.toString().contains('Timestamp')) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        date.millisecondsSinceEpoch,
      );
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    return date.toString();
  }

  void _openFile(String fileUrl) {
    // Implementasi untuk membuka file
    // Bisa menggunakan url_launcher atau browser
  }

  void _shareLink() {
    String fullUrl = '${DynamicLinkService.baseUrl}/link/${widget.shortCode}';
    Clipboard.setData(ClipboardData(text: fullUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }
}
