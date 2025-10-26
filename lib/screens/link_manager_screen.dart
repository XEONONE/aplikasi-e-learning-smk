// lib/screens/link_manager_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_e_learning_smk/services/dynamic_link_service.dart';
import 'package:aplikasi_e_learning_smk/services/firebase_service.dart';
import 'package:aplikasi_e_learning_smk/models/materi_model.dart';
import 'package:aplikasi_e_learning_smk/models/tugas_model.dart';
import 'package:aplikasi_e_learning_smk/models/pengumuman_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkManagerScreen extends StatefulWidget {
  const LinkManagerScreen({super.key});

  @override
  State<LinkManagerScreen> createState() => _LinkManagerScreenState();
}

class _LinkManagerScreenState extends State<LinkManagerScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> allLinks = [];
  List<Map<String, dynamic>> filteredLinks = [];
  bool isLoading = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLinks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLinks() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> links = await DynamicLinkService.getAllLinks();
      setState(() {
        allLinks = links;
        _filterLinks();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading links: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterLinks() {
    List<Map<String, dynamic>> filtered = allLinks;
    
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((link) =>
        link['title'].toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Filter by current tab
    String currentType = _getCurrentTypeFromTab();
    if (currentType != 'all') {
      filtered = filtered.where((link) => link['type'] == currentType).toList();
    }

    setState(() {
      filteredLinks = filtered;
    });
  }

  String _getCurrentTypeFromTab() {
    switch (_tabController.index) {
      case 0: return 'all';
      case 1: return 'materi';
      case 2: return 'tugas';
      case 3: return 'pengumuman';
      default: return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Manager'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search links...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _filterLinks();
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                onTap: (_) => _filterLinks(),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Materi'),
                  Tab(text: 'Tugas'),
                  Tab(text: 'Pengumuman'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLinksList(),
                _buildLinksList(),
                _buildLinksList(),
                _buildLinksList(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateLinkDialog,
        label: const Text('Create Link'),
        icon: const Icon(Icons.add_link),
      ),
    );
  }

  Widget _buildLinksList() {
    if (filteredLinks.isEmpty) {
      return const Center(
        child: Text('No links found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLinks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredLinks.length,
        itemBuilder: (context, index) {
          final link = filteredLinks[index];
          return _buildLinkCard(link);
        },
      ),
    );
  }

  Widget _buildLinkCard(Map<String, dynamic> link) {
    String fullUrl = '${DynamicLinkService.baseUrl}/link/${link['shortCode']}';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getTypeIcon(link['type']),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    link['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildStatusChip(link['isActive']),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fullUrl,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(fullUrl),
                    tooltip: 'Copy Link',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.mouse, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${link['clickCount'] ?? 0} clicks',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open'),
                  onPressed: () => _openLink(fullUrl),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, link),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'analytics',
                      child: Row(
                        children: [
                          Icon(Icons.analytics),
                          SizedBox(width: 8),
                          Text('Analytics'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: link['isActive'] ? 'deactivate' : 'reactivate',
                      child: Row(
                        children: [
                          Icon(link['isActive'] ? Icons.pause : Icons.play_arrow),
                          const SizedBox(width: 8),
                          Text(link['isActive'] ? 'Deactivate' : 'Reactivate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    switch (type) {
      case 'materi':
        return const Icon(Icons.book, color: Colors.blue);
      case 'tugas':
        return const Icon(Icons.assignment, color: Colors.orange);
      case 'pengumuman':
        return const Icon(Icons.announcement, color: Colors.red);
      default:
        return const Icon(Icons.link, color: Colors.grey);
    }
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: isActive ? Colors.green[100] : Colors.grey[300],
      labelStyle: TextStyle(
        color: isActive ? Colors.green[800] : Colors.grey[800],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  void _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  void _handleMenuAction(String action, Map<String, dynamic> link) {
    switch (action) {
      case 'analytics':
        _showAnalytics(link);
        break;
      case 'deactivate':
        _deactivateLink(link['shortCode']);
        break;
      case 'reactivate':
        _reactivateLink(link['shortCode']);
        break;
      case 'delete':
        _confirmDelete(link);
        break;
    }
  }

  void _showAnalytics(Map<String, dynamic> link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Analytics - ${link['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsRow('Type', link['type']),
            _buildAnalyticsRow('Clicks', '${link['clickCount'] ?? 0}'),
            _buildAnalyticsRow('Status', link['isActive'] ? 'Active' : 'Inactive'),
            _buildAnalyticsRow('Created', _formatDate(link['createdAt'])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    // Handle Firestore Timestamp
    if (timestamp.runtimeType.toString().contains('Timestamp')) {
      return DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch,
      ).toString().substring(0, 19);
    }
    return 'N/A';
  }

  void _deactivateLink(String shortCode) async {
    try {
      await DynamicLinkService.deactivateLink(shortCode);
      _loadLinks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link deactivated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _reactivateLink(String shortCode) async {
    try {
      await DynamicLinkService.reactivateLink(shortCode);
      _loadLinks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link reactivated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _confirmDelete(Map<String, dynamic> link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: Text('Are you sure you want to delete the link for "${link['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteLink(link['shortCode']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteLink(String shortCode) async {
    try {
      await DynamicLinkService.deleteLink(shortCode);
      _loadLinks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showCreateLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateLinkDialog(
        onLinkCreated: () {
          Navigator.of(context).pop();
          _loadLinks();
        },
      ),
    );
  }
}

// Dialog untuk membuat link baru
class _CreateLinkDialog extends StatefulWidget {
  final VoidCallback onLinkCreated;

  const _CreateLinkDialog({required this.onLinkCreated});

  @override
  State<_CreateLinkDialog> createState() => _CreateLinkDialogState();
}

class _CreateLinkDialogState extends State<_CreateLinkDialog> {
  String selectedType = 'materi';
  String? selectedDataId;
  String selectedTitle = '';
  List<dynamic> availableData = [];
  bool isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoadingData = true;
    });

    try {
      List<dynamic> data = [];
      switch (selectedType) {
        case 'materi':
          data = await FirebaseService.getAllMateri();
          break;
        case 'tugas':
          data = await FirebaseService.getAllTugas();
          break;
        case 'pengumuman':
          data = await FirebaseService.getAllPengumuman();
          break;
      }
      
      setState(() {
        availableData = data;
        selectedDataId = data.isNotEmpty ? data.first.id : null;
        selectedTitle = data.isNotEmpty ? data.first.judul : '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(value: 'materi', child: Text('Materi')),
              DropdownMenuItem(value: 'tugas', child: Text('Tugas')),
              DropdownMenuItem(value: 'pengumuman', child: Text('Pengumuman')),
            ],
            onChanged: (value) {
              setState(() {
                selectedType = value!;
                selectedDataId = null;
                selectedTitle = '';
              });
              _loadData();
            },
          ),
          const SizedBox(height: 16),
          if (isLoadingData)
            const CircularProgressIndicator()
          else
            DropdownButtonFormField<String>(
              value: selectedDataId,
              decoration: const InputDecoration(labelText: 'Select Item'),
              items: availableData.map((item) {
                return DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.judul),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDataId = value;
                  final selected = availableData.firstWhere((item) => item.id == value);
                  selectedTitle = selected.judul;
                });
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedDataId != null ? _createLink : null,
          child: const Text('Create Link'),
        ),
      ],
    );
  }

  void _createLink() async {
    try {
      String link = await DynamicLinkService.generateDataLink(
        type: selectedType,
        dataId: selectedDataId!,
        title: selectedTitle,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link created: $link')),
        );
        widget.onLinkCreated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating link: $e')),
        );
      }
    }
  }
}
