import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kyc_demo/components/CustomButton.dart';

class UploaderScreen extends StatefulWidget {
  const UploaderScreen({super.key});
  @override
  State<UploaderScreen> createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<UploaderScreen> {
  bool isUploading = false;
  String path = '';

  late StreamSubscription streamSubscription;

  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/uploaderEventChannel');

  static const MethodChannel methodChannel =
      MethodChannel('samples.flutter.io/uploaderMethodChannel');

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
    streamSubscription = eventChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
    initUploader();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  void _onEvent(event) {
    setState(() {
      isUploading = event['uploading'] ?? false;
      path = event['path'] ?? "";
    });
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

  void _onError(error) {
    debugPrint('Error: $error');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uploader')),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          child: path.isNotEmpty
              ? Flexible(
                  child: CustomButton(
                      disabled: isUploading,
                      label: "Copy link",
                      onPressed: copy))
              : Flexible(
                  child: CustomButton(
                    disabled: isUploading,
                    label: "Open picker",
                    onPressed: initUploader,
                  ),
                ),
        ),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          alignment: Alignment.center,
          child: Text(isUploading
              ? 'Loading...'
              : path.isNotEmpty
                  ? path
                  : 'No result'),
        ),
      ),
    );
  }
}
