part of 'generated.dart';

class ListSubmissionsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListSubmissionsVariablesBuilder(this._dataConnect, );
  Deserializer<ListSubmissionsData> dataDeserializer = (dynamic json)  => ListSubmissionsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListSubmissionsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListSubmissionsData, void> ref() {
    
    return _dataConnect.query("listSubmissions", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListSubmissionsSubmissions {
  final Timestamp submissionDate;
  final int score;
  final String? studentResponse;
  final String? feedback;
  final ListSubmissionsSubmissionsStudent student;
  final ListSubmissionsSubmissionsAssignment assignment;
  ListSubmissionsSubmissions.fromJson(dynamic json):
  
  submissionDate = Timestamp.fromJson(json['submissionDate']),
  score = nativeFromJson<int>(json['score']),
  studentResponse = json['studentResponse'] == null ? null : nativeFromJson<String>(json['studentResponse']),
  feedback = json['feedback'] == null ? null : nativeFromJson<String>(json['feedback']),
  student = ListSubmissionsSubmissionsStudent.fromJson(json['student']),
  assignment = ListSubmissionsSubmissionsAssignment.fromJson(json['assignment']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListSubmissionsSubmissions otherTyped = other as ListSubmissionsSubmissions;
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
    if (studentResponse != null) {
      json['studentResponse'] = nativeToJson<String?>(studentResponse);
    }
    if (feedback != null) {
      json['feedback'] = nativeToJson<String?>(feedback);
    }
    json['student'] = student.toJson();
    json['assignment'] = assignment.toJson();
    return json;
  }

  ListSubmissionsSubmissions({
    required this.submissionDate,
    required this.score,
    this.studentResponse,
    this.feedback,
    required this.student,
    required this.assignment,
  });
}

@immutable
class ListSubmissionsSubmissionsStudent {
  final String id;
  final String displayName;
  ListSubmissionsSubmissionsStudent.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  displayName = nativeFromJson<String>(json['displayName']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListSubmissionsSubmissionsStudent otherTyped = other as ListSubmissionsSubmissionsStudent;
    return id == otherTyped.id && 
    displayName == otherTyped.displayName;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, displayName.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['displayName'] = nativeToJson<String>(displayName);
    return json;
  }

  ListSubmissionsSubmissionsStudent({
    required this.id,
    required this.displayName,
  });
}

@immutable
class ListSubmissionsSubmissionsAssignment {
  final String id;
  final String title;
  ListSubmissionsSubmissionsAssignment.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListSubmissionsSubmissionsAssignment otherTyped = other as ListSubmissionsSubmissionsAssignment;
    return id == otherTyped.id && 
    title == otherTyped.title;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    return json;
  }

  ListSubmissionsSubmissionsAssignment({
    required this.id,
    required this.title,
  });
}

@immutable
class ListSubmissionsData {
  final List<ListSubmissionsSubmissions> submissions;
  ListSubmissionsData.fromJson(dynamic json):
  
  submissions = (json['submissions'] as List<dynamic>)
        .map((e) => ListSubmissionsSubmissions.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListSubmissionsData otherTyped = other as ListSubmissionsData;
    return submissions == otherTyped.submissions;
    
  }
  @override
  int get hashCode => submissions.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['submissions'] = submissions.map((e) => e.toJson()).toList();
    return json;
  }

  ListSubmissionsData({
    required this.submissions,
  });
}

