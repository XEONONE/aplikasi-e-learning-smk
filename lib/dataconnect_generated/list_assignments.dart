part of 'generated.dart';

class ListAssignmentsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListAssignmentsVariablesBuilder(this._dataConnect, );
  Deserializer<ListAssignmentsData> dataDeserializer = (dynamic json)  => ListAssignmentsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListAssignmentsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListAssignmentsData, void> ref() {
    
    return _dataConnect.query("listAssignments", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListAssignmentsAssignments {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime dueDate;
  final int maxScore;
  final ListAssignmentsAssignmentsModule? module;
  ListAssignmentsAssignments.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  description = nativeFromJson<String>(json['description']),
  type = nativeFromJson<String>(json['type']),
  dueDate = nativeFromJson<DateTime>(json['dueDate']),
  maxScore = nativeFromJson<int>(json['maxScore']),
  module = json['module'] == null ? null : ListAssignmentsAssignmentsModule.fromJson(json['module']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAssignmentsAssignments otherTyped = other as ListAssignmentsAssignments;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    description == otherTyped.description && 
    type == otherTyped.type && 
    dueDate == otherTyped.dueDate && 
    maxScore == otherTyped.maxScore && 
    module == otherTyped.module;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, description.hashCode, type.hashCode, dueDate.hashCode, maxScore.hashCode, module.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['description'] = nativeToJson<String>(description);
    json['type'] = nativeToJson<String>(type);
    json['dueDate'] = nativeToJson<DateTime>(dueDate);
    json['maxScore'] = nativeToJson<int>(maxScore);
    if (module != null) {
      json['module'] = module!.toJson();
    }
    return json;
  }

  ListAssignmentsAssignments({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.dueDate,
    required this.maxScore,
    this.module,
  });
}

@immutable
class ListAssignmentsAssignmentsModule {
  final String id;
  final String title;
  ListAssignmentsAssignmentsModule.fromJson(dynamic json):
  
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

    final ListAssignmentsAssignmentsModule otherTyped = other as ListAssignmentsAssignmentsModule;
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

  ListAssignmentsAssignmentsModule({
    required this.id,
    required this.title,
  });
}

@immutable
class ListAssignmentsData {
  final List<ListAssignmentsAssignments> assignments;
  ListAssignmentsData.fromJson(dynamic json):
  
  assignments = (json['assignments'] as List<dynamic>)
        .map((e) => ListAssignmentsAssignments.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAssignmentsData otherTyped = other as ListAssignmentsData;
    return assignments == otherTyped.assignments;
    
  }
  @override
  int get hashCode => assignments.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['assignments'] = assignments.map((e) => e.toJson()).toList();
    return json;
  }

  ListAssignmentsData({
    required this.assignments,
  });
}

