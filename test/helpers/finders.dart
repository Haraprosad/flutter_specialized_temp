import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds a [Text] widget whose data contains [substring].
Finder findTextContaining(String substring) => find.byWidgetPredicate(
  (widget) => widget is Text && (widget.data?.contains(substring) ?? false),
);

/// Finds the first [ElevatedButton] in the tree.
Finder findElevatedButton() => find.byType(ElevatedButton);

/// Finds a widget by its key string value.
Finder findByKeyString(String key) => find.byKey(Key(key));

/// Finds all [TextFormField] widgets.
Finder findTextFormFields() => find.byType(TextFormField);

/// Finds a [CircularProgressIndicator].
Finder findLoadingIndicator() => find.byType(CircularProgressIndicator);
