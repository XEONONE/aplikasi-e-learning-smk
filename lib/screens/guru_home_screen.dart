import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart'; 

class GuruHomeScreen extends StatefulWidget {
  final UserModel userModel;
  const GuruHomeScreen({super.key, required this.userModel});

  @override
  State<GuruHomeScreen> createState() => _GuruHomeScreenState();
}

class _GuruHomeScreenState extends State<GuruHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mengambil hitungan data
  Future<int> _fetchCount(String collection, String field, dynamic value) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print("Error fetching count for $collection: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Banner
            _buildWelcomeBanner(),
            const SizedBox(height: 24),

            // 2. Statistics Grid
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // 3. Pengumuman Terkini
            const Text(
              "Pengumuman Terkini",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildAnnouncementList(),
          ],
        ),
      ),
    );
  }

  // Widget untuk Welcome Banner
  Widget _buildWelcomeBanner() {
    String mengajar = widget.userModel.mengajarKelas?.join(', ') ?? 'Belum ada kelas';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, Color(0xFF6D28D9)], // Indigo to Purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ikon background
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.school, // Mengganti fas fa-chalkboard-teacher
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // Teks
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang, ${widget.userModel.nama}!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mengajar: $mengajar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk Statistik Grid
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true, // Penting di dalam SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Card Total Materi
        FutureBuilder<int>(
          future: _fetchCount('materi', 'diBuatOlehId', widget.userModel.uid),
          builder: (context, snapshot) {
            int count = snapshot.data ?? 0;
            return _buildStatCard(
              title: "Total Materi",
              count: count.toString(),
              icon: Icons.book_outlined,
              iconColor: Colors.green,
            );
          },
        ),
        // Card Total Tugas
        FutureBuilder<int>(
          future: _fetchCount('tugas', 'diBuatOlehId', widget.userModel.uid),
          builder: (context, snapshot) {
            int count = snapshot.data ?? 0;
            return _buildStatCard(
              title: "Total Tugas",
              count: count.toString(),
              icon: Icons.assignment_outlined, // Mengganti fas fa-pencil-alt
              iconColor: Colors.orange,
            );
          },
        ),
      ],
    );
  }

  // Widget template untuk kartu statistik
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded( // Hindari overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  count,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk daftar pengumuman
  Widget _buildAnnouncementList() {
    // Query untuk mengambil pengumuman
    Query query = _firestore
        .collection('pengumuman')
        .where('untukKelas', whereIn: ['Semua Kelas', ...widget.userModel.mengajarKelas ?? []])
        .orderBy('diBuatPada', descending: true)
        .limit(5); // Ambil 5 terbaru

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada pengumuman."));
        }

        final announcements = snapshot.data!.docs;

        // Gunakan ListView.builder di dalam Container ber-shadow
        return Container(
           decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            itemCount: announcements.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8), // Padding di dalam
            separatorBuilder: (context, index) => Divider(
              indent: 16,
              endIndent: 16,
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              var doc = announcements[index];
              var data = doc.data() as Map<String, dynamic>;

              // Format tanggal
              String formattedDate = "Tanggal tidak diketahui";
              if (data['diBuatPada'] != null) {
                Timestamp t = data['diBuatPada'];
                formattedDate = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(t.toDate());
              }

              // Tampilan list item sederhana (sesuai HTML)
              return ListTile(
                title: Text(
                  data['judul'] ?? 'Tanpa Judul',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  'Untuk: ${data['untukKelas']} - $formattedDate',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                // Anda bisa tambahkan onTap untuk membuka detail pengumuman
              );
            },
          ),
        );
      },
    );
  }
}