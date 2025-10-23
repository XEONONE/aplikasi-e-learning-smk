part of 'generated.dart';

class CreateEnrollmentVariablesBuilder {
  Timestamp enrollmentDate;
  String status;
  Optional<Timestamp> _completionDate = Optional.optional((json) => json['completionDate'] = Timestamp.fromJson(json['completionDate']), defaultSerializer);
  Optional<int> _grade = Optional.optional(nativeFromJson, nativeToJson);
  String student;
  String course;

  final FirebaseDataConnect _dataConnect;  CreateEnrollmentVariablesBuilder completionDate(Timestamp? t) {
   _completionDate.value = t;
   return this;
  }
  CreateEnrollmentVariablesBuilder grade(int? t) {
   _grade.value = t;
   return this;
  }

  CreateEnrollmentVariablesBuilder(this._dataConnect, {required  this.enrollmentDate,required  this.status,required  this.student,required  this.course,});
  Deserializer<CreateEnrollmentData> dataDeserializer = (dynamic json)  => CreateEnrollmentData.fromJson(jsonDecode(json));
  Serializer<CreateEnrollmentVariables> varsSerializer = (CreateEnrollmentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateEnrollmentData, CreateEnrollmentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateEnrollmentData, CreateEnrollmentVariables> ref() {
    CreateEnrollmentVariables vars= CreateEnrollmentVariables(enrollmentDate: enrollmentDate,status: status,completionDate: _completionDate,grade: _grade,student: student,course: course,);
    return _dataConnect.mutation("createEnrollment", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateEnrollmentEnrollmentInsert {
  final String studentId;
  final String courseId;
  CreateEnrollmentEnrollmentInsert.fromJson(dynamic json):
  
  studentId = nativeFromJson<String>(json['studentId']),
  courseId = nativeFromJson<String>(json['courseId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateEnrollmentEnrollmentInsert otherTyped = other as CreateEnrollmentEnrollmentInsert;
    return studentId == otherTyped.studentId && 
    courseId == otherTyped.courseId;
    
  }
  @override
  int get hashCode => Object.hashAll([studentId.hashCode, courseId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['studentId'] = nativeToJson<String>(studentId);
    json['courseId'] = nativeToJson<String>(courseId);
    return json;
  }

  CreateEnrollmentEnrollmentInsert({
    required this.studentId,
    required this.courseId,
  });
}

@immutable
class CreateEnrollmentData {
  final CreateEnrollmentEnrollmentInsert enrollment_insert;
  CreateEnrollmentData.fromJson(dynamic json):
  
  enrollment_insert = CreateEnrollmentEnrollmentInsert.fromJson(json['enrollment_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateEnrollmentData otherTyped = other as CreateEnrollmentData;
    return enrollment_insert == otherTyped.enrollment_insert;
    
  }
  @override
  int get hashCode => enrollment_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['enrollment_insert'] = enrollment_insert.toJson();
    return json;
  }

  CreateEnrollmentData({
    required this.enrollment_insert,
  });
}

@immutable
class CreateEnrollmentVariables {
  final Timestamp enrollmentDate;
  final String status;
  late final Optional<Timestamp>completionDate;
  late final Optional<int>grade;
  final String student;
  final String course;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateEnrollmentVariables.fromJson(Map<String, dynamic> json):
  
  enrollmentDate = Timestamp.fromJson(json['enrollmentDate']),
  status = nativeFromJson<String>(json['status']),
  student = nativeFromJson<String>(json['student']),
  course = nativeFromJson<String>(json['course']) {
  
  
  
  
    completionDate = Optional.optional((json) => json['completionDate'] = Timestamp.fromJson(json['completionDate']), defaultSerializer);
    completionDate.value = json['completionDate'] == null ? null : Timestamp.fromJson(json['completionDate']);
  
  
    grade = Optional.optional(nativeFromJson, nativeToJson);
    grade.value = json['grade'] == null ? null : nativeFromJson<int>(json['grade']);
  
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateEnrollmentVariables otherTyped = other as CreateEnrollmentVariables;
    return enrollmentDate == otherTyped.enrollmentDate && 
    status == otherTyped.status && 
    completionDate == otherTyped.completionDate && 
    grade == otherTyped.grade && 
    student == otherTyped.student && 
    course == otherTyped.course;
    
  }
  @override
  int get hashCode => Object.hashAll([enrollmentDate.hashCode, status.hashCode, completionDate.hashCode, grade.hashCode, student.hashCode, course.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['enrollmentDate'] = enrollmentDate.toJson();
    json['status'] = nativeToJson<String>(status);
    if(completionDate.state == OptionalState.set) {
      json['completionDate'] = completionDate.toJson();
    }
    if(grade.state == OptionalState.set) {
      json['grade'] = grade.toJson();
    }
    json['student'] = nativeToJson<String>(student);
    json['course'] = nativeToJson<String>(course);
    return json;
  }

  CreateEnrollmentVariables({
    required this.enrollmentDate,
    required this.status,
    required this.completionDate,
    required this.grade,
    required this.student,
    required this.course,
  });
}

