// lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplikasi_e_learning_smk/models/user_model.dart';
import 'package:aplikasi_e_learning_smk/models/materi_model.dart';
import 'package:aplikasi_e_learning_smk/models/tugas_model.dart';
import 'package:aplikasi_e_learning_smk/models/pengumuman_model.dart';
import 'package:aplikasi_e_learning_smk/models/komentar_model.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String materiCollection = 'materi';
  static const String tugasCollection = 'tugas';
  static const String pengumumanCollection = 'pengumuman';
  static const String komentarCollection = 'komentar';
  static const String kelasCollection = 'kelas';
  static const String pengumpulanCollection = 'pengumpulan';

  // === USER OPERATIONS ===
  static Future<void> createUser(UserModel user) async {
    try {
      await _db.collection(usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _db.collection(usersCollection).doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _db.collection(usersCollection).get();
      return snapshot.docs.map((doc) => 
        UserModel.fromMap(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // === MATERI OPERATIONS ===
  static Future<String> createMateri(MateriModel materi) async {
    try {
      DocumentReference docRef = await _db.collection(materiCollection).add(materi.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create materi: $e');
    }
  }

  static Future<MateriModel?> getMateri(String materiId) async {
    try {
      DocumentSnapshot doc = await _db.collection(materiCollection).doc(materiId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MateriModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get materi: $e');
    }
  }

  static Future<List<MateriModel>> getAllMateri() async {
    try {
      QuerySnapshot snapshot = await _db.collection(materiCollection)
          .orderBy('tanggalDibuat', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MateriModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get materi list: $e');
    }
  }

  static Future<List<MateriModel>> getMateriByKelas(String kelasId) async {
    try {
      QuerySnapshot snapshot = await _db.collection(materiCollection)
          .where('kelasId', isEqualTo: kelasId)
          .orderBy('tanggalDibuat', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MateriModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get materi by kelas: $e');
    }
  }

  static Future<void> updateMateri(String materiId, Map<String, dynamic> updates) async {
    try {
      await _db.collection(materiCollection).doc(materiId).update(updates);
    } catch (e) {
      throw Exception('Failed to update materi: $e');
    }
  }

  static Future<void> deleteMateri(String materiId) async {
    try {
      await _db.collection(materiCollection).doc(materiId).delete();
    } catch (e) {
      throw Exception('Failed to delete materi: $e');
    }
  }

  // === TUGAS OPERATIONS ===
  static Future<String> createTugas(TugasModel tugas) async {
    try {
      DocumentReference docRef = await _db.collection(tugasCollection).add(tugas.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create tugas: $e');
    }
  }

  static Future<TugasModel?> getTugas(String tugasId) async {
    try {
      DocumentSnapshot doc = await _db.collection(tugasCollection).doc(tugasId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TugasModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get tugas: $e');
    }
  }

  static Future<List<TugasModel>> getAllTugas() async {
    try {
      QuerySnapshot snapshot = await _db.collection(tugasCollection)
          .orderBy('tanggalDibuat', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TugasModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tugas list: $e');
    }
  }

  static Future<List<TugasModel>> getTugasByKelas(String kelasId) async {
    try {
      QuerySnapshot snapshot = await _db.collection(tugasCollection)
          .where('kelasId', isEqualTo: kelasId)
          .orderBy('tanggalDibuat', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TugasModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tugas by kelas: $e');
    }
  }

  static Future<void> updateTugas(String tugasId, Map<String, dynamic> updates) async {
    try {
      await _db.collection(tugasCollection).doc(tugasId).update(updates);
    } catch (e) {
      throw Exception('Failed to update tugas: $e');
    }
  }

  static Future<void> deleteTugas(String tugasId) async {
    try {
      await _db.collection(tugasCollection).doc(tugasId).delete();
    } catch (e) {
      throw Exception('Failed to delete tugas: $e');
    }
  }

  // === PENGUMUMAN OPERATIONS ===
  static Future<String> createPengumuman(PengumumanModel pengumuman) async {
    try {
      DocumentReference docRef = await _db.collection(pengumumanCollection).add(pengumuman.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create pengumuman: $e');
    }
  }

  static Future<PengumumanModel?> getPengumuman(String pengumumanId) async {
    try {
      DocumentSnapshot doc = await _db.collection(pengumumanCollection).doc(pengumumanId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PengumumanModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get pengumuman: $e');
    }
  }

  static Future<List<PengumumanModel>> getAllPengumuman() async {
    try {
      QuerySnapshot snapshot = await _db.collection(pengumumanCollection)
          .orderBy('tanggalDibuat', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return PengumumanModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pengumuman list: $e');
    }
  }

  static Future<void> updatePengumuman(String pengumumanId, Map<String, dynamic> updates) async {
    try {
      await _db.collection(pengumumanCollection).doc(pengumumanId).update(updates);
    } catch (e) {
      throw Exception('Failed to update pengumuman: $e');
    }
  }

  static Future<void> deletePengumuman(String pengumumanId) async {
    try {
      await _db.collection(pengumumanCollection).doc(pengumumanId).delete();
    } catch (e) {
      throw Exception('Failed to delete pengumuman: $e');
    }
  }

  // === KOMENTAR OPERATIONS ===
  static Future<String> createKomentar(KomentarModel komentar) async {
    try {
      DocumentReference docRef = await _db.collection(komentarCollection).add(komentar.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create komentar: $e');
    }
  }

  static Future<List<KomentarModel>> getKomentarByParent(String parentId, String type) async {
    try {
      QuerySnapshot snapshot = await _db.collection(komentarCollection)
          .where('parentId', isEqualTo: parentId)
          .where('type', isEqualTo: type)
          .orderBy('tanggalDibuat', descending: false)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return KomentarModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get komentar: $e');
    }
  }

  static Future<void> deleteKomentar(String komentarId) async {
    try {
      await _db.collection(komentarCollection).doc(komentarId).delete();
    } catch (e) {
      throw Exception('Failed to delete komentar: $e');
    }
  }

  // === REAL-TIME STREAMS ===
  static Stream<List<MateriModel>> getMateriStream() {
    return _db.collection(materiCollection)
        .orderBy('tanggalDibuat', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return MateriModel.fromMap(data);
        }).toList());
  }

  static Stream<List<TugasModel>> getTugasStream() {
    return _db.collection(tugasCollection)
        .orderBy('tanggalDibuat', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return TugasModel.fromMap(data);
        }).toList());
  }

  static Stream<List<PengumumanModel>> getPengumumanStream() {
    return _db.collection(pengumumanCollection)
        .orderBy('tanggalDibuat', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return PengumumanModel.fromMap(data);
        }).toList());
  }

  static Stream<List<KomentarModel>> getKomentarStream(String parentId, String type) {
    return _db.collection(komentarCollection)
        .where('parentId', isEqualTo: parentId)
        .where('type', isEqualTo: type)
        .orderBy('tanggalDibuat', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return KomentarModel.fromMap(data);
        }).toList());
  }

  // === UTILITY METHODS ===
  static Future<bool> isDocumentExists(String collection, String docId) async {
    try {
      DocumentSnapshot doc = await _db.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      WriteBatch batch = _db.batch();
      
      for (var operation in operations) {
        String type = operation['type'];
        String collection = operation['collection'];
        String? docId = operation['docId'];
        Map<String, dynamic> data = operation['data'];

        if (type == 'create') {
          DocumentReference docRef = docId != null 
            ? _db.collection(collection).doc(docId)
            : _db.collection(collection).doc();
          batch.set(docRef, data);
        } else if (type == 'update') {
          batch.update(_db.collection(collection).doc(docId!), data);
        } else if (type == 'delete') {
          batch.delete(_db.collection(collection).doc(docId!));
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to execute batch operations: $e');
    }
  }

  // === SEARCH OPERATIONS ===
  static Future<List<MateriModel>> searchMateri(String query) async {
    try {
      QuerySnapshot snapshot = await _db.collection(materiCollection)
          .where('judul', isGreaterThanOrEqualTo: query)
          .where('judul', isLessThan: query + '\uf8ff')
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MateriModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search materi: $e');
    }
  }

  static Future<List<TugasModel>> searchTugas(String query) async {
    try {
      QuerySnapshot snapshot = await _db.collection(tugasCollection)
          .where('judul', isGreaterThanOrEqualTo: query)
          .where('judul', isLessThan: query + '\uf8ff')
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TugasModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search tugas: $e');
    }
  }
}
