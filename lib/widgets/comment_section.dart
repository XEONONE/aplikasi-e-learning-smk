import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/widgets/comment_card.dart'; // Widget baru (akan kita buat)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Import warna
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class CommentSection extends StatefulWidget {
  // Menerima referensi dokumen (bisa tugas atau materi)
  final DocumentReference documentRef; 
  final UserModel userModel;
  
  const CommentSection({
    super.key, 
    required this.documentRef, 
    required this.userModel
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  // Fungsi untuk mengirim komentar
  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    setState(() { _isPosting = true; });

    try {
      // Tambahkan komentar ke sub-koleksi 'comments'
      await widget.documentRef.collection('comments').add({
        'text': _commentController.text.trim(),
        'authorName': widget.userModel.nama,
        'authorUid': widget.userModel.uid,
        'authorRole': widget.userModel.role, // Simpan role (guru/siswa)
        'timestamp': FieldValue.serverTimestamp(),
      });
      _commentController.clear(); // Kosongkan input
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim komentar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isPosting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Diskusi Tugas", // Judul bagian
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        
        // 1. Input Komentar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
               TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar atau pertanyaan...',
                  filled: true,
                  fillColor: Colors.grey[50],
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
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _isPosting
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      label: const Text('Kirim', style: TextStyle(color: Colors.white)),
                      onPressed: _postComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. Daftar Komentar
        StreamBuilder<QuerySnapshot>(
          // Query sub-koleksi 'comments'
          stream: widget.documentRef
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Belum ada komentar.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                // Gunakan CommentCard (akan kita buat selanjutnya)
                return CommentCard(commentDoc: doc); 
              },
            );
          },
        ),
      ],
    );
  }
}