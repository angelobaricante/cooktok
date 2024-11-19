import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooktok/constants.dart';
import 'package:cooktok/models/user.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  final Rx<List<User>> _searchedUsers = Rx<List<User>>([]);

  List<User> get searchedUsers => _searchedUsers.value;

  void searchUser(String typedUser) {
    if (typedUser.isEmpty) {
      _searchedUsers.value = [];
      return;
    }

    String searchKey = typedUser.toLowerCase();

    firestore.collection('users').snapshots().listen((QuerySnapshot query) {
      List<User> retVal = [];
      for (var elem in query.docs) {
        User user = User.fromSnap(elem);
        if (user.name.toLowerCase().contains(searchKey)) {
          retVal.add(user);
        }
      }
      _searchedUsers.value = retVal;
    });
  }
}
