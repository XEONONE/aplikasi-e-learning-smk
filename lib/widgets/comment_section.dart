import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/comment_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final String documentId; // ID dari tugas atau materi
  final String collectionName; // Nama koleksi ('tugas' atau 'materi')
  final User? currentUser;

  const CommentSection({
    super.key,
    required this.documentId,
    required this.collectionName,
    required this.currentUser,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  bool _isPosting = false;

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty || widget.currentUser == null) {
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Ambil data detail pengguna (nama & role)
      UserModel? userData =
          await _authService.getUserData(widget.currentUser!.uid);
      if (userData == null) throw Exception("User data not found");

      // Simpan komentar di sub-koleksi 'comments'
      await _firestore
          .collection(widget.collectionName)
          .doc(widget.documentId)
          .collection('comments')
          .add({
        'text': _commentController.text.trim(),
        'authorName': userData.nama,
        'authorUid': widget.currentUser!.uid,
        'authorRole': userData.role,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Kosongkan controller
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim komentar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daftar Komentar
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection(widget.collectionName)
              .doc(widget.documentId)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Belum ada komentar. Jadilah yang pertama!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            var comments = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                var comment = comments[index].data() as Map<String, dynamic>;
                return CommentCard(
                  author: comment['authorName'] ?? 'Anonim',
                  role: comment['authorRole'] ?? 'siswa',
                  text: comment['text'] ?? '',
                  timestamp: comment['timestamp'] as Timestamp? ??
                      Timestamp.now(), // Fallback
                );
              },
            );
          },
        ),

        const SizedBox(height: 16),

        // Input Komentar Baru
        if (widget.currentUser != null)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Tulis komentar...',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  maxLines: null, // Mengizinkan multi-baris
                ),
              ),
              const SizedBox(width: 8),
              _isPosting
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.send, color: Colors.indigo),
                      onPressed: _postComment,
                      tooltip: 'Kirim Komentar',
                    ),
            ],
          ),
      ],
    );
  }
}