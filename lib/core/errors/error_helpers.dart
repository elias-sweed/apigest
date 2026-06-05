import 'package:flutter/material.dart';
import 'error_mapper.dart';

void showError(BuildContext context, Object error, {String? errorContext}) {
  final message = ErrorMapper.map(error, context: errorContext);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red[700],
    ),
  );
}

void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green[700],
    ),
  );
}
