import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/announcement_card.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }

    // ADAPTASI 1: Menggunakan FutureBuilder untuk mengambil data siswa
    // Ini dilakukan untuk mendapatkan informasi 'kelas' dari siswa yang sedang login.
    return FutureBuilder<UserModel?>(
      future: AuthService().getUserData(currentUser.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final userKelas = userSnapshot.data!.kelas;
        if (userKelas == null) {
          return const Center(child: Text('Anda tidak terdaftar di kelas manapun.'));
        }

        // ADAPTASI 2: StreamBuilder sekarang berada di dalam FutureBuilder
        // Setelah informasi 'kelas' didapatkan, kita baru mengambil data pengumuman.
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pengumuman')
              // INTI PERUBAHAN: Query diadaptasi untuk memfilter data.
              // Ia hanya akan mengambil dokumen di mana field 'untukKelas' berisi
              // nama kelas siswa tersebut (misal: "X TKJ 1") ATAU berisi string "Semua Kelas".
              .where('untukKelas', whereIn: [userKelas, 'Semua Kelas'])
              .orderBy('dibuatPada', descending: true)
              .snapshots(),
          builder: (context, announcementSnapshot) {
            if (announcementSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!announcementSnapshot.hasData || announcementSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Belum ada pengumuman untuk Anda.'));
            }
            if (announcementSnapshot.hasError) {
              return const Center(child: Text('Terjadi error saat memuat pengumuman.'));
            }

            // Bagian ini sama seperti kode lama, hanya menampilkan data yang sudah difilter.
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: announcementSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = announcementSnapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                
                return AnnouncementCard(
                  judul: data['judul'],
                  isi: data['isi'],
                  dibuatPada: data['dibuatPada'],
                  dibuatOlehUid: data['dibuatOlehUid'],
                );
              },
            );
          },
        );
      },
    );
  }
}