part of 'generated.dart';

class ListModulesVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListModulesVariablesBuilder(this._dataConnect, );
  Deserializer<ListModulesData> dataDeserializer = (dynamic json)  => ListModulesData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListModulesData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListModulesData, void> ref() {
    
    return _dataConnect.query("listModules", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListModulesModules {
  final String id;
  final String title;
  final String description;
  final int orderIndex;
  final ListModulesModulesCourse? course;
  ListModulesModules.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  description = nativeFromJson<String>(json['description']),
  orderIndex = nativeFromJson<int>(json['orderIndex']),
  course = json['course'] == null ? null : ListModulesModulesCourse.fromJson(json['course']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListModulesModules otherTyped = other as ListModulesModules;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    description == otherTyped.description && 
    orderIndex == otherTyped.orderIndex && 
    course == otherTyped.course;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, description.hashCode, orderIndex.hashCode, course.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['description'] = nativeToJson<String>(description);
    json['orderIndex'] = nativeToJson<int>(orderIndex);
    if (course != null) {
      json['course'] = course!.toJson();
    }
    return json;
  }

  ListModulesModules({
    required this.id,
    required this.title,
    required this.description,
    required this.orderIndex,
    this.course,
  });
}

@immutable
class ListModulesModulesCourse {
  final String id;
  final String title;
  ListModulesModulesCourse.fromJson(dynamic json):
  
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

    final ListModulesModulesCourse otherTyped = other as ListModulesModulesCourse;
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

  ListModulesModulesCourse({
    required this.id,
    required this.title,
  });
}

@immutable
class ListModulesData {
  final List<ListModulesModules> modules;
  ListModulesData.fromJson(dynamic json):
  
  modules = (json['modules'] as List<dynamic>)
        .map((e) => ListModulesModules.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListModulesData otherTyped = other as ListModulesData;
    return modules == otherTyped.modules;
    
  }
  @override
  int get hashCode => modules.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['modules'] = modules.map((e) => e.toJson()).toList();
    return json;
  }

  ListModulesData({
    required this.modules,
  });
}

