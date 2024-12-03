import 'dart:io';
import 'package:cooktok/constants.dart';
import 'package:cooktok/views/screens/auth/login_screen.dart';
import 'package:cooktok/views/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cooktok/models/user.dart' as model;
import 'package:image_picker/image_picker.dart';
import 'package:cooktok/controllers/profile_controller.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  late Rx<File?> _pickedImage = Rx<File?>(null);

  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
      // Update the profile controller with the new user ID
      Get.find<ProfileController>().updateUserId(user.uid);
    }
  }

  Future<String?> pickImage() async {
    final pickedImageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImageFile != null) {
      _pickedImage.value = File(pickedImageFile.path);
      Get.snackbar('Profile Picture',
          'You have successfully selected your profile picture!');
      return pickedImageFile.path;
    }
    return null;
  }

  Future<String> _uploadToStorage(File image) async {
    Reference ref = firebaseStorage
        .ref()
        .child('profilePics')
        .child(firebaseAuth.currentUser!.uid);

    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl,
        );

        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar(
          'Registration Failed',
          'Please fill in all fields and select a profile picture',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;
        case 'weak-password':
          message = 'Password should be at least 6 characters long';
          break;
        default:
          message = 'Failed to create account. Please try again';
      }
      Get.snackbar(
        'Registration Failed',
        message,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // First authenticate with Firebase Auth
        UserCredential userCred = await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);

        // Then verify if user exists in Firestore
        var userDoc =
            await firestore.collection('users').doc(userCred.user!.uid).get();
        if (!userDoc.exists) {
          await firebaseAuth.signOut();
          Get.snackbar(
            'Account Not Found',
            'No account found with these credentials. Please register first.',
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
          );
          return;
        }
      } else {
        Get.snackbar(
          'Login Failed',
          'Please fill in both email and password',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}'); // Debug log
      print('Firebase Auth Error Message: ${e.message}'); // Debug log

      if (e.code == 'invalid-email') {
        Get.snackbar(
          'Login Failed',
          'Please enter a valid email address',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      } else if (e.code == 'user-disabled') {
        Get.snackbar(
          'Login Failed',
          'This account has been disabled',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      } else if (e.code == 'too-many-requests') {
        Get.snackbar(
          'Login Failed',
          'Too many failed attempts. Please try again later',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      } else {
        // For wrong-password, user-not-found, and other credential errors
        Get.snackbar(
          'Login Failed',
          'Invalid login details. Please check your email and password',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      print('Unexpected Error: $e'); // Debug log
      Get.snackbar(
        'Login Failed',
        'An unexpected error occurred',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      User? currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        // Delete user data from Firestore
        await firestore.collection('users').doc(currentUser.uid).delete();

        // Delete user's videos
        var videosQuery = await firestore
            .collection('videos')
            .where('uid', isEqualTo: currentUser.uid)
            .get();
        for (var doc in videosQuery.docs) {
          await doc.reference.delete();
        }

        // Delete user's authentication account
        await currentUser.delete();

        // Sign out the user
        await signOut();

        Get.snackbar(
          'Success',
          'Your account has been successfully deleted',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAll(() => LoginScreen());
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      switch (e.code) {
        case 'requires-recent-login':
          message = 'Please log in again before deleting your account';
          break;
        default:
          message = 'Failed to delete account. Please try again';
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
