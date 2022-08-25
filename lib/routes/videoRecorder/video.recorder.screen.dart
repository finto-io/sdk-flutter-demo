import 'package:flutter/material.dart';

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({super.key});
  @override
  State<VideoRecorderScreen> createState() => VideoRecorderScreenState();
}

class VideoRecorderScreenState extends State<VideoRecorderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video recorder'),
      ),
      body: const SafeArea(
          minimum: EdgeInsets.all(16.0), child: Text('Video recorder')),
    );
  }
}
