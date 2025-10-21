import 'package:aplikasi_e_learning_smk/screens/upload_materi_screen.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuruMateriListScreen extends StatefulWidget {
  const GuruMateriListScreen({super.key});

  @override
  State<GuruMateriListScreen> createState() => _GuruMateriListScreenState();
}

class _GuruMateriListScreenState extends State<GuruMateriListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _guruId = AuthService().getCurrentUser()?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil semua materi yang dibuat oleh guru ini
        stream: _firestore
            .collection('materi')
            .where('guruId', isEqualTo: _guruId)
            .orderBy('mapel') // Mengelompokkan berdasarkan mata pelajaran
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum mengunggah materi apapun.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi error.'));
          }

          var materiDocs = snapshot.data!.docs;
          Map<String, List<DocumentSnapshot>> groupedMateri = {};

          // Proses pengelompokan materi berdasarkan mata pelajaran
          for (var doc in materiDocs) {
            String mapel = doc['mapel'] ?? 'Lain-lain';
            if (!groupedMateri.containsKey(mapel)) {
              groupedMateri[mapel] = [];
            }
            groupedMateri[mapel]!.add(doc);
          }

          // Buat daftar yang bisa di-scroll
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: groupedMateri.keys.length,
            itemBuilder: (context, index) {
              String mapel = groupedMateri.keys.elementAt(index);
              List<DocumentSnapshot> items = groupedMateri[mapel]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Grup Mata Pelajaran
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      mapel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  // Daftar materi di dalam grup
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, itemIndex) {
                      var materi =
                          items[itemIndex].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 3.0,
                        child: ListTile(
                          leading: const Icon(Icons.description,
                              color: Colors.indigo),
                          title: Text(materi['judul'] ?? 'Tanpa Judul'),
                          subtitle: Text(materi['deskripsi'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Tambahkan navigasi ke halaman edit/detail materi
                            // Navigator.of(context).push(MaterialPageRoute(
                            //   builder: (context) => EditMateriScreen(materiDocId: items[itemIndex].id),
                            // ));
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(height: 24),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UploadMateriScreen(),
            ),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        tooltip: 'Unggah Materi Baru',
      ),
    );
  }
}