import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enum untuk status tugas
enum TaskStatus {
  sudahDinilai,
  sudahDikumpulkan,
  belumSelesai,
  melebihiTenggat
}

class TaskCard extends StatelessWidget {
  final String judul;
  final String mapel;
  final Timestamp deadline;
  final TaskStatus status;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.judul,
    required this.mapel,
    required this.deadline,
    required this.status,
    required this.onTap,
  });

  // Helper untuk mendapatkan tampilan status
  Widget _buildStatusChip() {
    String label;
    Color backgroundColor;
    Color foregroundColor;
    IconData iconData;

    bool isOverdue =
        DateTime.now().isAfter(deadline.toDate()) && // Sudah lewat
            status == TaskStatus.belumSelesai; // Dan belum dikumpulkan

    // Override status jika terlambat
    final currentStatus = isOverdue ? TaskStatus.melebihiTenggat : status;

    switch (currentStatus) {
      case TaskStatus.sudahDinilai:
        label = 'Sudah Dinilai';
        backgroundColor = Colors.green.shade100;
        foregroundColor = Colors.green.shade800;
        iconData = Icons.check_circle;
        break;
      case TaskStatus.sudahDikumpulkan:
        label = 'Terkumpul';
        backgroundColor = Colors.blue.shade100;
        foregroundColor = Colors.blue.shade800;
        iconData = Icons.hourglass_top;
        break;
      case TaskStatus.melebihiTenggat:
        label = 'Terlambat';
        backgroundColor = Colors.red.shade100;
        foregroundColor = Colors.red.shade800;
        iconData = Icons.error;
        break;
      case TaskStatus.belumSelesai:
      default:
        label = 'Belum Selesai';
        backgroundColor = Colors.grey.shade200;
        foregroundColor = Colors.grey.shade800;
        iconData = Icons.schedule;
        break;
    }

    return Chip(
      avatar: Icon(iconData, color: foregroundColor, size: 16),
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
          color: foregroundColor, fontSize: 12, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDeadline =
        DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(deadline.toDate());

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
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
              const SizedBox(height: 12.0),
              // Tenggat Waktu
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tenggat: $formattedDeadline',
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Status
              _buildStatusChip(),
            ],
          ),
        ),
      ),
    );
  }
}