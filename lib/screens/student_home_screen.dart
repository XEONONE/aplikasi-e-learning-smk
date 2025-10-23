// lib/screens/student_home_screen.dart
import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/announcement_card.dart'; // Import AnnouncementCard
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Hapus jika AnnouncementCard Anda tidak butuh ini

class StudentHomeScreen extends StatefulWidget {
  final String kelasId;
  const StudentHomeScreen({super.key, required this.kelasId});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final AuthService _authService = AuthService();
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchStudentData();
  }

  Future<UserModel?> _fetchStudentData() async {
    String? studentId = _authService.getCurrentUser()?.uid;
    if (studentId != null) {
      UserModel? studentData = await _authService.getUserData(studentId);
      return studentData;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            print("Error fetching user data: ${snapshot.error}");
            return const Center(
              child: Text('Gagal memuat data siswa. Coba lagi nanti.'),
            );
          }

          final user = snapshot.data!;
          final userKelas = user.kelas; // Simpan kelas user

          // --- UI LAMA ANDA ---
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card (sesuai kode asli Anda, sedikit dimodifikasi)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.indigo,
                        const Color(0xFF7C3AED).withOpacity(0.8),
                      ], // Sedikit transparansi
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    boxShadow: [
                      // Tambahkan sedikit shadow
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Tampilkan nama dan kelas
                        'Selamat Datang, ${user.nama}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kelas: ${userKelas ?? 'Belum ada kelas'}', // Tampilkan kelas
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Semangatmu hari ini adalah kunci kesuksesan di masa depan!',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Grid (sesuai kode asli Anda)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 4.0,
                  children: [
                    _buildStatCard(
                      'Materi',
                      '12/20',
                      Icons.book_outlined,
                      Colors.green.shade400,
                    ),
                    _buildStatCard(
                      'Tugas',
                      '5/8',
                      Icons.assignment_outlined,
                      Colors.orange.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 1),

                // Mata Pelajaran Section (sesuai kode asli Anda)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mata Pelajaran',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {}, // TODO: Implementasi Lihat Semua Materi
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSubjectCard(
                  'Informatika',
                  '6 dari 10 modul',
                  0.6,
                  Icons.laptop_chromebook_outlined,
                  Colors.blue.shade400,
                ),
                const SizedBox(height: 12),
                _buildSubjectCard(
                  'Matematika',
                  '8 dari 12 modul',
                  0.75,
                  Icons.calculate_outlined,
                  Colors.teal.shade400,
                ),
                const SizedBox(height: 32),

                // Tugas Mendatang Section (sesuai kode asli Anda)
                Text(
                  'Tugas Mendatang',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildUpcomingTask(
                  'Essay Algoritma',
                  'Informatika',
                  'Batas: Besok!',
                  Colors.red.shade400,
                ),
                const SizedBox(height: 12),
                _buildUpcomingTask(
                  'Latihan Soal Integral',
                  'Matematika',
                  'Batas: 4 hari lagi',
                  Colors.amber.shade600,
                ),
                const SizedBox(height: 32), // Beri jarak sebelum pengumuman
                // --- BAGIAN PENGUMUMAN (BARU DITAMBAHKAN) ---
                Text(
                  'Pengumuman Terbaru',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildAnnouncementSection(
                  userKelas,
                ), // Panggil method build pengumuman
                // --- AKHIR BAGIAN PENGUMUMAN ---
              ],
            ),
          );
          // --- AKHIR UI LAMA ---
        },
      ),
    );
  }

  // --- WIDGET HELPER DARI KODE ASLI ANDA (Dimodifikasi sedikit untuk style) ---
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2.0, // Sedikit kurangi shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, // Align ke kiri
          children: [
            Row(
              // Ikon dan Judul
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Icon(icon, size: 28, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              // Nilai
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    String subject,
    String progress,
    double progressValue,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), // Gunakan withOpacity
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress, // Tampilkan progress text
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    borderRadius: BorderRadius.circular(5), // Sedikit rounded
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTask(
    String title,
    String subject,
    String deadline,
    Color color,
  ) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        // Gunakan ListTile agar lebih rapi
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(Icons.calendar_today_outlined, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '$subject • $deadline',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {
          // TODO: Aksi ketika item tugas diklik
        },
      ),
    );
  }
  // --- AKHIR WIDGET HELPER DARI KODE ASLI ---

  // --- METHOD BARU UNTUK BAGIAN PENGUMUMAN ---
  Widget _buildAnnouncementSection(String? userKelas) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pengumuman')
          .where('untukKelas', whereIn: [userKelas ?? '', 'Semua Kelas'])
          .orderBy('dibuatPada', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Belum ada pengumuman untuk kelas ${userKelas ?? 'Anda'}.',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          print("Error loading announcements: ${snapshot.error}");
          return const Center(
            child: Text(
              'Gagal memuat pengumuman.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;

            Timestamp timestamp = data['dibuatPada'] ?? Timestamp.now();
            // DateTime dateTime = timestamp.toDate(); // Hapus jika AnnouncementCard pakai Timestamp

            // String authorName = data['dibuatOlehNama'] ?? data['dibuatOlehUid'] ?? 'Admin'; // Hapus jika AnnouncementCard handle nama

            // Panggil AnnouncementCard sesuai definisi di announcement_card.dart
            // (Menggunakan judul, isi, dibuatPada(Timestamp), dibuatOlehUid, untukKelas)
            return AnnouncementCard(
              judul: data['judul'] ?? 'Tanpa Judul',
              isi: data['isi'] ?? 'Tidak ada isi.',
              dibuatPada: timestamp, // Kirim Timestamp
              dibuatOlehUid: data['dibuatOlehUid'] ?? '',
              untukKelas: data['untukKelas'] ?? 'Tidak diketahui',
            );
          },
        );
      },
    );
  }

  // --- AKHIR METHOD BARU ---
}
