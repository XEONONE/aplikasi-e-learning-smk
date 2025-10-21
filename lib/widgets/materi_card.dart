// lib/widgets/materi_card.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MateriCard extends StatelessWidget {
  final String judul;
  final String deskripsi;
  final String? fileUrl;
  
  // --- PERUBAHAN: Tambahkan parameter ini kembali ---
  final bool isGuruView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  // --- AKHIR PERUBAHAN ---

  const MateriCard({
    super.key,
    required this.judul,
    required this.deskripsi,
    this.fileUrl,
    
    // --- PERUBAHAN: Tambahkan di constructor ---
    this.isGuruView = false, // Default false agar aman untuk siswa
    this.onEdit,
    this.onDelete,
    // --- AKHIR PERUBAHAN ---
  });

  // Fungsi untuk membuka URL (download)
  Future<void> _launchUrl() async {
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      final Uri url = Uri.parse(fileUrl!);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil tema saat ini
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Icon(Icons.description_outlined, color: theme.colorScheme.secondary),
        title: Text(
          judul,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          deskripsi,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        
        // --- PERUBAHAN: Logika untuk trailing icon ---
        trailing: isGuruView
            ? Row( // Tampilan GURU
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: theme.colorScheme.secondary),
                    tooltip: 'Edit Materi',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    tooltip: 'Hapus Materi',
                    onPressed: onDelete,
                  ),
                ],
              )
            : (fileUrl != null && fileUrl!.isNotEmpty
                ? IconButton( // Tampilan SISWA
                    icon: Icon(Icons.download_outlined, color: theme.colorScheme.primary),
                    tooltip: 'Download Materi',
                    onPressed: _launchUrl,
                  )
                : null), // Siswa (jika tidak ada file)
        // --- AKHIR PERUBAHAN ---
      ),
    );
  }
}