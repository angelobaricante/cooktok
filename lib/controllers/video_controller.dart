import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cooktok/constants.dart';
import 'package:cooktok/models/video.dart';
import 'package:get/get.dart';

class VideoController extends GetxController {
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);

  List<Video> get videoList => _videoList.value;

  @override
  void onInit() {
    super.onInit();
    _videoList.bindStream(
        firestore.collection('videos').snapshots().map((QuerySnapshot query) {
      List<Video> retVal = [];
      for (var element in query.docs) {
        retVal.add(
          Video.fromSnap(element),
        );
      }
      return retVal;
    }));
  }

  likeVideo(String id) async {
    DocumentSnapshot doc = await firestore.collection('videos').doc(id).get();
    var uid = authController.user.uid;
    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  List<Video> getUserVideos(String uid) {
    return _videoList.value.where((video) => video.uid == uid).toList();
  }

  Future<void> deleteVideo(String videoId) async {
    try {
      // Get the video document
      DocumentSnapshot videoDoc =
          await firestore.collection('videos').doc(videoId).get();

      if (!videoDoc.exists) {
        throw 'Video document not found';
      }

      // Get the video URL from the document
      String videoUrl = (videoDoc.data() as Map<String, dynamic>)['videoUrl'];

      // Delete the video file from Firebase Storage
      Reference storageRef = FirebaseStorage.instance.refFromURL(videoUrl);
      await storageRef.delete();

      // Delete the video document from Firestore
      await firestore.collection('videos').doc(videoId).delete();

      // Remove the video from the local list
      _videoList.update((val) {
        val?.removeWhere((video) => video.id == videoId);
      });

      Get.snackbar('Success', 'Video deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete video: $e');
    }
  }
}
