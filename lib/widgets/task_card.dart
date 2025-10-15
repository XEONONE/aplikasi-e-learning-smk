// lib/widgets/task_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final String taskId;
  final String judul;
  final Timestamp tenggatWaktu;
  final VoidCallback onTap;
  final VoidCallback? onEdit; // ## BARU: Tambahkan callback untuk edit ##

  const TaskCard({
    super.key,
    required this.taskId,
    required this.judul,
    required this.tenggatWaktu,
    required this.onTap,
    this.onEdit, // ## BARU ##
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
          padding: const EdgeInsets.all(16.0),
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
              Row( // ## BARU: Bungkus dengan Row ##
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
                  // ## BARU: Tambahkan tombol edit jika onEdit tidak null ##
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit_note, color: Colors.orange.shade700),
                      onPressed: onEdit,
                      tooltip: 'Edit Tugas',
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