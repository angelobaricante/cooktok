import 'dart:io';
import 'package:cooktok/controllers/upload_video_controller.dart';
import 'package:flutter/material.dart';
import 'package:cooktok/views/widgets/text_input_field.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:cooktok/views/screens/home_screen.dart';
import 'package:uuid/uuid.dart';

// Initialize the UUID generator
var uuid = const Uuid();

class ConfirmScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;
  const ConfirmScreen({
    super.key,
    required this.videoFile,
    required this.videoPath,
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late VideoPlayerController controller;
  final TextEditingController _songController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _recipeTitleController = TextEditingController();
  final TextEditingController _recipeController = TextEditingController();
  final TextEditingController _recipeIdController = TextEditingController();

  UploadVideoController uploadVideoController =
      Get.put(UploadVideoController());
  bool _isLoading = false;
  String _statusMessage = '';

  void generateRecipeId() {
    String generatedId = uuid.v4();
    _recipeIdController.text = generatedId;
    print('Generated Recipe ID: $generatedId');
  }

  @override
  void initState() {
    super.initState();
    generateRecipeId();
    setState(() {
      controller = VideoPlayerController.file(widget.videoFile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    _songController.dispose();
    _captionController.dispose();
    _recipeController.dispose();
    _recipeIdController.dispose();
  }

  void _uploadVideo() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    // Add the print statement here
    print('Recipe ID before upload: ${_recipeIdController.text}');

    try {
      await uploadVideoController.uploadVideo(
        _songController.text,
        _captionController.text,
        widget.videoPath,
        _recipeTitleController.text,
        _recipeController.text,
        _recipeIdController.text,
      );
      if (mounted) {
        setState(() {
          _statusMessage = 'Video uploaded successfully!';
        });
        Get.snackbar(
          'Success',
          'Video uploaded successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      print('Error uploading video: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Failed to upload video: ${e.toString()}';
        });
        Get.snackbar(
          'Error',
          'Failed to upload video. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Video'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: VideoPlayer(controller),
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextInputField(
                        controller: _songController,
                        labelText: 'Song Name (Optional)',
                        icon: Icons.music_note,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextInputField(
                        controller: _captionController,
                        labelText: 'Caption (Optional)',
                        icon: Icons.closed_caption,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextInputField(
                        controller: _recipeTitleController,
                        labelText: 'Recipe Title',
                        icon: Icons.restaurant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextField(
                        controller: _recipeController,
                        decoration: const InputDecoration(
                          labelText: 'Recipe',
                          prefixIcon: Icon(Icons.restaurant_menu),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_statusMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusMessage.contains('Failed')
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _uploadVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Upload!',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Uploading video...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
