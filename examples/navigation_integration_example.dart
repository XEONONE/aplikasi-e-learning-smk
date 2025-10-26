// Example: Adding Link Manager to Navigation
// Add this to your existing drawer or navigation menu

import 'package:flutter/material.dart';
import 'package:aplikasi_e_learning_smk/screens/link_manager_screen.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'E-Learning SMK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          
          // Existing menu items...
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Materi'),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Tugas'),
            onTap: () => Navigator.pop(context),
          ),
          
          // NEW: Link Manager
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Link Manager'),
            subtitle: const Text('Manage shared links'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LinkManagerScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // Other menu items...
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
