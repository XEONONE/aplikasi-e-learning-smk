import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MateriCard extends StatelessWidget {
  final String judul;
  final String deskripsi;
  final String fileUrl;
  final bool isGuruView; // BARU: Untuk menandai tampilan guru
  final VoidCallback? onEdit; // BARU: Fungsi untuk tombol edit

  const MateriCard({
    super.key,
    required this.judul,
    required this.deskripsi,
    required this.fileUrl,
    this.isGuruView = false, // Defaultnya false
    this.onEdit, // Opsional
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _downloadUrl() async {
    final RegExp regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(fileUrl);

    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      final downloadUrl =
          'https://docs.google.com/uc?export=download&id=$fileId';

      final Uri url = Uri.parse(downloadUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } else {
      await _launchUrl();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ## PERUBAHAN DI SINI ##
                // Tombol Edit hanya muncul jika isGuruView adalah true
                if (isGuruView) ...[
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Lihat'),
                  onPressed: _launchUrl,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Unduh'),
                  onPressed: _downloadUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
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
