import 'package:flutter/material.dart';
import 'package:cooktok/controllers/search_controller.dart' as custom;
import 'package:cooktok/views/screens/profile_screen.dart';
import 'package:get/get.dart';
import 'package:cooktok/views/screens/profile_screen.dart'; // Add this import

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  final custom.SearchController searchController =
      Get.put(custom.SearchController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: TextFormField(
            decoration: const InputDecoration(
              filled: false,
              hintText: 'Search',
              hintStyle: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onChanged: (value) =>
                searchController.searchUser(value), // Trigger live search
          ),
        ),
        body: searchController.searchedUsers.isEmpty
            ? const Center(
                child: Text(
                  'Search for users!',
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                itemCount: searchController.searchedUsers.length,
                itemBuilder: (context, index) {
                  var user = searchController.searchedUsers[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(uid: user.uid),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePhoto),
                      ),
                      title: Text(
                        user.name,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}
