// lib/services/dynamic_link_service.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class DynamicLinkService {
  static const String baseUrl = 'https://aplikasi-e-learning-smk.web.app';
  static const String linksCollection = 'dynamic_links';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // === LINK GENERATION ===
  
  /// Generate a unique link for accessing specific data
  static Future<String> generateDataLink({
    required String type, // 'materi', 'tugas', 'pengumuman'
    required String dataId,
    required String title,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Generate unique short code
      String shortCode = _generateShortCode();
      
      // Create link data
      Map<String, dynamic> linkData = {
        'shortCode': shortCode,
        'type': type,
        'dataId': dataId,
        'title': title,
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'clickCount': 0,
        'isActive': true,
      };

      // Save to Firestore
      await _db.collection(linksCollection).doc(shortCode).set(linkData);

      // Generate full URL
      String fullUrl = '$baseUrl/link/$shortCode';
      
      return fullUrl;
    } catch (e) {
      throw Exception('Failed to generate dynamic link: $e');
    }
  }

  /// Generate link for materi
  static Future<String> generateMateriLink(String materiId, String title) async {
    return await generateDataLink(
      type: 'materi',
      dataId: materiId,
      title: title,
      metadata: {'description': 'Akses materi pembelajaran'},
    );
  }

  /// Generate link for tugas
  static Future<String> generateTugasLink(String tugasId, String title) async {
    return await generateDataLink(
      type: 'tugas',
      dataId: tugasId,
      title: title,
      metadata: {'description': 'Akses tugas pembelajaran'},
    );
  }

  /// Generate link for pengumuman
  static Future<String> generatePengumumanLink(String pengumumanId, String title) async {
    return await generateDataLink(
      type: 'pengumuman',
      dataId: pengumumanId,
      title: title,
      metadata: {'description': 'Baca pengumuman'},
    );
  }

  // === LINK RESOLUTION ===

  /// Resolve short code to get data information
  static Future<Map<String, dynamic>?> resolveLink(String shortCode) async {
    try {
      DocumentSnapshot doc = await _db.collection(linksCollection).doc(shortCode).get();
      
      if (!doc.exists) {
        return null;
      }

      Map<String, dynamic> linkData = doc.data() as Map<String, dynamic>;
      
      // Check if link is active
      if (!linkData['isActive']) {
        return null;
      }

      // Increment click count
      await _incrementClickCount(shortCode);

      return linkData;
    } catch (e) {
      throw Exception('Failed to resolve link: $e');
    }
  }

  /// Get data by resolved link information
  static Future<Map<String, dynamic>?> getDataFromLink(String shortCode) async {
    try {
      Map<String, dynamic>? linkData = await resolveLink(shortCode);
      
      if (linkData == null) {
        return null;
      }

      String type = linkData['type'];
      String dataId = linkData['dataId'];

      DocumentSnapshot dataDoc;
      
      switch (type) {
        case 'materi':
          dataDoc = await _db.collection('materi').doc(dataId).get();
          break;
        case 'tugas':
          dataDoc = await _db.collection('tugas').doc(dataId).get();
          break;
        case 'pengumuman':
          dataDoc = await _db.collection('pengumuman').doc(dataId).get();
          break;
        default:
          return null;
      }

      if (!dataDoc.exists) {
        return null;
      }

      Map<String, dynamic> data = dataDoc.data() as Map<String, dynamic>;
      data['id'] = dataDoc.id;
      data['linkInfo'] = linkData;
      
      return data;
    } catch (e) {
      throw Exception('Failed to get data from link: $e');
    }
  }

  // === LINK MANAGEMENT ===

  /// Get all links created
  static Future<List<Map<String, dynamic>>> getAllLinks() async {
    try {
      QuerySnapshot snapshot = await _db.collection(linksCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['shortCode'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get links: $e');
    }
  }

  /// Get links by type
  static Future<List<Map<String, dynamic>>> getLinksByType(String type) async {
    try {
      QuerySnapshot snapshot = await _db.collection(linksCollection)
          .where('type', isEqualTo: type)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['shortCode'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get links by type: $e');
    }
  }

  /// Deactivate a link
  static Future<void> deactivateLink(String shortCode) async {
    try {
      await _db.collection(linksCollection).doc(shortCode).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to deactivate link: $e');
    }
  }

  /// Reactivate a link
  static Future<void> reactivateLink(String shortCode) async {
    try {
      await _db.collection(linksCollection).doc(shortCode).update({
        'isActive': true,
        'reactivatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reactivate link: $e');
    }
  }

  /// Delete a link permanently
  static Future<void> deleteLink(String shortCode) async {
    try {
      await _db.collection(linksCollection).doc(shortCode).delete();
    } catch (e) {
      throw Exception('Failed to delete link: $e');
    }
  }

  /// Get link analytics
  static Future<Map<String, dynamic>> getLinkAnalytics(String shortCode) async {
    try {
      DocumentSnapshot doc = await _db.collection(linksCollection).doc(shortCode).get();
      
      if (!doc.exists) {
        throw Exception('Link not found');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      return {
        'shortCode': shortCode,
        'title': data['title'],
        'type': data['type'],
        'clickCount': data['clickCount'] ?? 0,
        'createdAt': data['createdAt'],
        'isActive': data['isActive'],
        'fullUrl': '$baseUrl/link/$shortCode',
      };
    } catch (e) {
      throw Exception('Failed to get link analytics: $e');
    }
  }

  // === BULK OPERATIONS ===

  /// Generate multiple links at once
  static Future<List<String>> generateBulkLinks({
    required List<Map<String, dynamic>> items,
    required String type,
  }) async {
    try {
      List<String> generatedLinks = [];
      
      for (var item in items) {
        String link = await generateDataLink(
          type: type,
          dataId: item['id'],
          title: item['title'],
          metadata: item['metadata'],
        );
        generatedLinks.add(link);
      }
      
      return generatedLinks;
    } catch (e) {
      throw Exception('Failed to generate bulk links: $e');
    }
  }

  /// Get links with click statistics
  static Future<List<Map<String, dynamic>>> getLinksWithStats() async {
    try {
      QuerySnapshot snapshot = await _db.collection(linksCollection)
          .orderBy('clickCount', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['shortCode'] = doc.id;
        data['fullUrl'] = '$baseUrl/link/${doc.id}';
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get links with stats: $e');
    }
  }

  // === PRIVATE METHODS ===

  /// Generate unique short code for link
  static String _generateShortCode() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String random = (timestamp.hashCode % 999999).toString().padLeft(6, '0');
    return random;
  }

  /// Increment click count for a link
  static Future<void> _incrementClickCount(String shortCode) async {
    try {
      await _db.collection(linksCollection).doc(shortCode).update({
        'clickCount': FieldValue.increment(1),
        'lastClicked': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Ignore errors for click count increment
    }
  }

  /// Generate hash for data integrity
  static String _generateDataHash(Map<String, dynamic> data) {
    String dataString = jsonEncode(data);
    var bytes = utf8.encode(dataString);
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  // === SEARCH AND FILTER ===

  /// Search links by title
  static Future<List<Map<String, dynamic>>> searchLinks(String query) async {
    try {
      QuerySnapshot snapshot = await _db.collection(linksCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + '\uf8ff')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['shortCode'] = doc.id;
        data['fullUrl'] = '$baseUrl/link/${doc.id}';
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search links: $e');
    }
  }

  /// Get popular links (most clicked)
  static Future<List<Map<String, dynamic>>> getPopularLinks({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _db.collection(linksCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('clickCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['shortCode'] = doc.id;
        data['fullUrl'] = '$baseUrl/link/${doc.id}';
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get popular links: $e');
    }
  }

  /// Get recent links
  static Future<List<Map<String, dynamic>>> getRecentLinks({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _db.collection(linksCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['shortCode'] = doc.id;
        data['fullUrl'] = '$baseUrl/link/${doc.id}';
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recent links: $e');
    }
  }
}
