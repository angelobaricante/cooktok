import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktok/constants.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> user = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get getUser => user.value;

  Rx<String> uid = "".obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
}
