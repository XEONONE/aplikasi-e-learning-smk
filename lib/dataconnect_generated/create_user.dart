part of 'generated.dart';

class CreateUserVariablesBuilder {
  String displayName;
  String email;
  String role;
  Optional<String> _photoUrl = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _major = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateUserVariablesBuilder photoUrl(String? t) {
   _photoUrl.value = t;
   return this;
  }
  CreateUserVariablesBuilder major(String? t) {
   _major.value = t;
   return this;
  }

  CreateUserVariablesBuilder(this._dataConnect, {required  this.displayName,required  this.email,required  this.role,});
  Deserializer<CreateUserData> dataDeserializer = (dynamic json)  => CreateUserData.fromJson(jsonDecode(json));
  Serializer<CreateUserVariables> varsSerializer = (CreateUserVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateUserData, CreateUserVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateUserData, CreateUserVariables> ref() {
    CreateUserVariables vars= CreateUserVariables(displayName: displayName,email: email,role: role,photoUrl: _photoUrl,major: _major,);
    return _dataConnect.mutation("createUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateUserUserInsert {
  final String id;
  CreateUserUserInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserUserInsert otherTyped = other as CreateUserUserInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateUserUserInsert({
    required this.id,
  });
}

@immutable
class CreateUserData {
  final CreateUserUserInsert user_insert;
  CreateUserData.fromJson(dynamic json):
  
  user_insert = CreateUserUserInsert.fromJson(json['user_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserData otherTyped = other as CreateUserData;
    return user_insert == otherTyped.user_insert;
    
  }
  @override
  int get hashCode => user_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_insert'] = user_insert.toJson();
    return json;
  }

  CreateUserData({
    required this.user_insert,
  });
}

@immutable
class CreateUserVariables {
  final String displayName;
  final String email;
  final String role;
  late final Optional<String>photoUrl;
  late final Optional<String>major;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateUserVariables.fromJson(Map<String, dynamic> json):
  
  displayName = nativeFromJson<String>(json['displayName']),
  email = nativeFromJson<String>(json['email']),
  role = nativeFromJson<String>(json['role']) {
  
  
  
  
  
    photoUrl = Optional.optional(nativeFromJson, nativeToJson);
    photoUrl.value = json['photoUrl'] == null ? null : nativeFromJson<String>(json['photoUrl']);
  
  
    major = Optional.optional(nativeFromJson, nativeToJson);
    major.value = json['major'] == null ? null : nativeFromJson<String>(json['major']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserVariables otherTyped = other as CreateUserVariables;
    return displayName == otherTyped.displayName && 
    email == otherTyped.email && 
    role == otherTyped.role && 
    photoUrl == otherTyped.photoUrl && 
    major == otherTyped.major;
    
  }
  @override
  int get hashCode => Object.hashAll([displayName.hashCode, email.hashCode, role.hashCode, photoUrl.hashCode, major.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['displayName'] = nativeToJson<String>(displayName);
    json['email'] = nativeToJson<String>(email);
    json['role'] = nativeToJson<String>(role);
    if(photoUrl.state == OptionalState.set) {
      json['photoUrl'] = photoUrl.toJson();
    }
    if(major.state == OptionalState.set) {
      json['major'] = major.toJson();
    }
    return json;
  }

  CreateUserVariables({
    required this.displayName,
    required this.email,
    required this.role,
    required this.photoUrl,
    required this.major,
  });
}

