# Migration from Firebase Data Connect to Firestore

## Tasks
- [x] Remove the entire `dataconnect/` folder
- [x] Fix import statements in Dart files (add colon after 'package')
- [x] Update `lib/services/auth_service.dart` to use Firestore
- [x] Update `lib/services/notification_service.dart` to use Firestore and fix imports
- [ ] Update screens to use Firestore instead of Data Connect
  - [ ] `lib/screens/edit_materi_screen.dart`
  - [ ] `lib/screens/edit_task_screen.dart`
  - [ ] `lib/screens/guru_dashboard_screen.dart`
  - [ ] `lib/screens/guru_profile_screen.dart`
  - [ ] `lib/screens/siswa_dashboard_screen.dart`
  - [ ] `lib/screens/student_nilai_screen.dart`
  - [ ] `lib/screens/task_detail_screen.dart`
  - [ ] `lib/screens/task_list_screen.dart`
- [ ] Update widgets to use Firestore
  - [ ] `lib/widgets/task_card.dart`
- [x] Update `lib/auth_gate.dart`
- [ ] Update or create models for Firestore data structures (`lib/models/user_model.dart`)
- [ ] Fix other errors (missing parameters, undefined methods, unused variables)
- [x] Run `flutter pub get`
- [x] Test the app and address remaining compilation errors
