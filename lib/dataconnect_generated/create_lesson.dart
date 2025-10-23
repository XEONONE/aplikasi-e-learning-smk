part of 'generated.dart';

class CreateLessonVariablesBuilder {
  String title;
  String type;
  String contentUrl;
  int orderIndex;
  Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);
  Optional<int> _duration = Optional.optional(nativeFromJson, nativeToJson);
  String module;

  final FirebaseDataConnect _dataConnect;  CreateLessonVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }
  CreateLessonVariablesBuilder duration(int? t) {
   _duration.value = t;
   return this;
  }

  CreateLessonVariablesBuilder(this._dataConnect, {required  this.title,required  this.type,required  this.contentUrl,required  this.orderIndex,required  this.module,});
  Deserializer<CreateLessonData> dataDeserializer = (dynamic json)  => CreateLessonData.fromJson(jsonDecode(json));
  Serializer<CreateLessonVariables> varsSerializer = (CreateLessonVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateLessonData, CreateLessonVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateLessonData, CreateLessonVariables> ref() {
    CreateLessonVariables vars= CreateLessonVariables(title: title,type: type,contentUrl: contentUrl,orderIndex: orderIndex,description: _description,duration: _duration,module: module,);
    return _dataConnect.mutation("createLesson", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateLessonLessonInsert {
  final String id;
  CreateLessonLessonInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateLessonLessonInsert otherTyped = other as CreateLessonLessonInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateLessonLessonInsert({
    required this.id,
  });
}

@immutable
class CreateLessonData {
  final CreateLessonLessonInsert lesson_insert;
  CreateLessonData.fromJson(dynamic json):
  
  lesson_insert = CreateLessonLessonInsert.fromJson(json['lesson_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateLessonData otherTyped = other as CreateLessonData;
    return lesson_insert == otherTyped.lesson_insert;
    
  }
  @override
  int get hashCode => lesson_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['lesson_insert'] = lesson_insert.toJson();
    return json;
  }

  CreateLessonData({
    required this.lesson_insert,
  });
}

@immutable
class CreateLessonVariables {
  final String title;
  final String type;
  final String contentUrl;
  final int orderIndex;
  late final Optional<String>description;
  late final Optional<int>duration;
  final String module;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateLessonVariables.fromJson(Map<String, dynamic> json):
  
  title = nativeFromJson<String>(json['title']),
  type = nativeFromJson<String>(json['type']),
  contentUrl = nativeFromJson<String>(json['contentUrl']),
  orderIndex = nativeFromJson<int>(json['orderIndex']),
  module = nativeFromJson<String>(json['module']) {
  
  
  
  
  
  
    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  
  
    duration = Optional.optional(nativeFromJson, nativeToJson);
    duration.value = json['duration'] == null ? null : nativeFromJson<int>(json['duration']);
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateLessonVariables otherTyped = other as CreateLessonVariables;
    return title == otherTyped.title && 
    type == otherTyped.type && 
    contentUrl == otherTyped.contentUrl && 
    orderIndex == otherTyped.orderIndex && 
    description == otherTyped.description && 
    duration == otherTyped.duration && 
    module == otherTyped.module;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, type.hashCode, contentUrl.hashCode, orderIndex.hashCode, description.hashCode, duration.hashCode, module.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['type'] = nativeToJson<String>(type);
    json['contentUrl'] = nativeToJson<String>(contentUrl);
    json['orderIndex'] = nativeToJson<int>(orderIndex);
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    if(duration.state == OptionalState.set) {
      json['duration'] = duration.toJson();
    }
    json['module'] = nativeToJson<String>(module);
    return json;
  }

  CreateLessonVariables({
    required this.title,
    required this.type,
    required this.contentUrl,
    required this.orderIndex,
    required this.description,
    required this.duration,
    required this.module,
  });
}

