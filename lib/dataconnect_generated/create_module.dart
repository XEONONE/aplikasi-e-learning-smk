part of 'generated.dart';

class CreateModuleVariablesBuilder {
  String title;
  String description;
  int orderIndex;
  String course;

  final FirebaseDataConnect _dataConnect;
  CreateModuleVariablesBuilder(this._dataConnect, {required  this.title,required  this.description,required  this.orderIndex,required  this.course,});
  Deserializer<CreateModuleData> dataDeserializer = (dynamic json)  => CreateModuleData.fromJson(jsonDecode(json));
  Serializer<CreateModuleVariables> varsSerializer = (CreateModuleVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateModuleData, CreateModuleVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateModuleData, CreateModuleVariables> ref() {
    CreateModuleVariables vars= CreateModuleVariables(title: title,description: description,orderIndex: orderIndex,course: course,);
    return _dataConnect.mutation("createModule", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateModuleModuleInsert {
  final String id;
  CreateModuleModuleInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateModuleModuleInsert otherTyped = other as CreateModuleModuleInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateModuleModuleInsert({
    required this.id,
  });
}

@immutable
class CreateModuleData {
  final CreateModuleModuleInsert module_insert;
  CreateModuleData.fromJson(dynamic json):
  
  module_insert = CreateModuleModuleInsert.fromJson(json['module_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateModuleData otherTyped = other as CreateModuleData;
    return module_insert == otherTyped.module_insert;
    
  }
  @override
  int get hashCode => module_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['module_insert'] = module_insert.toJson();
    return json;
  }

  CreateModuleData({
    required this.module_insert,
  });
}

@immutable
class CreateModuleVariables {
  final String title;
  final String description;
  final int orderIndex;
  final String course;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateModuleVariables.fromJson(Map<String, dynamic> json):
  
  title = nativeFromJson<String>(json['title']),
  description = nativeFromJson<String>(json['description']),
  orderIndex = nativeFromJson<int>(json['orderIndex']),
  course = nativeFromJson<String>(json['course']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateModuleVariables otherTyped = other as CreateModuleVariables;
    return title == otherTyped.title && 
    description == otherTyped.description && 
    orderIndex == otherTyped.orderIndex && 
    course == otherTyped.course;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, description.hashCode, orderIndex.hashCode, course.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['description'] = nativeToJson<String>(description);
    json['orderIndex'] = nativeToJson<int>(orderIndex);
    json['course'] = nativeToJson<String>(course);
    return json;
  }

  CreateModuleVariables({
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.course,
  });
}

