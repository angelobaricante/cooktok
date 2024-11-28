import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktok/controllers/auth_controller.dart';
import 'package:cooktok/views/screens/add_video_screen.dart';
import 'package:cooktok/views/screens/profile_screen.dart';
import 'package:cooktok/views/screens/save_recipe_screen.dart';
import 'package:cooktok/views/screens/search_screen.dart';
import 'package:cooktok/views/screens/video_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<Widget> pages = [
  VideoScreen(),
  SearchScreen(),
  const AddVideoScreen(),
  const SavedRecipesScreen(),
  ProfileScreen(uid: authController.user.uid),
];

//COLORS
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// FIREBASE
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLER
var authController = AuthController.instance;

// Function to get the current user's profile screen
Widget getCurrentUserProfileScreen() {
  return ProfileScreen(uid: Get.find<AuthController>().user.uid);
}
