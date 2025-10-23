part of 'generated.dart';

class ListCoursesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListCoursesVariablesBuilder(this._dataConnect, );
  Deserializer<ListCoursesData> dataDeserializer = (dynamic json)  => ListCoursesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListCoursesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListCoursesData, void> ref() {
    
    return _dataConnect.query("listCourses", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListCoursesCourses {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficultyLevel;
  final Timestamp createdAt;
  final String? thumbnailUrl;
  final ListCoursesCoursesInstructor? instructor;
  ListCoursesCourses.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  description = nativeFromJson<String>(json['description']),
  category = nativeFromJson<String>(json['category']),
  difficultyLevel = nativeFromJson<String>(json['difficultyLevel']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  thumbnailUrl = json['thumbnailUrl'] == null ? null : nativeFromJson<String>(json['thumbnailUrl']),
  instructor = json['instructor'] == null ? null : ListCoursesCoursesInstructor.fromJson(json['instructor']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListCoursesCourses otherTyped = other as ListCoursesCourses;
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

  ListCoursesCourses({
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
class ListCoursesCoursesInstructor {
  final String id;
  final String displayName;
  ListCoursesCoursesInstructor.fromJson(dynamic json):
  
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

    final ListCoursesCoursesInstructor otherTyped = other as ListCoursesCoursesInstructor;
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

  ListCoursesCoursesInstructor({
    required this.id,
    required this.displayName,
  });
}

@immutable
class ListCoursesData {
  final List<ListCoursesCourses> courses;
  ListCoursesData.fromJson(dynamic json):
  
  courses = (json['courses'] as List<dynamic>)
        .map((e) => ListCoursesCourses.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListCoursesData otherTyped = other as ListCoursesData;
    return courses == otherTyped.courses;
    
  }
  @override
  int get hashCode => courses.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['courses'] = courses.map((e) => e.toJson()).toList();
    return json;
  }

  ListCoursesData({
    required this.courses,
  });
}

