import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktok/constants.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> user = Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> savedRecipes =
      <Map<String, dynamic>>[].obs;
  Map<String, dynamic> get getUser => user.value;

  Rx<String> uid = "".obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String _userId =
      'someUserId'; // Replace with actual logic to get userId

  String get currentUserId => _userId;

  updateUserId(String id) {
    uid.value = id;
    getUserData();
  }

  getUserData() async {
    List<String> thumbnails = [];
    List<String> videoUrls = [];

    var myVideos = await firestore
        .collection('videos')
        .where('uid', isEqualTo: uid.value)
        .get();
    for (int i = 0; i < myVideos.docs.length; i++) {
      var videoData = myVideos.docs[i].data() as dynamic;
      thumbnails.add(videoData['thumbnail']);
      videoUrls.add(videoData['videoUrl']);
    }

    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(uid.value).get();
    final userData = userDoc.data()! as dynamic;
    String name = userData['name'];
    String profilePhoto = userData['profilePhoto'];
    int likes = 0;

    for (var item in myVideos.docs) {
      likes += (item.data()['likes'] as List).length;
    }

    var followerDoc = await firestore
        .collection('users')
        .doc(uid.value)
        .collection('followers')
        .get();
    var followingDoc = await firestore
        .collection('users')
        .doc(uid.value)
        .collection('following')
        .get();
    int followers = followerDoc.docs.length;
    int following = followingDoc.docs.length;

    bool isFollowing = (await firestore
            .collection('users')
            .doc(uid.value)
            .collection('followers')
            .doc(authController.user.uid)
            .get())
        .exists;

    user.value = {
      'followers': followers.toString(),
      'following': following.toString(),
      'isFollowing': isFollowing,
      'likes': likes.toString(),
      'profilePhoto': profilePhoto,
      'name': name,
      'thumbnails': thumbnails,
      'videoUrls': videoUrls,
    };
    update();
  }

  followUser() async {
    final currentUserId = authController.user.uid;
    final targetUserId = uid.value;

    var doc = await firestore
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUserId)
        .get();

    if (!doc.exists) {
      await firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .set({});
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .set({});
      user.value
          .update('followers', (value) => (int.parse(value) + 1).toString());
    } else {
      await firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(currentUserId)
          .delete();
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .delete();
      user.value
          .update('followers', (value) => (int.parse(value) - 1).toString());
    }

    user.value.update('isFollowing', (value) => !value);
    update();
  }

  List<String> getUserVideos() {
    return user.value['videoUrls'] ?? [];
  }

  void saveRecipe(
      String recipeId, String recipeTitle, String recipeContent) async {
    final currentUserId = authController.user.uid;
    final recipeDoc = firestore
        .collection('users')
        .doc(currentUserId)
        .collection('savedRecipes')
        .doc(recipeId);

    print('Saving recipe for user: $currentUserId, recipeId: $recipeId');

    var doc = await recipeDoc.get();
    if (!doc.exists) {
      await recipeDoc.set({
        'savedAt': FieldValue.serverTimestamp(),
        'recipeTitle': recipeTitle,
        'recipeContent': recipeContent,
        'recipeId': recipeId,
      });
      print('Recipe saved successfully');
      fetchSavedRecipes();
    } else {
      print('Recipe already saved');
    }
  }

  void fetchSavedRecipes() async {
    try {
      final currentUserId = authController.user.uid;
      print('Fetching saved recipes for user: $currentUserId');
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('savedRecipes')
          .get();

      savedRecipes.assignAll(snapshot.docs.map((doc) => doc.data()).toList());

      // Extract and print recipeTitle and recipeContent
      for (var recipe in savedRecipes) {
        final recipeTitle = recipe['recipeTitle'] ?? 'No Title';
        final recipeContent = recipe['recipeContent'] ?? 'No Content';
        print('Recipe Title: $recipeTitle, Recipe Content: $recipeContent');
      }
    } catch (e) {
      print('Error fetching saved recipes: $e');
    }
  }

  bool isRecipeSaved(String recipeId) {
    return savedRecipes.any((recipe) => recipe['recipeId'] == recipeId);
  }

  void removeRecipe(String recipeId) async {
    final currentUserId = authController.user.uid;
    final recipeDoc = firestore
        .collection('users')
        .doc(currentUserId)
        .collection('savedRecipes')
        .doc(recipeId);

    print('Removing recipe for user: $currentUserId, recipeId: $recipeId');

    await recipeDoc.delete();
    print('Recipe removed successfully');
    fetchSavedRecipes();
  }
}
