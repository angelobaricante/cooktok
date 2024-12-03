import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:cooktok/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> savedRecipes = <Map<String, dynamic>>[].obs;
  Map<String, dynamic> get user => _user.value;

  final Rx<String> _uid = "".obs;
  String get uid => _uid.value;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AuthController authController = Get.find<AuthController>();

  final RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _uid.listen((_) {
      getUserData();
    });
  }

  void updateUserId(String id) {
    _uid.value = id;
  }

  void refreshProfile() {
    updateUserId(authController.user.uid);
  }

  void resetProfile() {
    _user.value = {};
    savedRecipes.clear();
    _uid.value = "";
  }

  Future<void> getUserData() async {
    _isLoading.value = true;
    if (_uid.value.isEmpty) {
      _isLoading.value = false;
      return;
    }

    try {
      List<String> thumbnails = [];
      List<String> videoUrls = [];

      var myVideos = await firestore
          .collection('videos')
          .where('uid', isEqualTo: _uid.value)
          .get();
      for (int i = 0; i < myVideos.docs.length; i++) {
        var videoData = myVideos.docs[i].data() as dynamic;
        thumbnails.add(videoData['thumbnail']);
        videoUrls.add(videoData['videoUrl']);
      }

      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(_uid.value).get();
      final userData = userDoc.data()! as dynamic;
      String name = userData['name'];
      String profilePhoto = userData['profilePhoto'];
      int likes = 0;

      for (var item in myVideos.docs) {
        likes += (item.data()['likes'] as List).length;
      }

      var followerDoc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .get();
      var followingDoc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('following')
          .get();
      int followers = followerDoc.docs.length;
      int following = followingDoc.docs.length;

      bool isFollowing = (await firestore
              .collection('users')
              .doc(_uid.value)
              .collection('followers')
              .doc(authController.user.uid)
              .get())
          .exists;

      _user.value = {
        'followers': followers.toString(),
        'following': following.toString(),
        'isFollowing': isFollowing,
        'likes': likes.toString(),
        'profilePhoto': profilePhoto,
        'name': name,
        'thumbnails': thumbnails,
        'videoUrls': videoUrls,
      };
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      _isLoading.value = false;
    }
    update();
  }

  Future<void> followUser() async {
    final currentUserId = authController.user.uid;
    final targetUserId = _uid.value;

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
      _user.value
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
      _user.value
          .update('followers', (value) => (int.parse(value) - 1).toString());
    }

    _user.value.update('isFollowing', (value) => !value);
    update();
  }

  List<String> getUserVideos() {
    return _user.value['videoUrls'] ?? [];
  }

  Future<void> saveRecipe(
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
      await fetchSavedRecipes();
    } else {
      print('Recipe already saved');
    }
  }

  Future<void> fetchSavedRecipes() async {
    try {
      final currentUserId = authController.user.uid;
      print('Fetching saved recipes for user: $currentUserId');
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('savedRecipes')
          .get();

      savedRecipes.assignAll(snapshot.docs.map((doc) => doc.data()).toList());

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

  Future<void> removeRecipe(String recipeId) async {
    final currentUserId = authController.user.uid;
    final recipeDoc = firestore
        .collection('users')
        .doc(currentUserId)
        .collection('savedRecipes')
        .doc(recipeId);

    print('Removing recipe for user: $currentUserId, recipeId: $recipeId');

    await recipeDoc.delete();
    print('Recipe removed successfully');
    await fetchSavedRecipes();
  }
}
