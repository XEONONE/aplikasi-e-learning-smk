import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final String author;
  final String role;
  final String text;
  final Timestamp timestamp;

  const CommentCard({
    super.key,
    required this.author,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(timestamp.toDate());

    // Tentukan warna chip berdasarkan peran
    Color chipColor = (role == 'guru') ? Colors.indigo : Colors.blueGrey;
    Color chipTextColor = Colors.white;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Nama Author
                Text(
                  author,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                // Chip Peran (Guru/Siswa)
                Chip(
                  label: Text(role == 'guru' ? 'Guru' : 'Siswa'),
                  backgroundColor: chipColor,
                  labelStyle: TextStyle(
                      color: chipTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                // Waktu
                Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Isi Komentar
            Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}