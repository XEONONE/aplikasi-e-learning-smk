import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan sudah ditambahkan di pubspec.yaml

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String content;
  final Timestamp timestamp;
  final String author;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    // Format tanggal dan waktu ke format Indonesia
    String formattedDate = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID')
        .format(timestamp.toDate());

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15.0,
                height: 1.4, // Jarak antar baris
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Oleh: $author',
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}