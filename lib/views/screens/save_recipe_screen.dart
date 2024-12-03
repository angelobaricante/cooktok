import 'package:cooktok/views/screens/recipe_detail_screen.dart';
import 'package:cooktok/views/screens/recipe_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cooktok/controllers/profile_controller.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    profileController.fetchSavedRecipes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
      ),
      body: Obx(() {
        if (profileController.savedRecipes.isEmpty) {
          return const Center(
            child: Text('No saved recipes yet'),
          );
        }

        return ListView.builder(
          itemCount: profileController.savedRecipes.length,
          itemBuilder: (context, index) {
            final recipe = profileController.savedRecipes[index];
            return Card(
              child: ListTile(
                title: Text(recipe['recipeTitle'] ?? 'No Title'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RecipeScreen(
                        recipeTitle: recipe['recipeTitle'] ?? 'No Title',
                        recipeContent: recipe['recipeContent'] ?? 'No Content',
                        recipeId: recipe['recipeId'] ?? '',
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
