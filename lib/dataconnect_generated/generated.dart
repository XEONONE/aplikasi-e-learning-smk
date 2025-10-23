library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'create_course.dart';

part 'create_enrollment.dart';

part 'create_module.dart';

part 'create_lesson.dart';

part 'create_assignment.dart';

part 'create_submission.dart';

part 'list_users.dart';

part 'get_user.dart';

part 'list_courses.dart';

part 'get_course.dart';

part 'list_enrollments.dart';

part 'list_modules.dart';

part 'list_lessons.dart';

part 'list_assignments.dart';

part 'list_submissions.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser ({required String displayName, required String email, required String role, }) {
    return CreateUserVariablesBuilder(dataConnect, displayName: displayName,email: email,role: role,);
  }
  
  
  CreateCourseVariablesBuilder createCourse ({required String title, required String description, required String category, required String difficultyLevel, required String instructor, }) {
    return CreateCourseVariablesBuilder(dataConnect, title: title,description: description,category: category,difficultyLevel: difficultyLevel,instructor: instructor,);
  }
  
  
  CreateEnrollmentVariablesBuilder createEnrollment ({required Timestamp enrollmentDate, required String status, required String student, required String course, }) {
    return CreateEnrollmentVariablesBuilder(dataConnect, enrollmentDate: enrollmentDate,status: status,student: student,course: course,);
  }
  
  
  CreateModuleVariablesBuilder createModule ({required String title, required String description, required int orderIndex, required String course, }) {
    return CreateModuleVariablesBuilder(dataConnect, title: title,description: description,orderIndex: orderIndex,course: course,);
  }
  
  
  CreateLessonVariablesBuilder createLesson ({required String title, required String type, required String contentUrl, required int orderIndex, required String module, }) {
    return CreateLessonVariablesBuilder(dataConnect, title: title,type: type,contentUrl: contentUrl,orderIndex: orderIndex,module: module,);
  }
  
  
  CreateAssignmentVariablesBuilder createAssignment ({required String title, required String description, required String type, required DateTime dueDate, required int maxScore, required String module, }) {
    return CreateAssignmentVariablesBuilder(dataConnect, title: title,description: description,type: type,dueDate: dueDate,maxScore: maxScore,module: module,);
  }
  
  
  CreateSubmissionVariablesBuilder createSubmission ({required Timestamp submissionDate, required int score, required String student, required String assignment, }) {
    return CreateSubmissionVariablesBuilder(dataConnect, submissionDate: submissionDate,score: score,student: student,assignment: assignment,);
  }
  
  
  ListUsersVariablesBuilder listUsers () {
    return ListUsersVariablesBuilder(dataConnect, );
  }
  
  
  GetUserVariablesBuilder getUser ({required String id, }) {
    return GetUserVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListCoursesVariablesBuilder listCourses () {
    return ListCoursesVariablesBuilder(dataConnect, );
  }
  
  
  GetCourseVariablesBuilder getCourse ({required String id, }) {
    return GetCourseVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListEnrollmentsVariablesBuilder listEnrollments () {
    return ListEnrollmentsVariablesBuilder(dataConnect, );
  }
  
  
  ListModulesVariablesBuilder listModules () {
    return ListModulesVariablesBuilder(dataConnect, );
  }
  
  
  ListLessonsVariablesBuilder listLessons () {
    return ListLessonsVariablesBuilder(dataConnect, );
  }
  
  
  ListAssignmentsVariablesBuilder listAssignments () {
    return ListAssignmentsVariablesBuilder(dataConnect, );
  }
  
  
  ListSubmissionsVariablesBuilder listSubmissions () {
    return ListSubmissionsVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'asia-southeast2',
    'example',
    'aplikasi-e-learning-smk',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}

