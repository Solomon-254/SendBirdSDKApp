import 'package:flutter/material.dart';

typedef StringFunction = Function(String);
typedef DynamicFunction = Function(dynamic);

void _showErrorSnackbar(BuildContext context, String message) {
  var snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(color: Colors.white),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void _dismissKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

extension WidgetUtil on Widget {
  void dismissKeyboard() => _dismissKeyboard();

  void showSnackbar(BuildContext context, String message) =>
      _showErrorSnackbar(context, message);
}

extension StateUtil on State {
  void dismissKeyboard() => _dismissKeyboard();

  void showSnackbar(BuildContext context, String message) =>
      _showErrorSnackbar(context, message);
}

int timeStamp() {
  return DateTime.timestamp().millisecondsSinceEpoch;
}
