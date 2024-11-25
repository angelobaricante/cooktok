import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cooktok/controllers/search_controller.dart' as custom;
import 'package:cooktok/views/screens/profile_screen.dart';
import 'package:cooktok/views/screens/user_video_screen.dart';
import 'package:get/get.dart';

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
              hintText: 'Search for users or recipes',
              hintStyle: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onChanged: (value) => searchController.search(value),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Users Section
              if (searchController.searchedUsers.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Users',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchController.searchedUsers.length,
                  itemBuilder: (context, index) {
                    var user = searchController.searchedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['profilePhoto'] ?? ''),
                      ),
                      title: Text(
                        user['name'] ?? 'Unnamed User',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      onTap: () {
                        // Navigate to ProfileScreen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(uid: user['uid']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
              // Recipes Section
              if (searchController.searchedVideos.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Recipes',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchController.searchedVideos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    var video = searchController.searchedVideos[index];
                    String thumbnail = video['thumbnail'] ?? '';
                    String recipeTitle = video['recipeTitle'] ?? 'No title';

                    return InkWell(
                      onTap: () {
                        // Navigate to the video player screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UserVideoScreen(
                              uid: video['uid'] ?? '',
                              initialVideoIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: thumbnail,
                            fit: BoxFit.cover,
                            height: 150,  // Thumbnail height
                            width: double.infinity,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          const SizedBox(height: 4), // Reduced the gap between thumbnail and title
                          Text(
                            recipeTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
