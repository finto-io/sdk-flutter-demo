import 'dart:async';

import 'package:flutter/foundation.dart';
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

  bool uploading = false;

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
          setState(() {
            uploading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute<String>(
              builder: (context) =>
                  VideoRecorderResultScreen(result: event["data"]),
            ),
          );
        }
        break;
      case "record_loading_started":
        {
          setState(() {
            uploading = true;
          });
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
        body: Stack(children: <Widget>[
          CustomUIKitView(
            viewType: ViewTypes.recorder,
            onCreated: (instance) {
              _instance = instance;
              instance.initialize();
              initEventSubscription();
            },
          ),
          defaultTargetPlatform == TargetPlatform.android
              ? Stack(children: <Widget>[
                  Positioned(
                      left: 50,
                      right: 50,
                      bottom: 30,
                      child: Listener(
                          onPointerDown: _incrementDown,
                          onPointerUp: _incrementUp,
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orange[900],
                            ),
                            child: const Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                              "Hold",
                            ),
                          ))),
                  uploading
                      ? Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          right: 0,
                          child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration:
                                  const BoxDecoration(color: Colors.white30),
                              child: Center(
                                child: Container(
                                    width: 16,
                                    height: 16,
                                    child: const CircularProgressIndicator()),
                              )))
                      : Container()
                ])
              : Container(),
        ]));
  }
}
