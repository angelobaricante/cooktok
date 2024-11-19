import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cooktok/controllers/profile_controller.dart';

class RecipeScreen extends StatelessWidget {
  final String recipeTitle;
  final String recipeContent;
  final String recipeId;

  const RecipeScreen({
    Key? key,
    required this.recipeTitle,
    required this.recipeContent,
    required this.recipeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find();
    final isSaved = profileController.isRecipeSaved(recipeId).obs;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and favorite button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recipeTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  Obx(() => IconButton(
                        icon: Icon(
                          isSaved.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          if (isSaved.value) {
                            profileController.removeRecipe(recipeId);
                          } else {
                            profileController.saveRecipe(
                                recipeId, recipeTitle, recipeContent);
                          }
                          isSaved.value = !isSaved.value;
                        },
                      )),
                ],
              ),
            ),
            // Recipe content
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  recipeContent,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
