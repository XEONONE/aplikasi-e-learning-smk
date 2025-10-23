part of 'generated.dart';

class CreateCourseVariablesBuilder {
  String title;
  String description;
  String category;
  String difficultyLevel;
  Optional<String> _thumbnailUrl = Optional.optional(nativeFromJson, nativeToJson);
  String instructor;

  final FirebaseDataConnect _dataConnect;  CreateCourseVariablesBuilder thumbnailUrl(String? t) {
   _thumbnailUrl.value = t;
   return this;
  }

  CreateCourseVariablesBuilder(this._dataConnect, {required  this.title,required  this.description,required  this.category,required  this.difficultyLevel,required  this.instructor,});
  Deserializer<CreateCourseData> dataDeserializer = (dynamic json)  => CreateCourseData.fromJson(jsonDecode(json));
  Serializer<CreateCourseVariables> varsSerializer = (CreateCourseVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateCourseData, CreateCourseVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateCourseData, CreateCourseVariables> ref() {
    CreateCourseVariables vars= CreateCourseVariables(title: title,description: description,category: category,difficultyLevel: difficultyLevel,thumbnailUrl: _thumbnailUrl,instructor: instructor,);
    return _dataConnect.mutation("createCourse", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateCourseCourseInsert {
  final String id;
  CreateCourseCourseInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateCourseCourseInsert otherTyped = other as CreateCourseCourseInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateCourseCourseInsert({
    required this.id,
  });
}

@immutable
class CreateCourseData {
  final CreateCourseCourseInsert course_insert;
  CreateCourseData.fromJson(dynamic json):
  
  course_insert = CreateCourseCourseInsert.fromJson(json['course_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateCourseData otherTyped = other as CreateCourseData;
    return course_insert == otherTyped.course_insert;
    
  }
  @override
  int get hashCode => course_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['course_insert'] = course_insert.toJson();
    return json;
  }

  CreateCourseData({
    required this.course_insert,
  });
}

@immutable
class CreateCourseVariables {
  final String title;
  final String description;
  final String category;
  final String difficultyLevel;
  late final Optional<String>thumbnailUrl;
  final String instructor;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateCourseVariables.fromJson(Map<String, dynamic> json):
  
  title = nativeFromJson<String>(json['title']),
  description = nativeFromJson<String>(json['description']),
  category = nativeFromJson<String>(json['category']),
  difficultyLevel = nativeFromJson<String>(json['difficultyLevel']),
  instructor = nativeFromJson<String>(json['instructor']) {
  
  
  
  
  
  
    thumbnailUrl = Optional.optional(nativeFromJson, nativeToJson);
    thumbnailUrl.value = json['thumbnailUrl'] == null ? null : nativeFromJson<String>(json['thumbnailUrl']);
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateCourseVariables otherTyped = other as CreateCourseVariables;
    return title == otherTyped.title && 
    description == otherTyped.description && 
    category == otherTyped.category && 
    difficultyLevel == otherTyped.difficultyLevel && 
    thumbnailUrl == otherTyped.thumbnailUrl && 
    instructor == otherTyped.instructor;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, description.hashCode, category.hashCode, difficultyLevel.hashCode, thumbnailUrl.hashCode, instructor.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['description'] = nativeToJson<String>(description);
    json['category'] = nativeToJson<String>(category);
    json['difficultyLevel'] = nativeToJson<String>(difficultyLevel);
    if(thumbnailUrl.state == OptionalState.set) {
      json['thumbnailUrl'] = thumbnailUrl.toJson();
    }
    json['instructor'] = nativeToJson<String>(instructor);
    return json;
  }

  CreateCourseVariables({
    required this.title,
    required this.description,
    required this.category,
    required this.difficultyLevel,
    required this.thumbnailUrl,
    required this.instructor,
  });
}

