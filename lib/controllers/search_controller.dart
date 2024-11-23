import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Rx<List<Map<String, dynamic>>> _searchedVideos = Rx<List<Map<String, dynamic>>>([]);
  final Rx<List<Map<String, dynamic>>> _searchedUsers = Rx<List<Map<String, dynamic>>>([]);

  List<Map<String, dynamic>> get searchedVideos => _searchedVideos.value;
  List<Map<String, dynamic>> get searchedUsers => _searchedUsers.value;

  void search(String query) async {
    if (query.isEmpty) {
      _searchedUsers.value = [];
      _searchedVideos.value = [];
      return;
    }

    final searchKey = query.toLowerCase();

    // Fetch users
    firestore.collection('users').get().then((querySnapshot) {
      List<Map<String, dynamic>> matchedUsers = [];
      for (var doc in querySnapshot.docs) {
        var userData = doc.data();
        if (userData['name']?.toLowerCase().contains(searchKey) ?? false) {
          matchedUsers.add(userData);
        }
      }
      _searchedUsers.value = matchedUsers;
    });

    // Fetch videos
    firestore.collection('videos').get().then((querySnapshot) {
      List<Map<String, dynamic>> matchedVideos = [];
      for (var doc in querySnapshot.docs) {
        var videoData = doc.data();
        if (videoData['recipeTitle']?.toLowerCase().contains(searchKey) ?? false) {
          matchedVideos.add(videoData);
        }
      }
      _searchedVideos.value = matchedVideos;
    });
  }
}
