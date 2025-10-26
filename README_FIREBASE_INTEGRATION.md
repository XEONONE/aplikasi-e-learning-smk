# Firebase Integration Setup Guide

## 🔥 Firebase Project Setup

### 1. Firebase Console Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Your project: `aplikasi-e-learning-smk` is already configured
3. Firebase services enabled:
   - **Authentication** ✅
   - **Firestore Database** ✅
   - **Storage** ✅
   - **Hosting** (for web link viewer) 

### 2. Database Collections Structure

```
firestore/
├── users/                    # User profiles
│   └── {userId}/
│       ├── id: string
│       ├── nama: string
│       ├── email: string
│       ├── role: string      # 'guru', 'siswa', 'admin'
│       └── ...
│
├── materi/                   # Learning materials
│   └── {materiId}/
│       ├── id: string
│       ├── judul: string
│       ├── deskripsi: string
│       ├── guruId: string
│       ├── kelasId: string
│       ├── fileUrl?: string
│       └── tanggalDibuat: timestamp
│
├── tugas/                    # Assignments
│   └── {tugasId}/
│       ├── id: string
│       ├── judul: string
│       ├── deskripsi: string
│       ├── guruId: string
│       ├── kelasId: string
│       ├── deadline?: timestamp
│       ├── fileUrl?: string
│       └── tanggalDibuat: timestamp
│
├── pengumuman/               # Announcements
│   └── {pengumumanId}/
│       ├── id: string
│       ├── judul: string
│       ├── isi: string
│       ├── guruId: string
│       └── tanggalDibuat: timestamp
│
├── komentar/                 # Comments
│   └── {komentarId}/
│       ├── id: string
│       ├── parentId: string  # ID of parent (materi/tugas/pengumuman)
│       ├── type: string      # 'materi', 'tugas', 'pengumuman'
│       ├── userId: string
│       ├── isi: string
│       └── tanggalDibuat: timestamp
│
└── dynamic_links/            # Generated links
    └── {shortCode}/
        ├── shortCode: string
        ├── type: string      # 'materi', 'tugas', 'pengumuman'
        ├── dataId: string    # ID of referenced data
        ├── title: string
        ├── metadata: object
        ├── createdAt: timestamp
        ├── clickCount: number
        ├── lastClicked?: timestamp
        └── isActive: boolean
```

## 🔗 Dynamic Link System

### Features
- ✅ Generate shareable links for any content
- ✅ Click tracking and analytics
- ✅ Link activation/deactivation
- ✅ Web viewer for links (no app required)
- ✅ Bulk link generation
- ✅ Search and filter links

### Link Format
```
https://aplikasi-e-learning-smk.web.app/link/{shortCode}
```

### Example Links
- Materi: `https://aplikasi-e-learning-smk.web.app/link/123456`
- Tugas: `https://aplikasi-e-learning-smk.web.app/link/789012`
- Pengumuman: `https://aplikasi-e-learning-smk.web.app/link/345678`

## 🚀 Implementation Files Created

### Core Services
1. **`lib/services/firebase_service.dart`**
   - CRUD operations for all collections
   - Real-time streams
   - Batch operations
   - Search functionality

2. **`lib/services/dynamic_link_service.dart`**
   - Link generation and resolution
   - Click tracking
   - Link management (activate/deactivate/delete)
   - Analytics and statistics

### UI Screens
3. **`lib/screens/link_manager_screen.dart`**
   - Manage all generated links
   - Create new links
   - View analytics
   - Search and filter

4. **`lib/screens/link_viewer_screen.dart`**
   - Mobile view for shared links
   - Content display based on type
   - Share functionality

### Utilities
5. **`lib/utils/link_helper.dart`**
   - Helper functions for link generation
   - UI components for sharing
   - Validation utilities

### Web Viewer
6. **`web/link_viewer.html`**
   - Standalone web page for viewing shared content
   - Works without mobile app
   - Firebase integration for data loading

### Security
7. **`firestore.rules`**
   - Database security rules
   - Role-based access control
   - Public link access for sharing

## 🔧 Usage Examples

### 1. Generate Link for Materi
```dart
// Using LinkHelper (recommended)
LinkHelper.generateMateriLink(context, materiId, materiTitle);

// Direct service call
String link = await DynamicLinkService.generateMateriLink(materiId, materiTitle);
```

### 2. Add Share Button to Widgets
```dart
// Add to your existing cards
LinkHelper.buildShareButton(
  context: context,
  type: 'materi',
  dataId: materi.id,
  title: materi.judul,
)
```

### 3. Access Link Manager
```dart
// Navigate to link management
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LinkManagerScreen()),
);
```

### 4. Integrate with Existing Widgets
```dart
// Example: Add share button to MateriCard
class MateriCard extends StatelessWidget {
  final MateriModel materi;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Existing content...
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Other buttons...
              LinkHelper.buildShareButton(
                context: context,
                type: 'materi',
                dataId: materi.id!,
                title: materi.judul,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## 📱 Mobile Integration Steps

### 1. Update Dependencies
The required packages are already added to `pubspec.yaml`:
- `crypto: ^3.0.3` (for link generation)

### 2. Add to Navigation
Add link manager to your app's navigation:

```dart
// In your drawer or navigation
ListTile(
  leading: const Icon(Icons.link),
  title: const Text('Link Manager'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LinkManagerScreen()),
    );
  },
),
```

### 3. Update Existing Widgets
Add share buttons to your existing materi, tugas, and pengumuman cards.

## 🌐 Web Deployment

### 1. Firebase Hosting Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize hosting
firebase init hosting

# Deploy
firebase deploy --only hosting
```

### 2. Configure Routing
Add to `firebase.json`:
```json
{
  "hosting": {
    "public": "web",
    "rewrites": [
      {
        "source": "/link/**",
        "destination": "/link_viewer.html"
      }
    ]
  }
}
```

## 🔒 Security Rules

The Firestore security rules ensure:
- Users can only modify their own data
- Teachers can create/edit educational content
- Students can read content and submit assignments
- Public read access for dynamic links
- Role-based permissions

## 📊 Analytics & Monitoring

Track link performance:
- Click counts for each link
- Popular content identification
- Usage statistics
- Active/inactive link management

## 🎯 Next Steps

1. **Deploy web viewer** to Firebase Hosting
2. **Add share buttons** to existing widgets
3. **Test link generation** and sharing
4. **Monitor usage** through Firebase Analytics
5. **Implement QR codes** for offline sharing

## 🔗 Quick Links

- Firebase Console: https://console.firebase.google.com/project/aplikasi-e-learning-smk
- Project URL: https://aplikasi-e-learning-smk.web.app
- Firestore: https://console.firebase.google.com/project/aplikasi-e-learning-smk/firestore
