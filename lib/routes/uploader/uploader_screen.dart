import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/customButton.dart';

class UploaderScreen extends StatefulWidget {
  const UploaderScreen({super.key});
  @override
  State<UploaderScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<UploaderScreen> {
  bool uploading = false;
  String path = '';

  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('kyc.sdk/uploaderEventChannel');

  static const MethodChannel methodChannel =
      MethodChannel('kyc.sdk/uploaderMethodChannel');

  Future<void> initUploader() async {
    try {
      await methodChannel.invokeMethod('initUploader');
    } on PlatformException catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    streamSubscription =
        eventChannel.receiveBroadcastStream().listen(onEvent, onError: onError);
    initUploader();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  void onEvent(event) {
    if (!mounted) return;
    switch (event["type"]) {
      case "upload_started":
        setState(() {
          uploading = true;
        });
        break;
      case "upload_success":
        print('RESULT!!!!!!!!!!!: $event');
        setState(() {
          uploading = false;
          path = event["data"];
        });
        break;
      case "upload_failed":
        setState(() {
          uploading = false;
        });
        break;
      default:
        break;
    }
  }

  void copy() {
    Clipboard.setData(ClipboardData(text: path)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Link copied to clipboard",
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }

  void onError(error) {
    debugPrint('Error: $error');
  }

  @override
  Widget build(BuildContext context) {
    double bottomOffset = Platform.isAndroid ? 20.0 : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Uploader')),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomOffset),
        child: Container(
          child: path.isNotEmpty
              ? CustomButton(
                  disabled: uploading, label: "Copy link", onPressed: copy)
              : CustomButton(
                  disabled: uploading,
                  label: "Open picker",
                  onPressed: initUploader,
                ),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          alignment: Alignment.center,
          child: Text(uploading
              ? 'Loading...'
              : path.isNotEmpty
                  ? path
                  : ''),
        ),
      ),
    );
  }
}
