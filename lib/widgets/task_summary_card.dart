import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan intl sudah di pubspec.yaml

class TaskSummaryCard extends StatelessWidget {
  final String taskId;
  final Map<String, dynamic> taskData;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TaskSummaryCard({
    super.key,
    required this.taskId,
    required this.taskData,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  Future<int> _getSubmissionCount(String taskId) async {
    try {
      // ## CATATAN: Pastikan koleksi ini 'submissions' atau 'pengumpulan' ##
      // Berdasarkan file task_detail_screen.dart Anda, sepertinya namanya 'pengumpulan'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tugas')
          .doc(taskId)
          .collection('pengumpulan') // Saya ganti ke 'pengumpulan'
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print("Error counting submissions: $e");
      // Jika koleksi 'submissions' yang benar, ganti 'pengumpulan' di atas
      try {
         QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tugas')
          .doc(taskId)
          .collection('submissions')
          .get();
         return snapshot.docs.length;
      } catch (e2) {
         print("Error counting submissions (fallback): $e2");
         return 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final String judul = taskData['judul'] ?? 'Tanpa Judul';
    
    // ## PERBAIKAN: 'untukKelas' adalah String, bukan List ##
    final String untukKelas =
        taskData['untukKelas'] as String? ?? 'Tidak Diketahui';
    // ## AKHIR PERBAIKAN ##

    final Timestamp tenggatTimestamp =
        taskData['tenggatWaktu'] as Timestamp? ?? Timestamp.now();
    final DateTime dueDate = tenggatTimestamp.toDate();

    final difference = dueDate.difference(now);
    bool isOverdue = dueDate.isBefore(now);

    String deadlineText;
    Color deadlineColor;

    if (isOverdue) {
      deadlineText =
          'Tenggat: ${DateFormat('dd MMM yyyy', 'id_ID').format(dueDate)} (Berakhir)';
      deadlineColor = Colors.redAccent;
    } else if (difference.inDays >= 1) {
      deadlineText =
          'Sisa ${difference.inDays + 1} hari (${DateFormat('dd MMM yyyy', 'id_ID').format(dueDate)})';
      deadlineColor = Colors.orangeAccent;
    } else if (difference.inHours >= 1) {
      deadlineText =
          'Sisa ${difference.inHours} jam (${DateFormat('HH:mm', 'id_ID').format(dueDate)})';
      deadlineColor = Colors.orangeAccent;
    } else {
      deadlineText = 'Kurang dari 1 jam lagi';
      deadlineColor = Colors.redAccent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
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
                judul,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // ## PERBAIKAN: Tampilkan String 'untukKelas' secara langsung ##
              Text(
                'Untuk: $untukKelas',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
              ),
              // ## AKHIR PERBAIKAN ##
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: deadlineColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deadlineText,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: deadlineColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<int>(
                    future: _getSubmissionCount(taskId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Memuat...',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[400]),
                        );
                      }
                      final count = snapshot.data ?? 0;
                      return Text(
                        '$count Siswa Mengumpulkan',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[400]),
                      );
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.blueAccent,
                        onPressed: onEdit,
                        tooltip: 'Edit Tugas',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.redAccent,
                        onPressed: onDelete,
                        tooltip: 'Hapus Tugas',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}