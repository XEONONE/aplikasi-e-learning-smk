// Lokasi file: lib/widgets/materi_card.dart

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

  Future<void> _downloadUrl(BuildContext context) async {
    // Tambahkan BuildContext
    final RegExp regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(fileUrl);
    String urlToLaunch = fileUrl; // Default ke URL asli

    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      // Membuat URL download langsung untuk Google Drive
      urlToLaunch = 'https://docs.google.com/uc?export=download&id=$fileId';
    }

    // Coba buka URL download
    final Uri url = Uri.parse(urlToLaunch);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Tampilkan pesan error jika gagal membuka URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa membuka link $urlToLaunch')),
      );
      // throw Exception('Could not launch $url'); // Hindari throw Exception agar aplikasi tidak crash
    }
  }

  // --- AWAL MODIFIKASI ---
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
            // Gunakan LayoutBuilder untuk tombol
            LayoutBuilder(
              builder: (context, constraints) {
                // Tentukan batas lebar untuk mengubah layout tombol
                const double buttonBreakPoint =
                    350.0; // Anda bisa sesuaikan nilai ini

                // Cek apakah lebar yang tersedia kurang dari breakpoint
                bool isNarrow = constraints.maxWidth < buttonBreakPoint;

                // Widget tombol yang akan digunakan
                final editButton = isGuruView && onEdit != null
                    ? TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        onPressed: onEdit,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange.shade800,
                        ),
                      )
                    : const SizedBox.shrink(); // Widget kosong jika tidak ada tombol edit

                final lihatButton = OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Lihat'),
                  onPressed: _launchUrl,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                );

                final unduhButton = ElevatedButton.icon(
                  icon: const Icon(Icons.download_outlined, size: 18),
                  label: const Text('Unduh'),
                  onPressed: () =>
                      _downloadUrl(context), // Kirim context ke _downloadUrl
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                );

                // Jika layar sempit (isNarrow == true), gunakan Column
                if (isNarrow) {
                  return Column(
                    // Rata kanan tombol dalam Column
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Hanya tampilkan tombol edit jika ada
                      if (isGuruView && onEdit != null) ...[
                        editButton,
                        const SizedBox(height: 8), // Jarak antar tombol
                      ],
                      lihatButton,
                      const SizedBox(height: 8), // Jarak antar tombol
                      unduhButton,
                    ],
                  );
                }
                // Jika layar lebar, gunakan Row seperti sebelumnya
                else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Hanya tampilkan tombol edit jika ada
                      if (isGuruView && onEdit != null) ...[
                        editButton,
                        const SizedBox(width: 8),
                      ],
                      lihatButton,
                      const SizedBox(width: 8),
                      unduhButton,
                    ],
                  );
                }
              },
            ),
            // --- AKHIR MODIFIKASI ---
          ],
        ),
      ),
    );
  }
}
