// lib/widgets/recipe_popup.dart
import 'package:flutter/material.dart';

class RecipeScreen extends StatelessWidget {
  final String recipeTitle;
  final String recipeContent;

  const RecipeScreen({
    Key? key,
    required this.recipeTitle,
    required this.recipeContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(recipeTitle),
      content: SingleChildScrollView(
        child: Text(recipeContent),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
