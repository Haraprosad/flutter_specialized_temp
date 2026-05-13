import 'dart:io';

/// Reads a JSON fixture file from `test/fixtures/`.
String readFixture(String name) =>
    File('test/fixtures/$name').readAsStringSync();
