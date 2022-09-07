import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';
import 'package:flutter_kyc_demo/components/customUiKitView.dart';
import 'package:flutter_kyc_demo/enums/enums.dart';
import 'package:flutter_kyc_demo/routes/videoRecorder/video.recorder.result.screen.dart';

class VideoRecorderScreen extends StatefulWidget {
  const VideoRecorderScreen({super.key});
  @override
  State<VideoRecorderScreen> createState() => VideoRecorderScreenState();
}

class VideoRecorderScreenState extends State<VideoRecorderScreen>
    with RouteAware {
  late StreamSubscription streamSubscription;
  late CustomUIKitController _instance;

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
  void didPopNext() {
    if (!mounted) return;
    _instance.restart();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  onEvent(event) {
    if (!mounted) return;
    switch (event["type"]) {
      case "record_success":
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
      case "record_failed":
        {
          String error = event['data'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade900,
            content: Text(
              error,
              textAlign: TextAlign.left,
            ),
          ));
        }
        break;
      default:
        break;
    }
  }

  onError(error) {
    debugPrint("Error: $error");
  }

  void _incrementDown(PointerEvent details) {
    _instance.startRecording();
  }

  void _incrementUp(PointerEvent details) {
    _instance.endRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('Hold the button for 5 sec')),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 20),
          child: Positioned(
              bottom: 10,
              child: Listener(
                  onPointerDown: _incrementDown,
                  onPointerUp: _incrementUp,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    color: Colors.orange[900],
                    child: const Text(
                      'Hold',
                    ),
                  ))),
        ),
        body: Stack(children: <Widget>[
          CustomUIKitView(
            viewType: ViewTypes.recorder,
            onCreated: (instance) {
              _instance = instance;
              instance.initialize();
              initEventSubscription();
            },
          ),
        ]));
  }
}
