import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomUIKitView.dart';
import 'package:flutter_kyc_demo/routes/videoRecorder/video.recorder.result.screen.dart';

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({super.key});
  @override
  State<VideoRecorderScreen> createState() => VideoRecorderScreenState();
}

class VideoRecorderScreenState extends State<VideoRecorderScreen> {
  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/recorderEventChannel');

  @override
  void initState() {
    super.initState();
  }

  void initEventSubscription() {
    streamSubscription = eventChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  _onEvent(event) {
    var type = event["type"];
    if (type == "videoViewRecordSuccess" && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<String>(
          builder: (context) =>
              VideoRecorderResultScreen(result: event["params"]),
        ),
      );
    } else {
      var error = event["params"];
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   backgroundColor: Colors.red.shade900,
      //   content: Text(
      //     "$error",
      //     textAlign: TextAlign.left,
      //   ),
      // ));
    }
  }

  _onError(error) {
    debugPrint("Error: $error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Hold the button for 5 sec')),
      body: SafeArea(
        minimum: const EdgeInsets.all(0.0),
        child: CustomUIKitView(
          viewType: ViewTypes.recorder,
          onCreated: (instance) {
            instance.initialize();
            initEventSubscription();
          },
        ),
      ),
    );
  }
}
