// lib/widgets/task_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final String taskId;
  final String judul;
  final Timestamp tenggatWaktu;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete; // ## BARU: Tambahkan callback untuk hapus ##

  const TaskCard({
    super.key,
    required this.taskId,
    required this.judul,
    required this.tenggatWaktu,
    required this.onTap,
    this.onEdit,
    this.onDelete, // ## BARU ##
  });

  @override
  Widget build(BuildContext context) {
    DateTime tenggat = tenggatWaktu.toDate();
    String formattedTenggat = DateFormat('d MMM yyyy, HH:mm').format(tenggat);
    bool isLate = DateTime.now().isAfter(tenggat);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8), // Sesuaikan padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: isLate ? Colors.red : Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    'Tenggat: $formattedTenggat',
                    style: TextStyle(color: isLate ? Colors.red : Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tugas')
                        .doc(taskId)
                        .collection('pengumpulan')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int submissionCount = 0;
                      if (snapshot.hasData) {
                        submissionCount = snapshot.data!.docs.length;
                      }
                      return Row(
                        children: [
                          const Icon(Icons.people_alt_outlined, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text('$submissionCount siswa telah mengumpulkan'),
                        ],
                      );
                    },
                  ),
                  // ## PERUBAHAN DI SINI: Tambahkan tombol hapus ##
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: Icon(Icons.edit_note, color: Colors.orange.shade700),
                          onPressed: onEdit,
                          tooltip: 'Edit Tugas',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                          onPressed: onDelete,
                          tooltip: 'Hapus Tugas',
                        ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}