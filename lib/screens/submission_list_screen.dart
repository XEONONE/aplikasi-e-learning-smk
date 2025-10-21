import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/widgets/comment_section.dart'; // Widget baru
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk input angka
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Import warna dari dashboard
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class SubmissionListScreen extends StatefulWidget {
  final UserModel userModel;
  final QueryDocumentSnapshot taskDoc; // Menerima data tugas
  const SubmissionListScreen({
    super.key,
    required this.userModel,
    required this.taskDoc,
  });

  @override
  State<SubmissionListScreen> createState() => _SubmissionListScreenState();
}

class _SubmissionListScreenState extends State<SubmissionListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Map<String, dynamic> _taskData;
  late DocumentReference _taskRef;

  @override
  void initState() {
    super.initState();
    _taskData = widget.taskDoc.data() as Map<String, dynamic>;
    _taskRef = _firestore.collection('tugas').doc(widget.taskDoc.id);
  }
  
  // Fungsi untuk membuka link jawaban
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
  
  // Fungsi untuk menampilkan modal "Beri Nilai"
  Future<void> _showGradeModal(DocumentSnapshot submissionDoc) async {
    final data = submissionDoc.data() as Map<String, dynamic>;
    final formKey = GlobalKey<FormState>();
    final nilaiController = TextEditingController(text: data['nilai']?.toString() ?? '');
    final feedbackController = TextEditingController(text: data['feedback'] ?? '');
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        // Gunakan StatefulBuilder agar bisa setState di dalam dialog
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Beri Nilai & Feedback', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data['siswaNama'] ?? 'Siswa', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nilaiController,
                      decoration: _inputDecoration(hint: 'Nilai (0-100)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nilai tidak boleh kosong';
                        }
                        int? nilai = int.tryParse(value);
                        if (nilai == null || nilai < 0 || nilai > 100) {
                          return 'Masukkan nilai antara 0-100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: feedbackController,
                      decoration: _inputDecoration(hint: 'Feedback (Opsional)'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                isSubmitting
                  ? const CircularProgressIndicator(color: kPrimaryColor)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setModalState(() { isSubmitting = true; });
                          
                          try {
                            // Update nilai & feedback di Firestore
                            await _firestore.collection('submissions').doc(submissionDoc.id).update({
                              'nilai': int.parse(nilaiController.text),
                              'feedback': feedbackController.text.trim(),
                            });
                            
                            Navigator.of(context).pop(); // Tutup dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nilai berhasil disimpan!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                             setModalState(() { isSubmitting = false; });
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menyimpan nilai: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Simpan Nilai', style: TextStyle(color: Colors.white)),
                    ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        // AppBar kustom dengan tombol back
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tugas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            Text(
              _taskData['judul'] ?? 'Detail Pengumpulan',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Pengumpulan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            // 1. Daftar Pengumpulan
            _buildSubmissionList(),
            
            const SizedBox(height: 24),

            // 2. Bagian Diskusi Tugas
            CommentSection(
              documentRef: _taskRef, // Referensi ke dokumen TUGAS
              userModel: widget.userModel,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk list pengumpulan
  Widget _buildSubmissionList() {
    return StreamBuilder<QuerySnapshot>(
      // Query ke koleksi 'submissions' berdasarkan 'tugasId'
      stream: _firestore
          .collection('submissions')
          .where('tugasId', isEqualTo: widget.taskDoc.id)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada siswa yang mengumpulkan.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            return _buildSubmissionCard(doc); // Buat kartu
          },
        );
      },
    );
  }

  // Widget untuk kartu pengumpulan
  Widget _buildSubmissionCard(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    String siswaNama = data['siswaNama'] ?? 'Siswa';
    String linkJawaban = data['linkJawaban'] ?? '';
    dynamic nilai = data['nilai']; // Bisa jadi int atau null
    
    String formattedDate = "Waktu tidak diketahui";
    if (data['timestamp'] != null) {
      Timestamp t = data['timestamp'];
      formattedDate = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(t.toDate());
    }
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Siswa
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(siswaNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  // Info Nilai
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       if (nilai != null)
                          Text(nilai.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                       if (nilai == null)
                         const Text('Belum Dinilai', style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
                     ],
                  ),
                ],
              ),
              const Divider(height: 24),
              // Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   if (linkJawaban.isNotEmpty)
                     TextButton.icon(
                       icon: const Icon(Icons.link, size: 18, color: Colors.blue),
                       label: const Text('Lihat Jawaban', style: TextStyle(color: Colors.blue)),
                       onPressed: () => _launchURL(linkJawaban),
                     ),
                   const SizedBox(width: 8),
                   TextButton.icon(
                       icon: const Icon(Icons.edit_note, size: 18, color: kPrimaryColor),
                       label: const Text('Beri Nilai', style: TextStyle(color: kPrimaryColor)),
                       onPressed: () => _showGradeModal(doc),
                     ),
                ],
              ),
           ],
         ),
      ),
    );
  }
  
  // Helper styling input untuk modal
  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
    );
  }
}