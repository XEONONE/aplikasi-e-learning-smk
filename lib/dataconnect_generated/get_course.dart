part of 'generated.dart';

class GetCourseVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetCourseVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetCourseData> dataDeserializer = (dynamic json)  => GetCourseData.fromJson(jsonDecode(json));
  Serializer<GetCourseVariables> varsSerializer = (GetCourseVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetCourseData, GetCourseVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetCourseData, GetCourseVariables> ref() {
    GetCourseVariables vars= GetCourseVariables(id: id,);
    return _dataConnect.query("getCourse", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetCourseCourse {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficultyLevel;
  final Timestamp createdAt;
  final String? thumbnailUrl;
  final GetCourseCourseInstructor? instructor;
  GetCourseCourse.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  description = nativeFromJson<String>(json['description']),
  category = nativeFromJson<String>(json['category']),
  difficultyLevel = nativeFromJson<String>(json['difficultyLevel']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  thumbnailUrl = json['thumbnailUrl'] == null ? null : nativeFromJson<String>(json['thumbnailUrl']),
  instructor = json['instructor'] == null ? null : GetCourseCourseInstructor.fromJson(json['instructor']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseCourse otherTyped = other as GetCourseCourse;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    description == otherTyped.description && 
    category == otherTyped.category && 
    difficultyLevel == otherTyped.difficultyLevel && 
    createdAt == otherTyped.createdAt && 
    thumbnailUrl == otherTyped.thumbnailUrl && 
    instructor == otherTyped.instructor;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, description.hashCode, category.hashCode, difficultyLevel.hashCode, createdAt.hashCode, thumbnailUrl.hashCode, instructor.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['description'] = nativeToJson<String>(description);
    json['category'] = nativeToJson<String>(category);
    json['difficultyLevel'] = nativeToJson<String>(difficultyLevel);
    json['createdAt'] = createdAt.toJson();
    if (thumbnailUrl != null) {
      json['thumbnailUrl'] = nativeToJson<String?>(thumbnailUrl);
    }
    if (instructor != null) {
      json['instructor'] = instructor!.toJson();
    }
    return json;
  }

  GetCourseCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficultyLevel,
    required this.createdAt,
    this.thumbnailUrl,
    this.instructor,
  });
}

@immutable
class GetCourseCourseInstructor {
  final String id;
  final String displayName;
  GetCourseCourseInstructor.fromJson(dynamic json):
  
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

    final GetCourseCourseInstructor otherTyped = other as GetCourseCourseInstructor;
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

  GetCourseCourseInstructor({
    required this.id,
    required this.displayName,
  });
}

@immutable
class GetCourseData {
  final GetCourseCourse? course;
  GetCourseData.fromJson(dynamic json):
  
  course = json['course'] == null ? null : GetCourseCourse.fromJson(json['course']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseData otherTyped = other as GetCourseData;
    return course == otherTyped.course;
    
  }
  @override
  int get hashCode => course.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (course != null) {
      json['course'] = course!.toJson();
    }
    return json;
  }

  GetCourseData({
    this.course,
  });
}

@immutable
class GetCourseVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetCourseVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetCourseVariables otherTyped = other as GetCourseVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  GetCourseVariables({
    required this.id,
  });
}

