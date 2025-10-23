part of 'generated.dart';

class ListLessonsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListLessonsVariablesBuilder(this._dataConnect, );
  Deserializer<ListLessonsData> dataDeserializer = (dynamic json)  => ListLessonsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListLessonsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListLessonsData, void> ref() {
    
    return _dataConnect.query("listLessons", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListLessonsLessons {
  final String id;
  final String title;
  final String type;
  final String contentUrl;
  final int orderIndex;
  final String? description;
  final int? duration;
  final ListLessonsLessonsModule? module;
  ListLessonsLessons.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  type = nativeFromJson<String>(json['type']),
  contentUrl = nativeFromJson<String>(json['contentUrl']),
  orderIndex = nativeFromJson<int>(json['orderIndex']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  duration = json['duration'] == null ? null : nativeFromJson<int>(json['duration']),
  module = json['module'] == null ? null : ListLessonsLessonsModule.fromJson(json['module']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListLessonsLessons otherTyped = other as ListLessonsLessons;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    type == otherTyped.type && 
    contentUrl == otherTyped.contentUrl && 
    orderIndex == otherTyped.orderIndex && 
    description == otherTyped.description && 
    duration == otherTyped.duration && 
    module == otherTyped.module;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, type.hashCode, contentUrl.hashCode, orderIndex.hashCode, description.hashCode, duration.hashCode, module.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['type'] = nativeToJson<String>(type);
    json['contentUrl'] = nativeToJson<String>(contentUrl);
    json['orderIndex'] = nativeToJson<int>(orderIndex);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    if (duration != null) {
      json['duration'] = nativeToJson<int?>(duration);
    }
    if (module != null) {
      json['module'] = module!.toJson();
    }
    return json;
  }

  ListLessonsLessons({
    required this.id,
    required this.title,
    required this.type,
    required this.contentUrl,
    required this.orderIndex,
    this.description,
    this.duration,
    this.module,
  });
}

@immutable
class ListLessonsLessonsModule {
  final String id;
  final String title;
  ListLessonsLessonsModule.fromJson(dynamic json):
  
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

    final ListLessonsLessonsModule otherTyped = other as ListLessonsLessonsModule;
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

  ListLessonsLessonsModule({
    required this.id,
    required this.title,
  });
}

@immutable
class ListLessonsData {
  final List<ListLessonsLessons> lessons;
  ListLessonsData.fromJson(dynamic json):
  
  lessons = (json['lessons'] as List<dynamic>)
        .map((e) => ListLessonsLessons.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListLessonsData otherTyped = other as ListLessonsData;
    return lessons == otherTyped.lessons;
    
  }
  @override
  int get hashCode => lessons.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['lessons'] = lessons.map((e) => e.toJson()).toList();
    return json;
  }

  ListLessonsData({
    required this.lessons,
  });
}

