# TODO: Fix Workspace Problems

## GraphQL Fixes
- [x] Remove invalid mutations in dataconnect/example/mutations.gql (movie_insert, review_upsert, review_delete) - No invalid mutations found
- [x] Remove invalid queries in dataconnect/example/queries.gql (listMovie_insert, lists, review_insert, movies) - No invalid queries found

## Dart Fixes
- [x] lib/auth_gate.dart: Add missing 'destinationPage' parameter - Fixed by adding parameter to dashboard screens
- [ ] lib/screens/edit_materi_screen.dart: Add import for user_model.dart, fix UserModel usage
- [x] lib/screens/edit_task_screen.dart: Fix nullable return types by adding returns or changing to void - Fixed by changing Future<void> to void
- [ ] lib/screens/guru_dashboard_screen.dart: Add missing imports, fix method calls
- [ ] lib/screens/guru_profile_screen.dart: Add import for user_model.dart, fix UserModel
- [ ] lib/screens/siswa_dashboard_screen.dart: Fix named parameters, remove unused imports
- [ ] lib/screens/student_nilai_screen.dart: Fix method call
- [ ] lib/screens/task_detail_screen.dart: Fix named parameters
- [ ] lib/screens/task_list_screen.dart: Add import for user_model.dart, fix UserModel, remove unused variable
- [ ] lib/services/auth_service.dart: Fix unassigned variable
- [ ] lib/services/notification_service.dart: Add missing Firebase imports
- [ ] lib/screens/activation_screen.dart: Remove unused variables
- [ ] lib/widgets/task_card.dart: Fix switch statement

## Followup
- [ ] Run flutter analyze to check for remaining errors
- [ ] Test the app functionality
