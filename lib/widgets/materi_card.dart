import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MateriCard extends StatelessWidget {
  final String judul;
  final String deskripsi;
  final String fileUrl;

  const MateriCard({
    super.key,
    required this.judul,
    required this.deskripsi,
    required this.fileUrl,
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url)) {
      // Di dunia nyata, Anda akan menampilkan notifikasi error di sini
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(deskripsi),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download_for_offline),
                label: const Text('Lihat/Unduh'),
                onPressed: _launchUrl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}