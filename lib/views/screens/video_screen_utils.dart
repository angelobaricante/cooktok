// lib/utils/video_screen_utils.dart
import 'package:flutter/material.dart';
import 'package:cooktok/views/screens/profile_screen.dart';
import 'package:cooktok/views/screens/comment_screen.dart';
import 'package:cooktok/views/widgets/circle_animation.dart';
import 'package:cooktok/controllers/video_controller.dart';
import 'package:cooktok/constants.dart';
import 'package:cooktok/views/screens/recipe_screen.dart';

class VideoScreenUtils {
  static Widget buildProfile(
      String profilePhoto, String userId, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(uid: userId),
          ),
        );
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          children: [
            Positioned(
              left: 5,
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image(
                    image: NetworkImage(profilePhoto),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget buildMusicAlbum(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.grey,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(profilePhoto),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildVideoActions(
      dynamic data, VideoController videoController, BuildContext context) {
    return Column(
      children: [
        buildLikeButton(data, videoController),
        buildCommentButton(data, context),
        buildRecipeButton(data, context),
        CircleAnimation(
          child: buildMusicAlbum(data.profilePhoto),
        ),
      ],
    );
  }

  static Widget buildLikeButton(dynamic data, VideoController videoController) {
    return Column(
      children: [
        InkWell(
          onTap: () => videoController.likeVideo(data.id),
          child: Icon(
            Icons.favorite,
            size: 40,
            color: data.likes.contains(authController.user.uid)
                ? Colors.red
                : Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          data.likes.length.toString(),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static Widget buildCommentButton(dynamic data, BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommentScreen(
                id: data.id,
              ),
            ),
          ),
          child: const Icon(
            Icons.comment,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          data.commentCount.toString(),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static Widget buildRecipeButton(dynamic data, BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return RecipeScreen(
                  recipeTitle: data.recipeTitle,
                  recipeContent: data.recipeContent,
                );
              },
            );
          },
          child: const Icon(
            Icons.restaurant_menu,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Recipe',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
