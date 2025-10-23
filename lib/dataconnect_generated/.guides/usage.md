# Basic Usage

```dart
ExampleConnector.instance.createUser(createUserVariables).execute();
ExampleConnector.instance.createCourse(createCourseVariables).execute();
ExampleConnector.instance.createEnrollment(createEnrollmentVariables).execute();
ExampleConnector.instance.createModule(createModuleVariables).execute();
ExampleConnector.instance.createLesson(createLessonVariables).execute();
ExampleConnector.instance.createAssignment(createAssignmentVariables).execute();
ExampleConnector.instance.createSubmission(createSubmissionVariables).execute();
ExampleConnector.instance.listUsers().execute();
ExampleConnector.instance.getUser(getUserVariables).execute();
ExampleConnector.instance.listCourses().execute();

```

## Optional Fields

Some operations may have optional fields. In these cases, the Flutter SDK exposes a builder method, and will have to be set separately.

Optional fields can be discovered based on classes that have `Optional` object types.

This is an example of a mutation with an optional field:

```dart
await Example.instance.createSubmission({ ... })
.studentResponse(...)
.execute();
```

Note: the above example is a mutation, but the same logic applies to query operations as well. Additionally, `createMovie` is an example, and may not be available to the user.

