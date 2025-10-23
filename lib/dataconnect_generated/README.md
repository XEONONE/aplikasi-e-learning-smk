# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### listUsers
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listUsers().execute();
```



#### Return Type
`execute()` returns a `QueryResult<listUsersData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listUsers();
listUsersData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listUsers().ref();
ref.execute();

ref.subscribe(...);
```


### getUser
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getUser(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<getUserData, getUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getUser(
  id: id,
);
getUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getUser(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### listCourses
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listCourses().execute();
```



#### Return Type
`execute()` returns a `QueryResult<listCoursesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listCourses();
listCoursesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listCourses().ref();
ref.execute();

ref.subscribe(...);
```


### getCourse
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getCourse(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<getCourseData, getCourseVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getCourse(
  id: id,
);
getCourseData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getCourse(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### listEnrollments
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listEnrollments().execute();
```



#### Return Type
`execute()` returns a `QueryResult<listEnrollmentsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listEnrollments();
listEnrollmentsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listEnrollments().ref();
ref.execute();

ref.subscribe(...);
```


### listModules
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listModules().execute();
```



#### Return Type
`execute()` returns a `QueryResult<listModulesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listModules();
listModulesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listModules().ref();
ref.execute();

ref.subscribe(...);
```


### listLessons
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listLessons().execute();
```



#### Return Type
`execute()` returns a `QueryResult<listLessonsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listLessons();
listLessonsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listLessons().ref();
ref.execute();

ref.subscribe(...);
```


### listAssignments
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listAssignments().execute();
```



#### Return Type
`execute()` returns a `QueryResult<listAssignmentsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listAssignments();
listAssignmentsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listAssignments().ref();
ref.execute();

ref.subscribe(...);
```


### listSubmissions
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listSubmissions().execute();
```



#### Return Type
`execute()` returns a `QueryResult<listSubmissionsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listSubmissions();
listSubmissionsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listSubmissions().ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### createUser
#### Required Arguments
```dart
String displayName = ...;
String email = ...;
String role = ...;
ExampleConnector.instance.createUser(
  displayName: displayName,
  email: email,
  role: role,
).execute();
```

#### Optional Arguments
We return a builder for each query. For createUser, we created `createUserBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateUserVariablesBuilder {
  ...
   CreateUserVariablesBuilder photoUrl(String? t) {
   _photoUrl.value = t;
   return this;
  }
  CreateUserVariablesBuilder major(String? t) {
   _major.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createUser(
  displayName: displayName,
  email: email,
  role: role,
)
.photoUrl(photoUrl)
.major(major)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<createUserData, createUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createUser(
  displayName: displayName,
  email: email,
  role: role,
);
createUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String displayName = ...;
String email = ...;
String role = ...;

final ref = ExampleConnector.instance.createUser(
  displayName: displayName,
  email: email,
  role: role,
).ref();
ref.execute();
```


### createCourse
#### Required Arguments
```dart
String title = ...;
String description = ...;
String category = ...;
String difficultyLevel = ...;
String instructor = ...;
ExampleConnector.instance.createCourse(
  title: title,
  description: description,
  category: category,
  difficultyLevel: difficultyLevel,
  instructor: instructor,
).execute();
```

#### Optional Arguments
We return a builder for each query. For createCourse, we created `createCourseBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateCourseVariablesBuilder {
  ...
   CreateCourseVariablesBuilder thumbnailUrl(String? t) {
   _thumbnailUrl.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createCourse(
  title: title,
  description: description,
  category: category,
  difficultyLevel: difficultyLevel,
  instructor: instructor,
)
.thumbnailUrl(thumbnailUrl)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<createCourseData, createCourseVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createCourse(
  title: title,
  description: description,
  category: category,
  difficultyLevel: difficultyLevel,
  instructor: instructor,
);
createCourseData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String title = ...;
String description = ...;
String category = ...;
String difficultyLevel = ...;
String instructor = ...;

final ref = ExampleConnector.instance.createCourse(
  title: title,
  description: description,
  category: category,
  difficultyLevel: difficultyLevel,
  instructor: instructor,
).ref();
ref.execute();
```


### createEnrollment
#### Required Arguments
```dart
Timestamp enrollmentDate = ...;
String status = ...;
String student = ...;
String course = ...;
ExampleConnector.instance.createEnrollment(
  enrollmentDate: enrollmentDate,
  status: status,
  student: student,
  course: course,
).execute();
```

#### Optional Arguments
We return a builder for each query. For createEnrollment, we created `createEnrollmentBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateEnrollmentVariablesBuilder {
  ...
   CreateEnrollmentVariablesBuilder completionDate(Timestamp? t) {
   _completionDate.value = t;
   return this;
  }
  CreateEnrollmentVariablesBuilder grade(int? t) {
   _grade.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createEnrollment(
  enrollmentDate: enrollmentDate,
  status: status,
  student: student,
  course: course,
)
.completionDate(completionDate)
.grade(grade)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<createEnrollmentData, createEnrollmentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createEnrollment(
  enrollmentDate: enrollmentDate,
  status: status,
  student: student,
  course: course,
);
createEnrollmentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
Timestamp enrollmentDate = ...;
String status = ...;
String student = ...;
String course = ...;

final ref = ExampleConnector.instance.createEnrollment(
  enrollmentDate: enrollmentDate,
  status: status,
  student: student,
  course: course,
).ref();
ref.execute();
```


### createModule
#### Required Arguments
```dart
String title = ...;
String description = ...;
int orderIndex = ...;
String course = ...;
ExampleConnector.instance.createModule(
  title: title,
  description: description,
  orderIndex: orderIndex,
  course: course,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<createModuleData, createModuleVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createModule(
  title: title,
  description: description,
  orderIndex: orderIndex,
  course: course,
);
createModuleData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String title = ...;
String description = ...;
int orderIndex = ...;
String course = ...;

final ref = ExampleConnector.instance.createModule(
  title: title,
  description: description,
  orderIndex: orderIndex,
  course: course,
).ref();
ref.execute();
```


### createLesson
#### Required Arguments
```dart
String title = ...;
String type = ...;
String contentUrl = ...;
int orderIndex = ...;
String module = ...;
ExampleConnector.instance.createLesson(
  title: title,
  type: type,
  contentUrl: contentUrl,
  orderIndex: orderIndex,
  module: module,
).execute();
```

#### Optional Arguments
We return a builder for each query. For createLesson, we created `createLessonBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateLessonVariablesBuilder {
  ...
   CreateLessonVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }
  CreateLessonVariablesBuilder duration(int? t) {
   _duration.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createLesson(
  title: title,
  type: type,
  contentUrl: contentUrl,
  orderIndex: orderIndex,
  module: module,
)
.description(description)
.duration(duration)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<createLessonData, createLessonVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createLesson(
  title: title,
  type: type,
  contentUrl: contentUrl,
  orderIndex: orderIndex,
  module: module,
);
createLessonData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String title = ...;
String type = ...;
String contentUrl = ...;
int orderIndex = ...;
String module = ...;

final ref = ExampleConnector.instance.createLesson(
  title: title,
  type: type,
  contentUrl: contentUrl,
  orderIndex: orderIndex,
  module: module,
).ref();
ref.execute();
```


### createAssignment
#### Required Arguments
```dart
String title = ...;
String description = ...;
String type = ...;
DateTime dueDate = ...;
int maxScore = ...;
String module = ...;
ExampleConnector.instance.createAssignment(
  title: title,
  description: description,
  type: type,
  dueDate: dueDate,
  maxScore: maxScore,
  module: module,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<createAssignmentData, createAssignmentVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createAssignment(
  title: title,
  description: description,
  type: type,
  dueDate: dueDate,
  maxScore: maxScore,
  module: module,
);
createAssignmentData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String title = ...;
String description = ...;
String type = ...;
DateTime dueDate = ...;
int maxScore = ...;
String module = ...;

final ref = ExampleConnector.instance.createAssignment(
  title: title,
  description: description,
  type: type,
  dueDate: dueDate,
  maxScore: maxScore,
  module: module,
).ref();
ref.execute();
```


### createSubmission
#### Required Arguments
```dart
Timestamp submissionDate = ...;
int score = ...;
String student = ...;
String assignment = ...;
ExampleConnector.instance.createSubmission(
  submissionDate: submissionDate,
  score: score,
  student: student,
  assignment: assignment,
).execute();
```

#### Optional Arguments
We return a builder for each query. For createSubmission, we created `createSubmissionBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateSubmissionVariablesBuilder {
  ...
   CreateSubmissionVariablesBuilder studentResponse(String? t) {
   _studentResponse.value = t;
   return this;
  }
  CreateSubmissionVariablesBuilder feedback(String? t) {
   _feedback.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createSubmission(
  submissionDate: submissionDate,
  score: score,
  student: student,
  assignment: assignment,
)
.studentResponse(studentResponse)
.feedback(feedback)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<createSubmissionData, createSubmissionVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createSubmission(
  submissionDate: submissionDate,
  score: score,
  student: student,
  assignment: assignment,
);
createSubmissionData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
Timestamp submissionDate = ...;
int score = ...;
String student = ...;
String assignment = ...;

final ref = ExampleConnector.instance.createSubmission(
  submissionDate: submissionDate,
  score: score,
  student: student,
  assignment: assignment,
).ref();
ref.execute();
```

