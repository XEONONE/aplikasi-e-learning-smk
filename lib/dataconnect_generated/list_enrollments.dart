part of 'generated.dart';

class ListEnrollmentsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListEnrollmentsVariablesBuilder(this._dataConnect, );
  Deserializer<ListEnrollmentsData> dataDeserializer = (dynamic json)  => ListEnrollmentsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListEnrollmentsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListEnrollmentsData, void> ref() {
    
    return _dataConnect.query("listEnrollments", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListEnrollmentsEnrollments {
  final Timestamp enrollmentDate;
  final String status;
  final Timestamp? completionDate;
  final int? grade;
  final ListEnrollmentsEnrollmentsStudent student;
  final ListEnrollmentsEnrollmentsCourse course;
  ListEnrollmentsEnrollments.fromJson(dynamic json):
  
  enrollmentDate = Timestamp.fromJson(json['enrollmentDate']),
  status = nativeFromJson<String>(json['status']),
  completionDate = json['completionDate'] == null ? null : Timestamp.fromJson(json['completionDate']),
  grade = json['grade'] == null ? null : nativeFromJson<int>(json['grade']),
  student = ListEnrollmentsEnrollmentsStudent.fromJson(json['student']),
  course = ListEnrollmentsEnrollmentsCourse.fromJson(json['course']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListEnrollmentsEnrollments otherTyped = other as ListEnrollmentsEnrollments;
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
    if (completionDate != null) {
      json['completionDate'] = completionDate!.toJson();
    }
    if (grade != null) {
      json['grade'] = nativeToJson<int?>(grade);
    }
    json['student'] = student.toJson();
    json['course'] = course.toJson();
    return json;
  }

  ListEnrollmentsEnrollments({
    required this.enrollmentDate,
    required this.status,
    this.completionDate,
    this.grade,
    required this.student,
    required this.course,
  });
}

@immutable
class ListEnrollmentsEnrollmentsStudent {
  final String id;
  final String displayName;
  ListEnrollmentsEnrollmentsStudent.fromJson(dynamic json):
  
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

    final ListEnrollmentsEnrollmentsStudent otherTyped = other as ListEnrollmentsEnrollmentsStudent;
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

  ListEnrollmentsEnrollmentsStudent({
    required this.id,
    required this.displayName,
  });
}

@immutable
class ListEnrollmentsEnrollmentsCourse {
  final String id;
  final String title;
  ListEnrollmentsEnrollmentsCourse.fromJson(dynamic json):
  
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

    final ListEnrollmentsEnrollmentsCourse otherTyped = other as ListEnrollmentsEnrollmentsCourse;
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

  ListEnrollmentsEnrollmentsCourse({
    required this.id,
    required this.title,
  });
}

@immutable
class ListEnrollmentsData {
  final List<ListEnrollmentsEnrollments> enrollments;
  ListEnrollmentsData.fromJson(dynamic json):
  
  enrollments = (json['enrollments'] as List<dynamic>)
        .map((e) => ListEnrollmentsEnrollments.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListEnrollmentsData otherTyped = other as ListEnrollmentsData;
    return enrollments == otherTyped.enrollments;
    
  }
  @override
  int get hashCode => enrollments.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['enrollments'] = enrollments.map((e) => e.toJson()).toList();
    return json;
  }

  ListEnrollmentsData({
    required this.enrollments,
  });
}

