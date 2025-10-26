// lib/utils/link_helper.dart

import 'package:aplikasi_e_learning_smk/services/dynamic_link_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkHelper {
  
  /// Generate link with loading dialog
  static Future<String?> generateLinkWithDialog({
    required BuildContext context,
    required String type,
    required String dataId,
    required String title,
    Map<String, dynamic>? metadata,
  }) async {
    String? generatedLink;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('Generating $type link...'),
          ],
        ),
      ),
    );

    try {
      generatedLink = await DynamicLinkService.generateDataLink(
        type: type,
        dataId: dataId,
        title: title,
        metadata: metadata,
      );
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showLinkGeneratedDialog(context, generatedLink, title);
      }
      
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    return generatedLink;
  }

  /// Show link generated success dialog
  static void _showLinkGeneratedDialog(
    BuildContext context, 
    String link, 
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Link Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Link for "$title" has been created successfully.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      link,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              shareLink(context, link, title);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  /// Share link using device's share functionality
  static void shareLink(BuildContext context, String link, String title) {
    // For now, just copy to clipboard
    // In a real app, you would use share_plus package
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard for sharing')),
    );
  }

  /// Generate link for materi
  static Future<String?> generateMateriLink(
    BuildContext context,
    String materiId,
    String title,
  ) async {
    return await generateLinkWithDialog(
      context: context,
      type: 'materi',
      dataId: materiId,
      title: title,
      metadata: {'description': 'Akses materi pembelajaran'},
    );
  }

  /// Generate link for tugas
  static Future<String?> generateTugasLink(
    BuildContext context,
    String tugasId,
    String title,
  ) async {
    return await generateLinkWithDialog(
      context: context,
      type: 'tugas',
      dataId: tugasId,
      title: title,
      metadata: {'description': 'Akses tugas pembelajaran'},
    );
  }

  /// Generate link for pengumuman
  static Future<String?> generatePengumumanLink(
    BuildContext context,
    String pengumumanId,
    String title,
  ) async {
    return await generateLinkWithDialog(
      context: context,
      type: 'pengumuman',
      dataId: pengumumanId,
      title: title,
      metadata: {'description': 'Baca pengumuman'},
    );
  }

  /// Add share button to any card widget
  static Widget buildShareButton({
    required BuildContext context,
    required String type,
    required String dataId,
    required String title,
    IconData icon = Icons.share,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () => _handleShare(context, type, dataId, title),
      tooltip: 'Share',
    );
  }

  static void _handleShare(
    BuildContext context,
    String type,
    String dataId,
    String title,
  ) {
    switch (type) {
      case 'materi':
        generateMateriLink(context, dataId, title);
        break;
      case 'tugas':
        generateTugasLink(context, dataId, title);
        break;
      case 'pengumuman':
        generatePengumumanLink(context, dataId, title);
        break;
    }
  }

  /// Show link options menu
  static void showLinkOptionsMenu({
    required BuildContext context,
    required String type,
    required String dataId,
    required String title,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Generate Link'),
              subtitle: const Text('Create a shareable link'),
              onTap: () {
                Navigator.of(context).pop();
                _handleShare(context, type, dataId, title);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Generate QR Code'),
              subtitle: const Text('Create QR code for easy sharing'),
              onTap: () {
                Navigator.of(context).pop();
                _generateQRCode(context, type, dataId, title);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _generateQRCode(
    BuildContext context,
    String type,
    String dataId,
    String title,
  ) {
    // Placeholder for QR code generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code generation will be implemented')),
    );
  }

  /// Validate short code format
  static bool isValidShortCode(String shortCode) {
    return shortCode.length == 6 && RegExp(r'^[0-9]+$').hasMatch(shortCode);
  }

  /// Extract short code from full URL
  static String? extractShortCode(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[segments.length - 2] == 'link') {
      final shortCode = segments.last;
      return isValidShortCode(shortCode) ? shortCode : null;
    }
    
    return null;
  }

  /// Build link statistics widget
  static Widget buildLinkStats(Map<String, dynamic> linkData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, color: Colors.blue, size: 16),
          const SizedBox(width: 4),
          Text(
            '${linkData['clickCount'] ?? 0} views',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Icon(
            linkData['isActive'] ? Icons.check_circle : Icons.cancel,
            color: linkData['isActive'] ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            linkData['isActive'] ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 12,
              color: linkData['isActive'] ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
