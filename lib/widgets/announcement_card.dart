import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementCard extends StatefulWidget {
  final String judul;
  final String isi;
  final Timestamp dibuatPada;
  final String dibuatOlehUid;
  final String untukKelas; // Tambahkan ini

  const AnnouncementCard({
    super.key,
    required this.judul,
    required this.isi,
    required this.dibuatPada,
    required this.dibuatOlehUid,
    required this.untukKelas, // Tambahkan ini
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  late Future<String> _authorNameFuture;

  @override
  void initState() {
    super.initState();
    _authorNameFuture = _getAuthorName(widget.dibuatOlehUid);
  }

  Future<String> _getAuthorName(String uid) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // Cari berdasarkan Doc ID (jika ID doc = UID)
          .get();
      
      if (userDoc.exists) {
        return userDoc.data()?['nama'] ?? 'Admin';
      } else {
         // Jika ID doc bukan UID, coba query
         var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
         if (userQuery.docs.isNotEmpty) {
           return userQuery.docs.first.data()['nama'] ?? 'Admin';
         }
      }
      return 'Admin'; // Default jika tidak ditemukan
    } catch (e) {
      print('Error getting author name: $e');
      return 'Admin';
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM yyyy, HH:mm', 'id_ID')
        .format(widget.dibuatPada.toDate());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.judul,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _authorNameFuture,
              builder: (context, snapshot) {
                String authorName =
                    snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData
                        ? snapshot.data!
                        : 'Memuat...';
                return Text(
                  // Tampilkan nama pembuat dan tanggal
                  'Oleh: $authorName • $formattedDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                );
              },
            ),
             const SizedBox(height: 4),
            // Tampilkan target kelas
            Text(
              'Untuk: ${widget.untukKelas}',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
            const Divider(height: 24), // Beri pembatas
            Text(
              widget.isi,
              style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}