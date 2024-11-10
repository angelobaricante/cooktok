import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cooktok/constants.dart';
import 'package:cooktok/views/screens/confirm_screen.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({Key? key}) : super(key: key);

  @override
  _AddVideoScreenState createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickVideo(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        // Navigate to ConfirmScreen
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ConfirmScreen(
                videoFile: File(video.path),
                videoPath: video.path,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Handle any errors here
      print('Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick video. Please try again.')),
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

  void _showOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Video Source'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
              child: const Row(
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 10),
                  Text('Gallery'),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
              child: const Row(
                children: [
                  Icon(Icons.videocam),
                  SizedBox(width: 10),
                  Text('Camera'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Video'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _showOptionsDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Add Video',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}