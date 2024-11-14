import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cooktok/controllers/video_controller.dart';
import 'package:cooktok/views/widgets/video_player_item.dart';
import 'package:cooktok/views/screens/video_screen_utils.dart';

class UserVideoScreen extends StatefulWidget {
  final String uid;
  final int? initialVideoIndex;
  const UserVideoScreen({Key? key, required this.uid, this.initialVideoIndex})
      : super(key: key);

  @override
  _UserVideoScreenState createState() => _UserVideoScreenState();
}

class _UserVideoScreenState extends State<UserVideoScreen> {
  late PageController _pageController;
  final VideoController videoController = Get.put(VideoController());

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.initialVideoIndex ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Obx(() {
        final userVideos = videoController.getUserVideos(widget.uid);
        return PageView.builder(
          controller: _pageController,
          itemCount: userVideos.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final data = userVideos[index];
            return Stack(
              children: [
                VideoPlayerItem(
                  videoUrl: data.videoUrl,
                ),
                Column(
                  children: [
                    const SizedBox(height: 100),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    data.username,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data.caption,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.music_note,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        data.songName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            margin: EdgeInsets.only(top: size.height / 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                VideoScreenUtils.buildProfile(
                                  data.profilePhoto,
                                  data.uid,
                                  context,
                                ),
                                VideoScreenUtils.buildVideoActions(
                                  data,
                                  videoController,
                                  context,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
