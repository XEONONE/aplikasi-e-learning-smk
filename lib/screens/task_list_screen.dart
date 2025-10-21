import 'package.aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/screens/create_task_screen.dart'; // Halaman buat tugas
import 'package:aplikasi_e_learning_smk/screens/edit_task_screen.dart'; // Halaman edit tugas (akan kita rombak)
import 'package:aplikasi_e_learning_smk/screens/submission_list_screen.dart'; // Halaman lihat pengumpulan (akan kita rombak)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class TaskListScreen extends StatefulWidget {
  final UserModel userModel;
  const TaskListScreen({super.key, required this.userModel});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

// Gunakan 'with TickerProviderStateMixin' untuk TabController
class _TaskListScreenState extends State<TaskListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fungsi untuk hapus tugas
  Future<void> _deleteTask(String docId, String judul) async {
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
        content: Text('Apakah Anda yakin ingin menghapus tugas "$judul"? Ini juga akan menghapus semua data pengumpulan terkait.'), // Tambahkan peringatan
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
        // Hapus dokumen tugas
        await _firestore.collection('tugas').doc(docId).delete();
        // TODO: Idealnya, hapus juga semua sub-koleksi (komentar) dan 
        // dokumen di koleksi 'submissions' yang terkait dengan 'tugasId' ini.
        // Ini memerlukan logic yang lebih kompleks (misalnya Cloud Function).
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus tugas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi navigasi ke edit
  void _editTask(QueryDocumentSnapshot taskDoc) {
     Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen( // Ke halaman edit tugas
          taskDoc: taskDoc,
          userModel: widget.userModel,
        ),
      ),
    );
  }
  
  // Fungsi navigasi ke daftar pengumpulan
  void _viewSubmissions(QueryDocumentSnapshot taskDoc) {
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmissionListScreen( // Ke halaman daftar pengumpulan
          taskDoc: taskDoc,
          userModel: widget.userModel,
        ),
      ),
    );
  }

  // Helper untuk format tenggat waktu
  String _formatDeadline(Timestamp deadline) {
    final now = DateTime.now();
    final deadlineDate = deadline.toDate();
    final difference = deadlineDate.difference(now);

    if (difference.isNegative) {
      if (difference.inDays < -1) return 'Berakhir ${difference.inDays.abs()} hari lalu';
      return 'Berakhir kemarin';
    } else {
      if (difference.inDays == 0) return 'Besok!';
      if (difference.inDays == 1) return '2 hari lagi';
      return '${difference.inDays + 1} hari lagi';
    }
  }

  // Helper untuk warna tenggat waktu
  Color _getDeadlineColor(Timestamp deadline) {
     final now = DateTime.now();
     final deadlineDate = deadline.toDate();
     final difference = deadlineDate.difference(now);
     
     if (difference.isNegative) return Colors.grey;
     if (difference.inDays < 1) return Colors.red;
     if (difference.inDays < 4) return Colors.orange;
     return Colors.green;
  }
  
  // Fungsi untuk mengambil jumlah siswa di kelas target
  // Ini adalah SIMULASI. Idealnya, Anda punya data jumlah siswa per kelas.
  Future<int> _getTotalStudents(String kelas) async {
     // SIMULASI: Anggap semua kelas punya 32 siswa
     // Realitanya, Anda mungkin perlu query ke koleksi 'users'
     // atau memiliki dokumen 'kelas' yang menyimpan jumlah siswa.
     if (kelas == "Semua Kelas") {
       // Jika semua kelas, hitung total siswa yang diajar guru
       int total = 0;
       for (var k in widget.userModel.mengajarKelas ?? []) {
          // Ganti 32 dengan logic Anda
          total += 32; 
       }
       return total.clamp(32, 1000); // Batasi
     }
     return 32; // Default per kelas
  }
  
  // Fungsi untuk mengambil jumlah yang sudah mengumpulkan
  Future<int> _getSubmissionCount(String taskId) async {
    try {
      // Query ke koleksi 'submissions' berdasarkan 'tugasId'
      final snapshot = await _firestore
          .collection('submissions')
          .where('tugasId', isEqualTo: taskId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print("Error fetching submission count: $e");
      return 0;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      // FAB untuk tambah tugas
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTaskScreen(userModel: widget.userModel),
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. Tab Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.1),
                       blurRadius: 4,
                       offset: const Offset(0, 2),
                     ),
                  ],
                ),
                labelColor: kPrimaryColor,
                unselectedLabelColor: Colors.grey[600],
                tabs: const [
                  Tab(text: 'Tugas Aktif'),
                  Tab(text: 'Riwayat'),
                ],
              ),
            ),
          ),
          
          // 2. Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Tugas Aktif
                _buildTaskList(
                  _firestore
                      .collection('tugas')
                      .where('diBuatOlehId', isEqualTo: widget.userModel.uid)
                      .where('tenggatWaktu', isGreaterThan: Timestamp.now())
                      .orderBy('tenggatWaktu', descending: false), // Yg paling dekat
                  isActive: true,
                ),
                // Tab 2: Riwayat Tugas
                _buildTaskList(
                  _firestore
                      .collection('tugas')
                      .where('diBuatOlehId', isEqualTo: widget.userModel.uid)
                      .where('tenggatWaktu', isLessThanOrEqualTo: Timestamp.now())
                      .orderBy('tenggatWaktu', descending: true), // Yg paling baru berakhir
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan daftar tugas
  Widget _buildTaskList(Query query, {required bool isActive}) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Tidak ada ${isActive ? 'tugas aktif' : 'riwayat tugas'}.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            return _buildTaskCard(doc, isActive: isActive); // Buat kartu
          },
        );
      },
    );
  }
  
  // Widget untuk kartu tugas
  Widget _buildTaskCard(QueryDocumentSnapshot doc, {required bool isActive}) {
     var data = doc.data() as Map<String, dynamic>;
     String judul = data['judul'] ?? 'Tanpa Judul';
     String untukKelas = data['untukKelas'] ?? 'Semua Kelas';
     Timestamp tenggat = data['tenggatWaktu'] ?? Timestamp.now();
     
     Color deadlineColor = isActive ? _getDeadlineColor(tenggat) : Colors.grey;
     String deadlineText = isActive ? _formatDeadline(tenggat) : 'Telah Berakhir';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Judul & Tenggat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         judul,
                         style: TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                           color: isActive ? Colors.black87 : Colors.grey[600],
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         'Untuk: $untukKelas',
                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                       ),
                     ],
                   ),
                 ),
                 // Info Tenggat
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: deadlineColor.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(6),
                   ),
                   child: Text(
                     deadlineText,
                     style: TextStyle(
                       color: deadlineColor,
                       fontWeight: FontWeight.bold,
                       fontSize: 12,
                     ),
                   ),
                 ),
              ],
            ),
            const Divider(height: 24),
            // Baris Info Pengumpulan & Tombol
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info Mengumpulkan
                FutureBuilder<int>(
                  future: _getSubmissionCount(doc.id),
                  builder: (context, countSnapshot) {
                    int submissionCount = countSnapshot.data ?? 0;
                    return FutureBuilder<int>(
                       future: _getTotalStudents(untukKelas),
                       builder: (context, totalSnapshot) {
                         int totalStudents = totalSnapshot.data ?? 32; // Default
                         return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('$submissionCount / $totalStudents', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor)),
                             const Text('Mengumpulkan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                           ],
                         );
                       },
                    );
                  },
                ),
                
                // Tombol Aksi
                Row(
                  children: [
                    // Tombol Lihat Pengumpulan
                    IconButton(
                      icon: const Icon(Icons.inbox_outlined, color: Colors.blue),
                      tooltip: 'Lihat Pengumpulan',
                      onPressed: () => _viewSubmissions(doc),
                    ),
                    // Tombol Edit
                    IconButton(
                       icon: Icon(Icons.edit_outlined, color: isActive ? Colors.orange : Colors.grey),
                       tooltip: 'Edit Tugas',
                       onPressed: isActive ? () => _editTask(doc) : null, // Nonaktifkan jika sudah riwayat
                    ),
                    // Tombol Hapus
                    IconButton(
                       icon: const Icon(Icons.delete_outline, color: Colors.red),
                       tooltip: 'Hapus Tugas',
                       onPressed: () => _deleteTask(doc.id, judul),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}