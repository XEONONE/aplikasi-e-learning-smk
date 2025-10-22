// Lokasi: lib/widgets/materi_card.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MateriCard extends StatelessWidget {
  final String judul;
  final String deskripsi;
  final String? fileUrl;
  final bool isGuruView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete; // Tambahkan parameter onDelete

  const MateriCard({
    super.key,
    required this.judul,
    required this.deskripsi,
    this.fileUrl,
    this.isGuruView = false,
    this.onEdit,
    this.onDelete, // Tambahkan di constructor
  });

  Future<void> _launchUrl() async {
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      final Uri url = Uri.parse(fileUrl!);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
        // Pertimbangkan menampilkan SnackBar atau pesan error ke pengguna
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(
          Icons.description_outlined,
          color: theme.colorScheme.secondary,
        ),
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
          maxLines: 2, // Batasi deskripsi agar tidak terlalu panjang
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isGuruView
            ? Row(
                // Tampilan GURU
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null) // Tampilkan hanya jika ada fungsi onEdit
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: theme.colorScheme.secondary,
                      ),
                      tooltip: 'Edit Materi',
                      onPressed: onEdit, // Panggil fungsi onEdit saat ditekan
                    ),
                  if (onDelete !=
                      null) // Tampilkan hanya jika ada fungsi onDelete
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Hapus Materi',
                      // ## PERUBAHAN UTAMA: Panggil fungsi onDelete saat ditekan ##
                      onPressed: onDelete,
                      // ## AKHIR PERUBAHAN UTAMA ##
                    ),
                ],
              )
            : (fileUrl != null && fileUrl!.isNotEmpty
                  ? IconButton(
                      // Tampilan SISWA
                      icon: Icon(
                        Icons.download_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: 'Download Materi',
                      onPressed: _launchUrl,
                    )
                  : null), // Siswa (jika tidak ada file)
      ),
    );
  }
}
