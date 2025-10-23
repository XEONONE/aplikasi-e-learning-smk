part of 'generated.dart';

class CreateSubmissionVariablesBuilder {
  Timestamp submissionDate;
  int score;
  Optional<String> _studentResponse = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _feedback = Optional.optional(nativeFromJson, nativeToJson);
  String student;
  String assignment;

  final FirebaseDataConnect _dataConnect;  CreateSubmissionVariablesBuilder studentResponse(String? t) {
   _studentResponse.value = t;
   return this;
  }
  CreateSubmissionVariablesBuilder feedback(String? t) {
   _feedback.value = t;
   return this;
  }

  CreateSubmissionVariablesBuilder(this._dataConnect, {required  this.submissionDate,required  this.score,required  this.student,required  this.assignment,});
  Deserializer<CreateSubmissionData> dataDeserializer = (dynamic json)  => CreateSubmissionData.fromJson(jsonDecode(json));
  Serializer<CreateSubmissionVariables> varsSerializer = (CreateSubmissionVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateSubmissionData, CreateSubmissionVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateSubmissionData, CreateSubmissionVariables> ref() {
    CreateSubmissionVariables vars= CreateSubmissionVariables(submissionDate: submissionDate,score: score,studentResponse: _studentResponse,feedback: _feedback,student: student,assignment: assignment,);
    return _dataConnect.mutation("createSubmission", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateSubmissionSubmissionInsert {
  final String studentId;
  final String assignmentId;
  CreateSubmissionSubmissionInsert.fromJson(dynamic json):
  
  studentId = nativeFromJson<String>(json['studentId']),
  assignmentId = nativeFromJson<String>(json['assignmentId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSubmissionSubmissionInsert otherTyped = other as CreateSubmissionSubmissionInsert;
    return studentId == otherTyped.studentId && 
    assignmentId == otherTyped.assignmentId;
    
  }
  @override
  int get hashCode => Object.hashAll([studentId.hashCode, assignmentId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['studentId'] = nativeToJson<String>(studentId);
    json['assignmentId'] = nativeToJson<String>(assignmentId);
    return json;
  }

  CreateSubmissionSubmissionInsert({
    required this.studentId,
    required this.assignmentId,
  });
}

@immutable
class CreateSubmissionData {
  final CreateSubmissionSubmissionInsert submission_insert;
  CreateSubmissionData.fromJson(dynamic json):
  
  submission_insert = CreateSubmissionSubmissionInsert.fromJson(json['submission_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSubmissionData otherTyped = other as CreateSubmissionData;
    return submission_insert == otherTyped.submission_insert;
    
  }
  @override
  int get hashCode => submission_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['submission_insert'] = submission_insert.toJson();
    return json;
  }

  CreateSubmissionData({
    required this.submission_insert,
  });
}

@immutable
class CreateSubmissionVariables {
  final Timestamp submissionDate;
  final int score;
  late final Optional<String>studentResponse;
  late final Optional<String>feedback;
  final String student;
  final String assignment;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateSubmissionVariables.fromJson(Map<String, dynamic> json):
  
  submissionDate = Timestamp.fromJson(json['submissionDate']),
  score = nativeFromJson<int>(json['score']),
  student = nativeFromJson<String>(json['student']),
  assignment = nativeFromJson<String>(json['assignment']) {
  
  
  
  
    studentResponse = Optional.optional(nativeFromJson, nativeToJson);
    studentResponse.value = json['studentResponse'] == null ? null : nativeFromJson<String>(json['studentResponse']);
  
  
    feedback = Optional.optional(nativeFromJson, nativeToJson);
    feedback.value = json['feedback'] == null ? null : nativeFromJson<String>(json['feedback']);
  
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSubmissionVariables otherTyped = other as CreateSubmissionVariables;
    return submissionDate == otherTyped.submissionDate && 
    score == otherTyped.score && 
    studentResponse == otherTyped.studentResponse && 
    feedback == otherTyped.feedback && 
    student == otherTyped.student && 
    assignment == otherTyped.assignment;
    
  }
  @override
  int get hashCode => Object.hashAll([submissionDate.hashCode, score.hashCode, studentResponse.hashCode, feedback.hashCode, student.hashCode, assignment.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['submissionDate'] = submissionDate.toJson();
    json['score'] = nativeToJson<int>(score);
    if(studentResponse.state == OptionalState.set) {
      json['studentResponse'] = studentResponse.toJson();
    }
    if(feedback.state == OptionalState.set) {
      json['feedback'] = feedback.toJson();
    }
    json['student'] = nativeToJson<String>(student);
    json['assignment'] = nativeToJson<String>(assignment);
    return json;
  }

  CreateSubmissionVariables({
    required this.submissionDate,
    required this.score,
    required this.studentResponse,
    required this.feedback,
    required this.student,
    required this.assignment,
  });
}

