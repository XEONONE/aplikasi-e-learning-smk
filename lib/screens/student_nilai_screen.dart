import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentNilaiScreen extends StatefulWidget {
  final String siswaId;
  const StudentNilaiScreen({super.key, required this.siswaId});

  @override
  State<StudentNilaiScreen> createState() => _StudentNilaiScreenState();
}

class _StudentNilaiScreenState extends State<StudentNilaiScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Kita perlu judul tugas, yang ada di koleksi 'tugas'.
  // Kita akan ambil semua judul tugas terlebih dahulu.
  late Future<Map<String, String>> _taskTitlesFuture;

  @override
  void initState() {
    super.initState();
    _taskTitlesFuture = _fetchTaskTitles();
  }

  // Fungsi untuk mengambil semua judul tugas dan menyimpannya di Map
  Future<Map<String, String>> _fetchTaskTitles() async {
    Map<String, String> taskMap = {};
    try {
      QuerySnapshot taskSnapshot = await _firestore.collection('tugas').get();
      for (var doc in taskSnapshot.docs) {
        taskMap[doc.id] = (doc.data() as Map<String, dynamic>)['judul'] ?? 'Tugas Dihapus';
      }
      return taskMap;
    } catch (e) {
      print('Error fetching task titles: $e');
      return taskMap; // Kembalikan map kosong jika error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, String>>(
        future: _taskTitlesFuture,
        builder: (context, taskMapSnapshot) {
          if (taskMapSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (taskMapSnapshot.hasError || !taskMapSnapshot.hasData) {
            return const Center(child: Text('Gagal memuat data tugas.'));
          }

          final taskTitlesMap = taskMapSnapshot.data!;

          // Setelah data judul tugas siap, baru kita stream data nilai
          return StreamBuilder<QuerySnapshot>(
            // Mengambil semua submission milik siswa ini YANG SUDAH DINILAI
            stream: _firestore
                .collection('submissions')
                .where('siswaId', isEqualTo: widget.siswaId)
                .where('nilai', isNotEqualTo: null) // Filter hanya yang ada nilai
                .orderBy('nilai', descending: true) // Urutkan berdasarkan nilai
                .snapshots(),
            builder: (context, submissionSnapshot) {
              if (submissionSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!submissionSnapshot.hasData || submissionSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada nilai yang diberikan.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              if (submissionSnapshot.hasError) {
                return const Center(child: Text('Terjadi error.'));
              }

              var submissions = submissionSnapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: submissions.length,
                itemBuilder: (context, index) {
                  var sub = submissions[index].data() as Map<String, dynamic>;
                  String tugasId = sub['tugasId'] ?? '';
                  String judulTugas = taskTitlesMap[tugasId] ?? 'Nama Tugas Tidak Ditemukan';
                  num nilai = sub['nilai'] ?? 0;

                  return Card(
                    elevation: 3.0,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      // Tampilan Nilai
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: nilai >= 75 ? Colors.green : (nilai >= 50 ? Colors.orange : Colors.red),
                        child: Text(
                          nilai.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      // Judul Tugas
                      title: Text(
                        judulTugas,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Feedback (jika ada)
                      subtitle: Text(
                        'Feedback: ${sub['feedback'] ?? 'Tidak ada feedback.'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                      onTap: () {
                        // Arahkan siswa kembali ke detail tugas
                        // agar mereka bisa melihat feedback lengkapnya
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                              taskId: tugasId,
                              siswaId: widget.siswaId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}