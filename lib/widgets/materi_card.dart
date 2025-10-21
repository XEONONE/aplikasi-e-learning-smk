import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MateriCard extends StatelessWidget {
  final String judul;
  final String deskripsi;
  final String mapel;
  final String author;
  final String fileUrl;

  const MateriCard({
    super.key,
    required this.judul,
    required this.deskripsi,
    required this.mapel,
    required this.author,
    required this.fileUrl,
  });

  // Fungsi untuk membuka URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Tidak bisa buka URL
      print('Tidak bisa membuka $url');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Baris Judul dan Mapel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    mapel,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            // Author
            Text(
              'Oleh: $author',
              style: const TextStyle(
                fontSize: 12.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12.0),
            // Deskripsi
            Text(
              deskripsi.isEmpty ? 'Tidak ada deskripsi.' : deskripsi,
              style: const TextStyle(
                fontSize: 15.0,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16.0),
            // Tombol Unduh
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (fileUrl.isNotEmpty) {
                    _launchUrl(fileUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File tidak tersedia.')),
                    );
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Unduh Materi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}