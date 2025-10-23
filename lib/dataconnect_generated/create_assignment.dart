part of 'generated.dart';

class CreateAssignmentVariablesBuilder {
  String title;
  String description;
  String type;
  DateTime dueDate;
  int maxScore;
  String module;

  final FirebaseDataConnect _dataConnect;
  CreateAssignmentVariablesBuilder(this._dataConnect, {required  this.title,required  this.description,required  this.type,required  this.dueDate,required  this.maxScore,required  this.module,});
  Deserializer<CreateAssignmentData> dataDeserializer = (dynamic json)  => CreateAssignmentData.fromJson(jsonDecode(json));
  Serializer<CreateAssignmentVariables> varsSerializer = (CreateAssignmentVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateAssignmentData, CreateAssignmentVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateAssignmentData, CreateAssignmentVariables> ref() {
    CreateAssignmentVariables vars= CreateAssignmentVariables(title: title,description: description,type: type,dueDate: dueDate,maxScore: maxScore,module: module,);
    return _dataConnect.mutation("createAssignment", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateAssignmentAssignmentInsert {
  final String id;
  CreateAssignmentAssignmentInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateAssignmentAssignmentInsert otherTyped = other as CreateAssignmentAssignmentInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateAssignmentAssignmentInsert({
    required this.id,
  });
}

@immutable
class CreateAssignmentData {
  final CreateAssignmentAssignmentInsert assignment_insert;
  CreateAssignmentData.fromJson(dynamic json):
  
  assignment_insert = CreateAssignmentAssignmentInsert.fromJson(json['assignment_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateAssignmentData otherTyped = other as CreateAssignmentData;
    return assignment_insert == otherTyped.assignment_insert;
    
  }
  @override
  int get hashCode => assignment_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['assignment_insert'] = assignment_insert.toJson();
    return json;
  }

  CreateAssignmentData({
    required this.assignment_insert,
  });
}

@immutable
class CreateAssignmentVariables {
  final String title;
  final String description;
  final String type;
  final DateTime dueDate;
  final int maxScore;
  final String module;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateAssignmentVariables.fromJson(Map<String, dynamic> json):
  
  title = nativeFromJson<String>(json['title']),
  description = nativeFromJson<String>(json['description']),
  type = nativeFromJson<String>(json['type']),
  dueDate = nativeFromJson<DateTime>(json['dueDate']),
  maxScore = nativeFromJson<int>(json['maxScore']),
  module = nativeFromJson<String>(json['module']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateAssignmentVariables otherTyped = other as CreateAssignmentVariables;
    return title == otherTyped.title && 
    description == otherTyped.description && 
    type == otherTyped.type && 
    dueDate == otherTyped.dueDate && 
    maxScore == otherTyped.maxScore && 
    module == otherTyped.module;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, description.hashCode, type.hashCode, dueDate.hashCode, maxScore.hashCode, module.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    json['description'] = nativeToJson<String>(description);
    json['type'] = nativeToJson<String>(type);
    json['dueDate'] = nativeToJson<DateTime>(dueDate);
    json['maxScore'] = nativeToJson<int>(maxScore);
    json['module'] = nativeToJson<String>(module);
    return json;
  }

  CreateAssignmentVariables({
    required this.title,
    required this.description,
    required this.type,
    required this.dueDate,
    required this.maxScore,
    required this.module,
  });
}

