import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cooktok/controllers/auth_controller.dart';
import 'package:cooktok/controllers/profile_controller.dart';
import 'package:cooktok/controllers/video_controller.dart';
import 'package:cooktok/views/screens/user_video_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  late final ProfileController profileController;
  late final VideoController videoController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileController());
    _initVideoController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.updateUserId(widget.uid);
    });
  }

  void _initVideoController() {
    if (!Get.isRegistered<VideoController>()) {
      Get.put(VideoController());
    }
    videoController = Get.find<VideoController>();
  }

  void _showFullScreenProfileImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Obx(() => Text(
          widget.uid == authController.user.uid
              ? 'My Profile'
              : profileController.user['name'] ?? '',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        )),
        actions: [
          if (widget.uid == authController.user.uid)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Account'),
                      content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop();
                            authController.deleteAccount();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text('Delete Account', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _showFullScreenProfileImage(
                  context,
                  profileController.user['profilePhoto'] ?? '',
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: profileController.user['profilePhoto'] ?? '',
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn('Following', profileController.user['following'] ?? '0'),
                  Container(color: Colors.black54, width: 1, height: 15, margin: const EdgeInsets.symmetric(horizontal: 15)),
                  _buildStatColumn('Followers', profileController.user['followers'] ?? '0'),
                  Container(color: Colors.black54, width: 1, height: 15, margin: const EdgeInsets.symmetric(horizontal: 15)),
                  _buildStatColumn('Likes', profileController.user['likes'] ?? '0'),
                ],
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () {
                  if (widget.uid == authController.user.uid) {
                    authController.signOut();
                  } else {
                    profileController.followUser();
                  }
                },
                child: Container(
                  width: 140,
                  height: 47,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      widget.uid == authController.user.uid
                          ? 'Sign Out'
                          : profileController.user['isFollowing'] ?? false
                              ? 'Unfollow'
                              : 'Follow',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                final userVideos = videoController.getUserVideos(widget.uid);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userVideos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    final video = userVideos[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UserVideoScreen(
                              uid: widget.uid,
                              initialVideoIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: video.thumbnail,
                            fit: BoxFit.cover,
                          ),
                          if (widget.uid == authController.user.uid)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () => _showDeleteVideoDialog(video.id),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatColumn(String title, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  void _showDeleteVideoDialog(String videoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Video'),
        content: Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop();
              videoController.deleteVideo(videoId);
            },
          ),
        ],
      ),
    );
  }
}

