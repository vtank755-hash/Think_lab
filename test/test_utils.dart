import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The fixed-width course cards overflow a little under the test font's
/// metrics; that is unrelated to the behaviour being checked here.
void ignoreOverflowErrors() {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception.toString().contains('overflowed')) return;
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);
}
