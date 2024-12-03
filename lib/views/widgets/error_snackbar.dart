import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: Colors.red,
    action: SnackBarAction(
      label: 'Dismiss',
      textColor: Colors.white,
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
