import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import warna
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart'; 

class StudentHomeScreen extends StatefulWidget {
  final UserModel userModel;
  const StudentHomeScreen({super.key, required this.userModel});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIMULASI: Anda perlu logic nyata untuk menghitung progress
  // Ini hanya data statis untuk tampilan
  final int _completedMateri = 12;
  final int _totalMateri = 20;
  final int _completedTugas = 5;
  final int _totalTugas = 8;
  
  // SIMULASI: Data progress mapel
  final Map<String, double> _mapelProgress = {
    "Informatika": 0.6, // 60%
    "Matematika": 0.75, // 75%
  };
  final Map<String, String> _mapelProgressText = {
    "Informatika": "6 dari 10 modul",
    "Matematika": "8 dari 12 modul",
  };
   final Map<String, IconData> _mapelIcons = {
    "Informatika": Icons.laptop_chromebook,
    "Matematika": Icons.calculate,
  };


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
            
            // 3. Mata Pelajaran
            _buildMataPelajaranSection(),
            const SizedBox(height: 24),

            // 4. Tugas Mendatang
            _buildTugasMendatangSection(),
          ],
        ),
      ),
    );
  }

  // Widget untuk Welcome Banner
  Widget _buildWelcomeBanner() {
    String kelasSiswa = widget.userModel.kelas ?? 'Siswa';
    
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
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.auto_stories, // Mengganti fas fa-shapes
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kelasSiswa,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Semangatmu hari ini adalah kunci kesuksesan di masa depan!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: "Materi",
          count: '$_completedMateri/$_totalMateri',
          icon: Icons.book_outlined,
          iconColor: Colors.green,
        ),
        _buildStatCard(
          title: "Tugas",
          count: '$_completedTugas/$_totalTugas',
          icon: Icons.assignment_turned_in_outlined, // Mengganti fas fa-pencil-alt
          iconColor: Colors.orange,
        ),
      ],
    );
  }
  
  // Template kartu statistik (re-use dari guru)
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
        boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)) ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration( color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk bagian Mata Pelajaran
  Widget _buildMataPelajaranSection() {
    // TODO: Ganti _mapelProgress.keys dengan data mapel dari Firestore
    final mapelList = _mapelProgress.keys.toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             const Text("Mata Pelajaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
             TextButton(
               onPressed: () { /* TODO: Navigasi ke halaman Materi */ },
               child: const Text('Lihat Semua', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
             )
           ],
         ),
        const SizedBox(height: 8),
        ListView.separated(
          itemCount: mapelList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final mapel = mapelList[index];
            final progress = _mapelProgress[mapel] ?? 0.0;
            final progressText = _mapelProgressText[mapel] ?? '0 dari 0 modul';
            final icon = _mapelIcons[mapel] ?? Icons.book;
            
            return _buildMapelCard(
              mapel: mapel,
              progress: progress,
              progressText: progressText,
              icon: icon,
              color: index.isEven ? kPrimaryColor : Colors.green.shade600
            );
          },
        ),
      ],
    );
  }

  // Widget untuk kartu mapel
  Widget _buildMapelCard({
    required String mapel,
    required double progress,
    required String progressText,
    required IconData icon,
    required Color color
  }) {
    return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)) ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mapel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(progressText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget untuk bagian Tugas Mendatang
  Widget _buildTugasMendatangSection() {
     Query query = _firestore
        .collection('tugas')
        .where('untukKelas', whereIn: ['Semua Kelas', widget.userModel.kelas ?? ''])
        .where('tenggatWaktu', isGreaterThan: Timestamp.now()) // Hanya tugas aktif
        .orderBy('tenggatWaktu', descending: false) // Tenggat terdekat dulu
        .limit(3); // Ambil 3 teratas

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          const Text("Tugas Mendatang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Tidak ada tugas mendatang."));
              }
              
              final tasks = snapshot.data!.docs;
              
              return Container(
                 decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)) ],
                ),
                child: ListView.separated(
                  itemCount: tasks.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 16, height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    var data = tasks[index].data() as Map<String, dynamic>;
                    Timestamp t = data['tenggatWaktu'];
                    final deadline = t.toDate();
                    return _buildTaskTile(
                      mapel: data['mapel'] ?? 'Tugas',
                      judul: data['judul'] ?? 'Tanpa Judul',
                      deadline: deadline,
                    );
                  },
                ),
              );
            },
          ),
       ],
    );
  }

  // Widget untuk list tile tugas mendatang
  Widget _buildTaskTile({required String mapel, required String judul, required DateTime deadline}) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    
    String deadlineText;
    Color deadlineColor;
    
    if (difference < 1) {
      deadlineText = 'Besok!';
      deadlineColor = Colors.red;
    } else if (difference < 4) {
      deadlineText = '$difference hari lagi';
      deadlineColor = Colors.orange;
    } else {
      deadlineText = '$difference hari lagi';
      deadlineColor = Colors.grey;
    }
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: deadlineColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('d').format(deadline), style: TextStyle(color: deadlineColor, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(DateFormat('MMM', 'id_ID').format(deadline), style: TextStyle(color: deadlineColor, fontSize: 10)),
          ],
        ),
      ),
      title: Text(judul, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text('$mapel - $deadlineText', style: TextStyle(fontSize: 13, color: deadlineColor)),
      onTap: () {
        // TODO: Navigasi ke detail tugas
      },
    );
  }

}