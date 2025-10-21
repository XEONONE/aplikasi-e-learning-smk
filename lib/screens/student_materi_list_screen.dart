// lib/screens/student_materi_list_screen.dart

import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/services/auth_service.dart';
import 'package:aplikasi_e_learning_smk/widgets/materi_detail_sheet.dart'; // <-- PASTIKAN INI DI-IMPORT
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentMateriListScreen extends StatefulWidget {
  const StudentMateriListScreen({super.key});

  @override
  State<StudentMateriListScreen> createState() => _StudentMateriListScreenState();
}

class _StudentMateriListScreenState extends State<StudentMateriListScreen> {
  late Future<UserModel?> _userFuture;
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final Map<String, bool> _expansionState = {};

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _userFuture = _authService.getUserData(currentUser!.uid);
    }
  }

  // --- WIDGET _buildModuleItem ---
  Widget _buildModuleItem(
      BuildContext context, Map<String, dynamic> materiData) {
    
    final String guruName = "Bpk. Ahmad Fauzi"; // Placeholder
    final bool isCompleted = materiData['judul'].contains("Logika"); // Placeholder

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            
            // --- INI ADALAH KUNCI UTAMANYA ---
            showModalBottomSheet(
              context: context, 
              
              // PERINTAH AGAR TIDAK MENUTUPI NAVIGATION BAR
              useRootNavigator: false, 
              
              isScrollControlled: true, 
              backgroundColor: Colors.transparent,
              builder: (sheetContext) {
                // GestureDetector ini untuk menutup sheet jika klik di area luar
                return GestureDetector(
                  onTap: () => Navigator.of(sheetContext).pop(), 
                  child: Container(
                    color: const Color.fromRGBO(0, 0, 0, 0.001), 
                    alignment: Alignment.bottomCenter,
                    // GestureDetector ini agar klik di DALAM sheet
                    // tidak ikut menutup sheet-nya
                    child: GestureDetector(
                      onTap: () {}, // Biarkan kosong
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor, 
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                        ),
                        // Kita panggil sheet detail
                        child: MateriDetailSheet(materiData: materiData),
                      ),
                    ),
                  ),
                );
              },
            );
            // --- AKHIR KUNCI ---

          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materiData['judul'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guruName,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? Colors.greenAccent : Colors.grey,
                    ),
                    color: isCompleted ? Colors.greenAccent : Colors.transparent,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.black87)
                      : const SizedBox(width: 16, height: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // --- Akhir _buildModuleItem ---

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Silakan login ulang.'));
    }
    final theme = Theme.of(context);

    // --- PASTIKAN TIDAK ADA 'return Scaffold(...)' DI SINI ---
    // Langsung return FutureBuilder
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return const Center(child: Text('Gagal memuat data siswa.'));
        }

        final userKelas = userSnapshot.data!.kelas;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('materi')
              .where('untukKelas', isEqualTo: userKelas)
              .orderBy('mataPelajaran')
              .orderBy('diunggahPada', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            // 'context' ini adalah context dari Scaffold utama (di dashboard)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Terjadi error saat memuat data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('Belum ada materi untuk kelas $userKelas.'),
              );
            }

            var groupedMateri = <String, List<QueryDocumentSnapshot>>{};
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              String mapel = data['mataPelajaran'] ?? 'Lainnya';
              if (groupedMateri[mapel] == null) {
                groupedMateri[mapel] = [];
              }
              groupedMateri[mapel]!.add(doc);
            }

            List<String> mapelKeys = groupedMateri.keys.toList();

            for (var key in mapelKeys) {
              _expansionState.putIfAbsent(key, () => true);
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: mapelKeys.map((mapel) {
                List<QueryDocumentSnapshot> materis = groupedMateri[mapel]!;

                return Card(
                  color: theme.cardColor,
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  child: ExpansionTile(
                    key: PageStorageKey(mapel),
                    title: Text(
                      mapel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    
                    initiallyExpanded: _expansionState[mapel] ?? true,
                    onExpansionChanged: (isExpanded) {
                      setState(() {
                        _expansionState[mapel] = isExpanded;
                      });
                    },
                    
                    trailing: Icon(
                      _expansionState[mapel] ?? true
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.grey[400],
                    ),
                    backgroundColor: theme.cardColor,
                    collapsedBackgroundColor: theme.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    childrenPadding: const EdgeInsets.only(bottom: 8.0),
                    children: materis.map((materiDoc) {
                      var materiData = materiDoc.data() as Map<String, dynamic>;
                      
                      return _buildModuleItem(context, materiData);
                    }).toList(),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}