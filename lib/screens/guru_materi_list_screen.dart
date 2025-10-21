import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/edit_materi_screen.dart'; // Halaman edit (akan kita rombak nanti)
import 'package:aplikasi_e_learning_smk/screens/upload_materi_screen.dart'; // Halaman upload baru
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka link materi

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class GuruMateriListScreen extends StatefulWidget {
  final UserModel userModel;
  const GuruMateriListScreen({super.key, required this.userModel});

  @override
  State<GuruMateriListScreen> createState() => _GuruMateriListScreenState();
}

class _GuruMateriListScreenState extends State<GuruMateriListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mengelompokkan materi berdasarkan mata pelajaran
  Map<String, List<QueryDocumentSnapshot>> _groupMateriByMapel(
      List<QueryDocumentSnapshot> materiDocs) {
    Map<String, List<QueryDocumentSnapshot>> groupedMateri = {};
    for (var doc in materiDocs) {
      String mapel = (doc.data() as Map<String, dynamic>)['mapel'] ?? 'Lain-lain';
      if (groupedMateri[mapel] == null) {
        groupedMateri[mapel] = [];
      }
      groupedMateri[mapel]!.add(doc);
    }
    return groupedMateri;
  }
  
  // Fungsi untuk hapus materi
  Future<void> _deleteMateri(String docId, String judul) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
             Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
             SizedBox(height: 16),
             Text('Konfirmasi Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Apakah Anda yakin ingin menghapus materi "$judul"? Tindakan ini tidak dapat diurungkan.'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('materi').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materi berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus materi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi untuk navigasi ke halaman edit
  void _editMateri(QueryDocumentSnapshot materiDoc) {
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMateriScreen(
          materiDoc: materiDoc, // Mengirim data materi yang akan diedit
          userModel: widget.userModel,
        ),
      ),
    );
  }

  // Fungsi untuk membuka link materi
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak bisa membuka link: $url'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // FAB untuk tambah materi
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadMateriScreen(userModel: widget.userModel),
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query materi yang dibuat oleh guru ini, diurutkan berdasarkan mapel
        stream: _firestore
            .collection('materi')
            .where('diBuatOlehId', isEqualTo: widget.userModel.uid)
            .orderBy('mapel')
            .orderBy('diBuatPada', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum mengupload materi.\nKlik tombol + untuk menambah.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Kelompokkan data
          var groupedMateri = _groupMateriByMapel(snapshot.data!.docs);
          var mapelKeys = groupedMateri.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mapelKeys.length,
            itemBuilder: (context, index) {
              String mapel = mapelKeys[index];
              List<QueryDocumentSnapshot> materiList = groupedMateri[mapel]!;

              // Gunakan ExpansionTile untuk accordion
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias, // Penting untuk border radius
                child: ExpansionTile(
                  title: Text(
                    mapel,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${materiList.length} materi'),
                  initiallyExpanded: true, // Default terbuka
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(top: 0),
                   backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  children: materiList.map((doc) {
                    return _buildMateriCard(doc); // Buat kartu untuk setiap materi
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget untuk kartu materi
  Widget _buildMateriCard(QueryDocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    String judul = data['judul'] ?? 'Tanpa Judul';
    String untukKelas = data['untukKelas'] ?? 'Semua Kelas';
    String fileUrl = data['fileUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            judul,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          // Target Kelas
          Text(
            'Untuk: $untukKelas',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // Baris Tombol Aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Lihat Materi (jika ada link)
              if (fileUrl.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.link, size: 18, color: kPrimaryColor),
                  label: const Text('Lihat Link', style: TextStyle(color: kPrimaryColor)),
                  onPressed: () => _launchURL(fileUrl),
                ),
              if (fileUrl.isEmpty)
                const Spacer(), // Beri jarak jika tidak ada link
              
              // Tombol Edit & Hapus
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.orange),
                    label: const Text('Edit', style: TextStyle(color: Colors.orange)),
                    onPressed: () => _editMateri(doc),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    onPressed: () => _deleteMateri(doc.id, judul),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}