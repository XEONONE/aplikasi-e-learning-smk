import 'package:flutter/material.dart';
// TODO: Anda mungkin perlu mengimpor file lain,
// misalnya untuk mengambil data pengguna (email) atau untuk navigasi

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _notificationsEnabled = true; // Nilai default
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // TODO: Ganti 'ahmad.fauzi@email.com' dengan email pengguna yang
    // sedang login. Anda bisa mendapatkannya dari Firebase Auth atau
    // state management Anda.
    _emailController.text = 'ahmad.fauzi@email.com';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menyimpan pengaturan
  void _saveSettings() {
    // TODO: Tambahkan logika untuk menyimpan pengaturan
    
    // 1. Cek jika password baru diisi:
    String newPassword = _newPasswordController.text.trim();
    if (newPassword.isNotEmpty) {
      // Panggil fungsi untuk update password (misal: di Firebase Auth)
      // print('Updating password to: $newPassword');
      // authService.updatePassword(newPassword);
    }
    
    // 2. Simpan status notifikasi
    // (misal: ke Firestore atau SharedPreferences)
    // print('Notifications enabled: $_notificationsEnabled');
    // userService.updateNotificationSettings(_notificationsEnabled);

    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext) {
    // Mendeteksi tema (terang/gelap) untuk warna field
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Logika untuk kembali ke halaman sebelumnya
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Aksi untuk tombol titik tiga (opsional)
            },
          ),
        ],
        // Styling AppBar agar sesuai gambar
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Field Email (Read Only) ---
            TextField(
              controller: _emailController,
              readOnly: true, // Tidak bisa diubah
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: fieldColor, // Warna latar field
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: textColor.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),

            // --- Field Ganti Password ---
            TextField(
              controller: _newPasswordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Ganti Password',
                hintText: 'Masukkan password baru',
                filled: true,
                fillColor: fieldColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 24),

            // --- Toggle Notifikasi ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: fieldColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_outlined, color: iconColor),
                      const SizedBox(width: 12),
                      Text('Notifikasi', style: TextStyle(color: textColor, fontSize: 16)),
                    ],
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeThumbColor: Colors.blueAccent, // Warna saat aktif
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- Tombol Simpan ---
            ElevatedButton(
              onPressed: _saveSettings, // Panggil fungsi simpan
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Warna tombol
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Simpan Pengaturan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),

      // --- Catatan tentang Bottom Navigation Bar ---
      // Sesuai gambar, halaman ini memiliki Bottom Navigation Bar.
      // Jika file ini dipanggil dari dalam file dashboard utama Anda
      // (seperti siswa_dashboard_screen.dart) yang SUDAH punya BottomNavBar,
      // maka Anda TIDAK PERLU menambahkan properti `bottomNavigationBar` di sini.

      // Namun, jika ini adalah halaman terpisah, Anda bisa tambahkan
      // kode BottomNavBar seperti di bawah ini (sesuaikan `currentIndex`):
      /*
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: 3, // Set ke 3 untuk 'Profil'
        onTap: (index) {
          // TODO: Tambahkan logika navigasi utama Anda di sini
        },
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
      ),
      */
    );
  }
}