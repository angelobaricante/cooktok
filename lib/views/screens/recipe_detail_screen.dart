import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final String recipeTitle = recipe['recipeTitle'] ?? 'No Title';
    final String recipeContent = recipe['recipeContent'] ?? 'No Content';

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(recipeContent),
      ),
    );
  }
}
