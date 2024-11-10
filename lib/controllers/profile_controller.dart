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
    var myVideos = await firestore.collection('videos').where('uid', isEqualTo: uid.value).get();
    for (int i = 0; i < myVideos.docs.length; i++) {
      thumbnails.add((myVideos.docs[i].data() as dynamic)['thumbnail']);
    }

    DocumentSnapshot userDoc = await firestore.collection('users').doc(uid.value).get();
    final userData = userDoc.data()! as dynamic;
    String name = userData['name'];
    String profilePhoto = userData['profilePhoto'];
    int likes = 0;

    for (var item in myVideos.docs) {
      likes += (item.data()['likes'] as List).length;
    }

    var followerDoc = await firestore.collection('users').doc(uid.value).collection('followers').get();
    var followingDoc = await firestore.collection('users').doc(uid.value).collection('following').get();
    int followers = followerDoc.docs.length;
    int following = followingDoc.docs.length;

    bool isFollowing = (await firestore.collection('users').doc(uid.value)
        .collection('followers').doc(authController.user.uid).get()).exists;

    user.value = {
      'followers': followers.toString(),
      'following': following.toString(),
      'isFollowing': isFollowing,
      'likes': likes.toString(),
      'profilePhoto': profilePhoto,
      'name': name,
      'thumbnails': thumbnails
    };
    update();
  }

  followUser() async {
    final currentUserId = authController.user.uid;
    final targetUserId = uid.value;

    var doc = await firestore.collection('users').doc(targetUserId).collection('followers').doc(currentUserId).get();

    if (!doc.exists) {
      // Add current user to target user's followers
      await firestore.collection('users').doc(targetUserId).collection('followers').doc(currentUserId).set({});

      // Add target user to current user's following
      await firestore.collection('users').doc(currentUserId).collection('following').doc(targetUserId).set({});

      // Update follower and following counts correctly
      user.value.update('followers', (value) => (int.parse(value) + 1).toString());
    } else {
      // Remove current user from target user's followers
      await firestore.collection('users').doc(targetUserId).collection('followers').doc(currentUserId).delete();

      // Remove target user from current user's following
      await firestore.collection('users').doc(currentUserId).collection('following').doc(targetUserId).delete();

      // Update follower and following counts correctly
      user.value.update('followers', (value) => (int.parse(value) - 1).toString());
    }

    // Toggle follow status
    user.value.update('isFollowing', (value) => !value);
    update();
  }
}
