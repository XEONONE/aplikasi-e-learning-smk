import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import warna
import 'package:aplikasi_e_learning_smk/screens/guru_dashboard_screen.dart';

class CommentCard extends StatelessWidget {
  final QueryDocumentSnapshot commentDoc; // Menerima data komentar

  const CommentCard({super.key, required this.commentDoc});

  @override
  Widget build(BuildContext context) {
    final data = commentDoc.data() as Map<String, dynamic>;
    final String authorName = data['authorName'] ?? 'Anonim';
    final String text = data['text'] ?? '';
    final String authorRole = data['authorRole'] ?? 'siswa';
    final Timestamp? timestamp = data['timestamp'];

    // Format tanggal
    String formattedDate = "Waktu tidak diketahui";
    if (timestamp != null) {
      formattedDate = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(timestamp.toDate());
    }

    // Ambil inisial nama untuk avatar
    String initials = authorName.isNotEmpty
        ? authorName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';

    // Tentukan warna latar belakang berdasarkan role (sesuai desain HTML)
    Color backgroundColor = authorRole == 'guru' ? const Color(0xFFE0E7FF) : Colors.white; // Indigo-50 for guru, white for others

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
         boxShadow: [ // Tambahkan shadow tipis jika background putih
            if (backgroundColor == Colors.white)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
         ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: authorRole == 'guru' ? kPrimaryColor.withOpacity(0.2) : Colors.grey[200],
            // TODO: Ganti dengan NetworkImage jika user punya foto profil
            child: Text(
              initials.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: authorRole == 'guru' ? kPrimaryColor : Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Konten Komentar (Nama, Badge Role, Teks, Waktu)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Nama & Badge
                Row(
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                    ),
                    // Tampilkan badge 'Guru' jika role adalah guru
                    if (authorRole == 'guru')
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Guru',
                          style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Teks Komentar
                Text(
                  text,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // Waktu Komentar
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}