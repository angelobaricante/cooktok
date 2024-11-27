import 'package:cooktok/constants.dart';
import 'package:cooktok/controllers/profile_controller.dart';
import 'package:cooktok/controllers/video_controller.dart';
import 'package:cooktok/views/screens/user_video_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final bool showBackButton;
  const ProfileScreen({
    Key? key,
    required this.uid,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      profileController.updateUserId(widget.uid);
    }
  }

  void _showFullScreenProfileImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (profileController.user.value.isEmpty) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black12,
          leading: widget.showBackButton
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          actions: const [Icon(Icons.more_horiz)],
          title: Text(
            profileController.user.value['name'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        _showFullScreenProfileImage(
                          context,
                          profileController.user.value['profilePhoto'],
                        );
                      },
                      child: ClipOval(
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: profileController.user.value['profilePhoto'],
                          height: 100,
                          width: 100,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          profileController.user.value['following'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text('Following', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Container(
                      color: Colors.black54,
                      width: 1,
                      height: 15,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    Column(
                      children: [
                        Text(
                          profileController.user.value['followers'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text('Followers', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Container(
                      color: Colors.black54,
                      width: 1,
                      height: 15,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    Column(
                      children: [
                        Text(
                          profileController.user.value['likes'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text('Likes', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: 140,
                  height: 47,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black12)),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        if (widget.uid == authController.user.uid) {
                          authController.signOut();
                        } else {
                          profileController.followUser();
                        }
                      },
                      child: Text(
                        widget.uid == authController.user.uid
                            ? 'Sign Out'
                            : profileController.user.value['isFollowing']
                                ? 'Unfollow'
                                : 'Follow',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  final userVideos = videoController.getUserVideos(widget.uid);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userVideos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      final video = userVideos[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          InkWell(
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
                            child: CachedNetworkImage(
                              imageUrl: video.thumbnail,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (widget.uid == authController.user.uid)
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Video'),
                                      content: Text(
                                          'Are you sure you want to delete this video?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: Text('Delete'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            videoController
                                                .deleteVideo(video.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}