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
    for(int i=0; i<myVideos.docs.length; i++){
      thumbnails.add((myVideos.docs[i].data() as dynamic)['thumbnail']);
    }

    DocumentSnapshot userDoc = await firestore.collection('users').doc(uid.value).get();
    final userData = userDoc.data()! as dynamic;
    String name = userData['name'];
    String profilePhoto = userData['profilePhoto'];
    int likes = 0;
    int followers = 0;
    int following = 0;
    bool isFollowing = false;

    for(var item in myVideos.docs){
      likes += (item.data()['likes'] as List).length;
    }
    var followerDoc = await firestore.collection('users').doc(uid.value).collection('followers').get();
    var followingDoc = await firestore.collection('users').doc(uid.value).collection('followers').get();
    followers = followerDoc.docs.length;
    following = followingDoc.docs.length;

    firestore.collection('users').doc(uid.value).collection('followers').doc(authController.user.uid).get().then((value) {
      if(value.exists){
        isFollowing = true;
      }else{
        isFollowing = false;
      }

    });

    user.value = {
      'followers':followers.toString(),
      'following':following.toString(),
      'isFollowing':isFollowing,
      'likes':likes.toString(),
      'profilePhoto':profilePhoto,
      'name':name,
      'thumbnails':thumbnails
    };
    update();
  }

  followUser() async {
    var doc = await firestore.collection('users').doc(uid.value).collection('followers').doc(authController.user.uid).get();
    if(!doc.exists){
      await firestore.collection('users').doc(uid.value).collection('followers').doc(authController.user.uid).set({});
      await firestore.collection('users').doc(authController.user.uid).collection('followers').doc(uid.value).set({});
      user.value.update('follower', (value) => (int.parse(value) + 1).toString());
  }
  else{
    await firestore.collection('users').doc(uid.value).collection('followers').doc(authController.user.uid).delete();
      await firestore.collection('users').doc(authController.user.uid).collection('followers').doc(uid.value).delete();
      user.value.update('follower', (value) => (int.parse(value) - 1).toString());
  }

  user.value.update('isFollowing', (value) => !value);
  update();
}
}