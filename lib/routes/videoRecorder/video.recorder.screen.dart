import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/customUiKitView.dart';
import 'package:flutter_kyc_demo/enums/enums.dart';
import 'package:flutter_kyc_demo/routes/videoRecorder/video.recorder.result.screen.dart';

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({Key? key}) : super(key: key);
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
    streamSubscription =
        eventChannel.receiveBroadcastStream().listen(onEvent, onError: onError);
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  onEvent(event) {
    if (!mounted) return;
    switch (event["type"]) {
      case "recording_success":
        {
          Navigator.push(
            context,
            MaterialPageRoute<String>(
              builder: (context) =>
                  VideoRecorderResultScreen(result: event["data"]),
            ),
          );
        }
        break;
      case "recording_failed":
        {
          String error = event['data'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade900,
            content: Text(
              error,
              textAlign: TextAlign.left,
            ),
          ));
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
        break;
      default:
        break;
    }
  }

  onError(error) {
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
